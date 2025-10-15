const { CognitoIdentityProviderClient, InitiateAuthCommand, RespondToAuthChallengeCommand } = require('@aws-sdk/client-cognito-identity-provider');
const { DynamoDBClient } = require('@aws-sdk/client-dynamodb');
const { DynamoDBDocumentClient, GetCommand, PutCommand, UpdateCommand } = require('@aws-sdk/lib-dynamodb');
const { VerifiedPermissionsClient, IsAuthorizedCommand } = require('@aws-sdk/client-verifiedpermissions');
const jwt = require('jsonwebtoken');
const jwksClient = require('jwks-rsa');

// Initialize AWS clients
const cognitoClient = new CognitoIdentityProviderClient({ region: process.env.AWS_REGION });
const dynamoClient = DynamoDBDocumentClient.from(new DynamoDBClient({ region: process.env.AWS_REGION }));
const verifiedPermissionsClient = new VerifiedPermissionsClient({ region: process.env.AWS_REGION });

// Environment variables
const USER_POOL_ID = process.env.USER_POOL_ID;
const CLIENT_ID = process.env.CLIENT_ID;
const TABLE_NAME = process.env.TABLE_NAME;
const POLICY_STORE_ID = process.env.POLICY_STORE_ID;

/**
 * Main Lambda Handler
 * Handles:
 * - Authentication (Cognito PKCE + Google)
 * - Authorization (Verified Permissions)
 * - API Gateway Lambda Authorizer
 * - User profile management (DynamoDB)
 */
exports.handler = async (event) => {
  console.log('Event:', JSON.stringify(event, null, 2));

  try {
    // Detect event type
    if (event.type === 'REQUEST' || event.methodArn) {
      // API Gateway Lambda Authorizer
      return await handleAuthorizer(event);
    } else if (event.httpMethod) {
      // Direct Lambda invocation or API Gateway proxy
      return await handleRequest(event);
    } else {
      throw new Error('Unknown event type');
    }
  } catch (error) {
    console.error('Error:', error);
    return {
      statusCode: 500,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
      body: JSON.stringify({
        error: 'Internal server error',
        message: error.message,
      }),
    };
  }
};

/**
 * Handle HTTP requests
 */
async function handleRequest(event) {
  const path = event.path || event.rawPath;
  const method = event.httpMethod || event.requestContext?.http?.method;
  const body = event.body ? JSON.parse(event.body) : {};

  // Route handling
  if (method === 'POST' && path.includes('/auth/login')) {
    return await handleLogin(body);
  } else if (method === 'POST' && path.includes('/auth/google')) {
    return await handleGoogleAuth(body);
  } else if (method === 'POST' && path.includes('/auth/refresh')) {
    return await handleRefreshToken(body);
  } else if (method === 'GET' && path.includes('/auth/me')) {
    return await handleGetProfile(event);
  } else if (method === 'POST' && path.includes('/auth/authorize')) {
    return await handleAuthorize(event);
  } else {
    return {
      statusCode: 404,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ error: 'Not found' }),
    };
  }
}

/**
 * Handle Cognito PKCE login
 */
async function handleLogin(body) {
  const { username, codeVerifier, authCode } = body;

  if (!username || !codeVerifier || !authCode) {
    return {
      statusCode: 400,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ error: 'Missing required fields' }),
    };
  }

  try {
    // Exchange auth code for tokens using PKCE
    const command = new InitiateAuthCommand({
      AuthFlow: 'CUSTOM_AUTH',
      ClientId: CLIENT_ID,
      AuthParameters: {
        USERNAME: username,
        CODE_VERIFIER: codeVerifier,
        AUTH_CODE: authCode,
      },
    });

    const response = await cognitoClient.send(command);

    // Save user profile to DynamoDB
    const userId = jwt.decode(response.AuthenticationResult.IdToken).sub;
    await saveUserProfile(userId, {
      username,
      lastLogin: new Date().toISOString(),
      provider: 'cognito',
    });

    return {
      statusCode: 200,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        accessToken: response.AuthenticationResult.AccessToken,
        idToken: response.AuthenticationResult.IdToken,
        refreshToken: response.AuthenticationResult.RefreshToken,
        expiresIn: response.AuthenticationResult.ExpiresIn,
      }),
    };
  } catch (error) {
    console.error('Login error:', error);
    return {
      statusCode: 401,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ error: 'Authentication failed', message: error.message }),
    };
  }
}

