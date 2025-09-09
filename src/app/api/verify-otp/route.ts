import { NextRequest, NextResponse } from 'next/server';

export async function POST(request: NextRequest) {
  try {
    const { email, otp } = await request.json();

    if (!email || !otp) {
      return NextResponse.json(
        { success: false, error: 'Email and OTP are required' },
        { status: 400 }
      );
    }

    // Forward the request to the OTP service
    const otpServiceUrl = process.env.OTP_SERVICE_URL || 'https://noor-otp-service-nd3swur9u-charanjit-singhs-projects-01b838c6.vercel.app';

    console.log('Verifying OTP request to:', `${otpServiceUrl}/api/verify-otp`);

    const response = await fetch(`${otpServiceUrl}/api/verify-otp`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'User-Agent': 'Noor-Web-App/1.0',
      },
      body: JSON.stringify({
        email,
        otp,
      }),
    });

    console.log('OTP verify response status:', response.status);

    const data = await response.json();
    console.log('OTP verify response data:', data);

    return NextResponse.json(data, {
      status: response.status,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type',
      },
    });
  } catch (error) {
    console.error('Verify OTP API error:', error);
    return NextResponse.json(
      {
        success: false,
        error: 'Network error: Please check your connection and try again.'
      },
      {
        status: 500,
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'POST, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type',
        },
      }
    );
  }
}
