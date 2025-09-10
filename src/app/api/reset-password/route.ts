import { NextRequest, NextResponse } from 'next/server';
import { updatePassword } from 'firebase/auth';
import { auth } from '@/lib/firebase';
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
    const { email, otp, newPassword } = await request.json();

    if (!email || !otp || !newPassword) {
      return NextResponse.json(
        { success: false, error: 'Email, OTP, and new password are required' },
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

    // Validate password strength
    if (newPassword.length < 6) {
      return NextResponse.json(
        { success: false, error: 'Password must be at least 6 characters long' },
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

    // Check if this is a password reset OTP
    if (storedData.type !== 'password_reset') {
      return NextResponse.json(
        { success: false, error: 'Invalid OTP type' },
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
      try {
        // Get user by email to update password
        // Note: Firebase Admin SDK would be better here, but for now we'll use client SDK approach
        // In production, you might want to use Firebase Admin SDK on the server

        // For now, we'll return success and let the client handle the password update
        // This is a simplified approach - in production, you'd want server-side password updates

        // Remove OTP from store
        otpStore.delete(email);

        return NextResponse.json(
          {
            success: true,
            message: 'OTP verified successfully. You can now reset your password.',
            email: email
          },
          {
            headers: {
              'Access-Control-Allow-Origin': '*',
              'Access-Control-Allow-Methods': 'POST, OPTIONS',
              'Access-Control-Allow-Headers': 'Content-Type',
            },
          }
        );
      } catch (updateError) {
        console.error('Password update error:', updateError);
        return NextResponse.json(
          { success: false, error: 'Failed to update password' },
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
    console.error('Reset password API error:', error);
    return NextResponse.json(
      {
        success: false,
        error: 'Failed to reset password'
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