/**
 * Handle Google OAuth authentication
 */
async function handleGoogleAuth(body) {
  const { googleToken } = body;

  if (!googleToken) {
    return {
      statusCode: 400,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ error: 'Missing Google token' }),
    };
  }

  try {
    // Verify Google token and exchange for Cognito token
    // This requires Cognito Identity Provider with Google configured
    const command = new InitiateAuthCommand({
      AuthFlow: 'CUSTOM_AUTH',
      ClientId: CLIENT_ID,
      AuthParameters: {
        GOOGLE_TOKEN: googleToken,
      },
    });

    const response = await cognitoClient.send(command);

    // Save user profile
    const userId = jwt.decode(response.AuthenticationResult.IdToken).sub;
    const decodedToken = jwt.decode(response.AuthenticationResult.IdToken);
    
    await saveUserProfile(userId, {
      email: decodedToken.email,
      name: decodedToken.name,
      lastLogin: new Date().toISOString(),
      provider: 'google',
    });

    return {
      statusCode: 200,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        accessToken: response.AuthenticationResult.AccessToken,
        idToken: response.AuthenticationResult.IdToken,
        refreshToken: response.AuthenticationResult.RefreshToken,
        expiresIn: response.AuthenticationResult.ExpiresIn,
      }),
    };
  } catch (error) {
    console.error('Google auth error:', error);
    return {
      statusCode: 401,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ error: 'Google authentication failed', message: error.message }),
    };
  }
}

/**
 * Handle token refresh
 */
async function handleRefreshToken(body) {
  const { refreshToken } = body;

  if (!refreshToken) {
    return {
      statusCode: 400,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ error: 'Missing refresh token' }),
    };
  }

  try {
    const command = new InitiateAuthCommand({
      AuthFlow: 'REFRESH_TOKEN_AUTH',
      ClientId: CLIENT_ID,
      AuthParameters: {
        REFRESH_TOKEN: refreshToken,
      },
    });

    const response = await cognitoClient.send(command);

    return {
      statusCode: 200,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        accessToken: response.AuthenticationResult.AccessToken,
        idToken: response.AuthenticationResult.IdToken,
        expiresIn: response.AuthenticationResult.ExpiresIn,
      }),
    };
  } catch (error) {
    console.error('Refresh token error:', error);
    return {
      statusCode: 401,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ error: 'Token refresh failed', message: error.message }),
    };
  }
}

/**
 * Get user profile
 */
async function handleGetProfile(event) {
  const token = extractToken(event);
  
  if (!token) {
    return {
      statusCode: 401,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ error: 'Missing authorization token' }),
    };
  }

  try {
    const decoded = await verifyToken(token);
    const userId = decoded.sub;

    const command = new GetCommand({
      TableName: TABLE_NAME,
      Key: { userId },
    });

    const result = await dynamoClient.send(command);

    if (!result.Item) {
      return {
        statusCode: 404,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ error: 'User not found' }),
      };
    }

    return {
      statusCode: 200,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(result.Item),
    };
  } catch (error) {
    console.error('Get profile error:', error);
    return {
      statusCode: 401,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ error: 'Unauthorized', message: error.message }),
    };
  }
}

/**
 * Handle authorization check (Verified Permissions)
 */
async function handleAuthorize(event) {
  const token = extractToken(event);
  const body = event.body ? JSON.parse(event.body) : {};
  const { resource, action } = body;

  if (!token) {
    return {
      statusCode: 401,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ error: 'Missing authorization token' }),
    };
  }

  try {
    const decoded = await verifyToken(token);
    const userId = decoded.sub;
    const userRole = decoded['custom:role'] || 'user';

    // Get user profile to check role
    const profile = await getUserProfile(userId);
    const role = profile?.role || userRole;

    // Check authorization with Verified Permissions
    const isAuthorized = await checkAuthorization(userId, role, resource, action);

    return {
      statusCode: 200,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        authorized: isAuthorized,
        userId,
        role,
      }),
    };
  } catch (error) {
    console.error('Authorization error:', error);
    return {
      statusCode: 403,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ error: 'Authorization failed', message: error.message }),
    };
  }
}

/**
 * API Gateway Lambda Authorizer
 */
