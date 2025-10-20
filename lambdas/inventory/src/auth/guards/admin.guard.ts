import { Injectable, CanActivate, ExecutionContext, UnauthorizedException, ForbiddenException } from '@nestjs/common';
import axios from 'axios';

@Injectable()
export class AdminGuard implements CanActivate {
  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const authHeader = request.headers.authorization;

    if (!authHeader) {
      throw new UnauthorizedException('Authorization header is missing');
    }

    const token = authHeader.replace('Bearer ', '');

    if (!token) {
      throw new UnauthorizedException('Token is missing');
    }

    try {
      // Call identity Lambda to verify token and get user info
      const identityApiUrl = process.env.IDENTITY_API_URL || 'http://localhost:3000/auth';
      
      const response = await axios.get(`${identityApiUrl}/me`, {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      });

      const user = response.data;

      // Check if user has admin role
      if (user.role !== 'admin') {
        throw new ForbiddenException('Only administrators can access this resource');
      }

      // Attach user to request for further use
      request.user = user;

      return true;
    } catch (error) {
      if (error.response?.status === 401) {
        throw new UnauthorizedException('Invalid or expired token');
      }

      if (error.response?.status === 403) {
        throw new ForbiddenException('Only administrators can access this resource');
      }

      throw new UnauthorizedException('Authentication failed');
    }
  }
}
