import { NextRequest, NextResponse } from 'next/server';
import { sendOTPEmail, generateOTP } from '@/lib/smtp';
import otpStore from '@/lib/otp-store';

export async function OPTIONS(request: NextRequest) {
  return NextResponse.json(
    {},
    {
      status: 200,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type',
      },
    }
  );
}

export async function POST(request: NextRequest) {
  try {
    const { email, name, type } = await request.json();

    if (!email) {
      return NextResponse.json(
        { success: false, error: 'Email is required' },
        {
          status: 400,
          headers: {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'POST, OPTIONS',
            'Access-Control-Allow-Headers': 'Content-Type',
          },
        }
      );
    }

    // Generate OTP
    const otp = generateOTP();
    const expiresAt = Date.now() + (10 * 60 * 1000); // 10 minutes

    // Store OTP
    otpStore.set(email, {
      otp,
      expiresAt,
      name: name || '',
      attempts: 0
    });

    // Send OTP email using SMTP
    const emailSent = await sendOTPEmail(email, otp, name);

    if (!emailSent) {
      return NextResponse.json(
        { success: false, error: 'Failed to send OTP email' },
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

    console.log(`OTP sent to ${email}: ${otp}`);

    return NextResponse.json(
      { success: true, message: 'OTP sent successfully' },
      {
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'POST, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type',
        },
      }
    );
  } catch (error) {
    console.error('Send email API error:', error);
    return NextResponse.json(
      {
        success: false,
        error: 'Failed to send email. Please try again.'
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
