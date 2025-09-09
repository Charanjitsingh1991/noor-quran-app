exports.handler = async (event, context) => {
  // Handle CORS preflight
  if (event.httpMethod === 'OPTIONS') {
    return {
      statusCode: 200,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type',
      },
      body: JSON.stringify({}),
    };
  }

  if (event.httpMethod !== 'POST') {
    return {
      statusCode: 405,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type',
      },
      body: JSON.stringify({ success: false, error: 'Method not allowed' }),
    };
  }

  try {
    const { email, otp } = JSON.parse(event.body);

    if (!email || !otp) {
      return {
        statusCode: 400,
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'POST, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type',
        },
        body: JSON.stringify({ success: false, error: 'Email and OTP are required' }),
      };
    }

    // Forward the request to the OTP service
    const otpServiceUrl = process.env.OTP_SERVICE_URL || 'https://noor-otp-service-nd3swur9u-charanjit-singhs-projects-01b838c6.vercel.app';

    console.log('Sending OTP verification request to:', otpServiceUrl + '/api/verify-otp');

    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 10000); // 10 second timeout

    const response = await fetch(otpServiceUrl + '/api/verify-otp', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'User-Agent': 'Noor-Web-App/1.0',
        'Accept': 'application/json',
      },
      body: JSON.stringify({
        email,
        otp,
      }),
      signal: controller.signal,
    });

    clearTimeout(timeoutId);

    console.log('OTP verification response status:', response.status);

    const data = await response.json();
    console.log('OTP verification response data:', data);

    return {
      statusCode: response.status,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type',
      },
      body: JSON.stringify(data),
    };
  } catch (error) {
    console.error('Verify OTP API error:', error);
    return {
      statusCode: 500,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type',
      },
      body: JSON.stringify({
        success: false,
        error: 'Network error: Please check your connection and try again.'
      }),
    };
  }
};