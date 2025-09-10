import { NextRequest, NextResponse } from 'next/server';
import { sendPasswordResetEmail, generateOTP } from '@/lib/smtp';
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
    const { email, name } = await request.json();

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

    // Generate OTP for password reset
    const otp = generateOTP();
    const expiresAt = Date.now() + (10 * 60 * 1000); // 10 minutes

    // Store OTP with type 'password_reset'
    otpStore.set(email, {
      otp,
      expiresAt,
      name: name || 'User',
      type: 'password_reset',
      attempts: 0
    });

    // Send password reset OTP email
    const emailSent = await sendPasswordResetEmail(email, otp, name);

    if (!emailSent) {
      return NextResponse.json(
        { success: false, error: 'Failed to send password reset email' },
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

    console.log(`Password reset OTP sent to ${email}: ${otp}`);

    return NextResponse.json(
      { success: true, message: 'Password reset OTP sent successfully' },
      {
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'POST, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type',
        },
      }
    );
  } catch (error) {
    console.error('Forgot password API error:', error);
    return NextResponse.json(
      {
        success: false,
        error: 'Failed to send password reset email. Please try again.'
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