async function handleAuthorizer(event) {
  const token = event.authorizationToken || extractToken(event);

  if (!token) {
    throw new Error('Unauthorized');
  }

  try {
    const decoded = await verifyToken(token);
    const userId = decoded.sub;
    const userRole = decoded['custom:role'] || 'user';

    // Get user profile
    const profile = await getUserProfile(userId);
    const role = profile?.role || userRole;

    // Check if accessing admin panel
    const resource = event.methodArn || event.routeArn;
    const isAdminResource = resource.includes('/admin');

    if (isAdminResource) {
      // Check admin access with Verified Permissions
      const isAuthorized = await checkAuthorization(userId, role, 'admin-panel', 'access');
      
      if (!isAuthorized) {
        throw new Error('Forbidden: Admin access required');
      }
    }

    // Generate IAM policy
    return generatePolicy(userId, 'Allow', event.methodArn || event.routeArn, {
      userId,
      role,
      email: decoded.email,
    });
  } catch (error) {
    console.error('Authorizer error:', error);
    throw new Error('Unauthorized');
  }
}

/**
 * Check authorization with AWS Verified Permissions
 */
async function checkAuthorization(userId, role, resource, action) {
  try {
    const command = new IsAuthorizedCommand({
      policyStoreId: POLICY_STORE_ID,
      principal: {
        entityType: 'User',
        entityId: userId,
      },
      action: {
        actionType: 'Action',
        actionId: action,
      },
      resource: {
        entityType: 'Resource',
        entityId: resource,
      },
      entities: {
        entityList: [
          {
            identifier: {
              entityType: 'User',
              entityId: userId,
            },
            attributes: {
              role: { string: role },
            },
          },
        ],
      },
    });

    const response = await verifiedPermissionsClient.send(command);
    return response.decision === 'ALLOW';
  } catch (error) {
    console.error('Verified Permissions error:', error);
    
    // Fallback: Check if role is admin for admin-panel access
    if (resource === 'admin-panel' && action === 'access') {
      return role === 'admin';
    }
    
    return false;
  }
}

/**
 * Save user profile to DynamoDB
 */
async function saveUserProfile(userId, data) {
  const command = new PutCommand({
    TableName: TABLE_NAME,
    Item: {
      userId,
      ...data,
      updatedAt: new Date().toISOString(),
      createdAt: data.createdAt || new Date().toISOString(),
    },
  });

  await dynamoClient.send(command);
}

/**
 * Get user profile from DynamoDB
 */
async function getUserProfile(userId) {
  const command = new GetCommand({
    TableName: TABLE_NAME,
    Key: { userId },
  });

  const result = await dynamoClient.send(command);
  return result.Item;
}

/**
 * Verify JWT token
 */
async function verifyToken(token) {
  // Remove 'Bearer ' prefix if present
  token = token.replace('Bearer ', '');

  const decoded = jwt.decode(token, { complete: true });
  
  if (!decoded) {
    throw new Error('Invalid token');
  }

  // Get signing key from Cognito JWKS
  const client = jwksClient({
    jwksUri: `https://cognito-idp.${process.env.AWS_REGION}.amazonaws.com/${USER_POOL_ID}/.well-known/jwks.json`,
  });

  const key = await client.getSigningKey(decoded.header.kid);
  const signingKey = key.getPublicKey();

  // Verify token
  return jwt.verify(token, signingKey, {
    algorithms: ['RS256'],
  });
}

/**
 * Extract token from event
 */
function extractToken(event) {
  // Check Authorization header
  const authHeader = event.headers?.Authorization || event.headers?.authorization;
  if (authHeader) {
    return authHeader.replace('Bearer ', '');
  }

  // Check authorizationToken (Lambda authorizer)
  if (event.authorizationToken) {
    return event.authorizationToken.replace('Bearer ', '');
  }

  return null;
}

/**
 * Generate IAM policy for API Gateway
 */
function generatePolicy(principalId, effect, resource, context) {
  const authResponse = {
    principalId,
  };

  if (effect && resource) {
    authResponse.policyDocument = {
      Version: '2012-10-17',
      Statement: [
        {
          Action: 'execute-api:Invoke',
          Effect: effect,
          Resource: resource,
        },
      ],
    };
  }

  if (context) {
    authResponse.context = context;
  }

  return authResponse;
}
