exports.handler = async (event) => {
  console.log('Event:', JSON.stringify(event, null, 2));
  
  return {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
    },
    body: JSON.stringify({
      message: 'Identity service placeholder',
      path: event.rawPath || event.path,
    }),
  };
};
