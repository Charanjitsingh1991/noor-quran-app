const fs = require('fs');
const path = require('path');

// Create netlify functions directory
const functionsDir = path.join(__dirname, '..', 'netlify', 'functions');
if (!fs.existsSync(functionsDir)) {
  fs.mkdirSync(functionsDir, { recursive: true });
}

// Send OTP function
const sendOtpFunction = `exports.handler = async (event, context) => {
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
    const { email, name } = JSON.parse(event.body);

    if (!email) {
      return {
        statusCode: 400,
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'POST, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type',
        },
        body: JSON.stringify({ success: false, error: 'Email is required' }),
      };
    }

    // Forward the request to the OTP service
    const otpServiceUrl = process.env.OTP_SERVICE_URL || 'https://noor-otp-service-nd3swur9u-charanjit-singhs-projects-01b838c6.vercel.app';

    console.log('Sending OTP request to:', otpServiceUrl + '/api/send-otp');

    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 10000); // 10 second timeout

    const response = await fetch(otpServiceUrl + '/api/send-otp', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'User-Agent': 'Noor-Web-App/1.0',
        'Accept': 'application/json',
      },
      body: JSON.stringify({
        email,
        name: name || 'User',
      }),
      signal: controller.signal,
    });

    clearTimeout(timeoutId);

    console.log('OTP service response status:', response.status);

    const data = await response.json();
    console.log('OTP service response data:', data);

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
    console.error('Send OTP API error:', error);
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
};`;

// Verify OTP function
const verifyOtpFunction = `exports.handler = async (event, context) => {
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
};`;

// Create send-otp function
const sendOtpDir = path.join(functionsDir, 'send-otp');
if (!fs.existsSync(sendOtpDir)) {
  fs.mkdirSync(sendOtpDir, { recursive: true });
}
fs.writeFileSync(path.join(sendOtpDir, 'send-otp.js'), sendOtpFunction);
console.log('Created Netlify function for send-otp');

// Create verify-otp function
const verifyOtpDir = path.join(functionsDir, 'verify-otp');
if (!fs.existsSync(verifyOtpDir)) {
  fs.mkdirSync(verifyOtpDir, { recursive: true });
}
fs.writeFileSync(path.join(verifyOtpDir, 'verify-otp.js'), verifyOtpFunction);
console.log('Created Netlify function for verify-otp');

console.log('Netlify functions created successfully!');
