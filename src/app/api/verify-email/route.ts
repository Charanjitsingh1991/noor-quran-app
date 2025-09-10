import { NextRequest, NextResponse } from 'next/server';
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
    const { email, otp } = await request.json();

    if (!email || !otp) {
      return NextResponse.json(
        { success: false, error: 'Email and OTP are required' },
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

    const storedData = otpStore.get(email);

    if (!storedData) {
      return NextResponse.json(
        { success: false, error: 'OTP not found or expired' },
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

    // Check if OTP is expired
    if (Date.now() > storedData.expiresAt) {
      otpStore.delete(email);
      return NextResponse.json(
        { success: false, error: 'OTP has expired' },
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

    // Check attempts
    if (storedData.attempts >= 3) {
      otpStore.delete(email);
      return NextResponse.json(
        { success: false, error: 'Too many failed attempts' },
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

    // Verify OTP
    if (storedData.otp === otp) {
      // Success - remove OTP from store
      otpStore.delete(email);
      return NextResponse.json(
        {
          success: true,
          message: 'OTP verified successfully',
          user: {
            email,
            name: storedData.name
          }
        },
        {
          headers: {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'POST, OPTIONS',
            'Access-Control-Allow-Headers': 'Content-Type',
          },
        }
      );
    } else {
      // Failed attempt
      storedData.attempts++;
      otpStore.set(email, storedData);
      return NextResponse.json(
        {
          success: false,
          error: 'Invalid OTP',
          attemptsLeft: 3 - storedData.attempts
        },
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
  } catch (error) {
    console.error('Verify email API error:', error);
    return NextResponse.json(
      {
        success: false,
        error: 'Failed to verify OTP'
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
