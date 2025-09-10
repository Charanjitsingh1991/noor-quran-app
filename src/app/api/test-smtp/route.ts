import { NextRequest, NextResponse } from 'next/server';
import { verifySMTPConnection } from '@/lib/smtp';

export async function GET(request: NextRequest) {
  try {
    const isConnected = await verifySMTPConnection();

    return NextResponse.json(
      {
        success: isConnected,
        message: isConnected ? 'SMTP connection successful' : 'SMTP connection failed',
        timestamp: new Date().toISOString()
      },
      {
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type',
        },
      }
    );
  } catch (error) {
    console.error('SMTP test error:', error);
    return NextResponse.json(
      {
        success: false,
        message: 'SMTP test failed',
        error: error instanceof Error ? error.message : 'Unknown error',
        timestamp: new Date().toISOString()
      },
      {
        status: 500,
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type',
        },
      }
    );
  }
}

export async function OPTIONS(request: NextRequest) {
  return NextResponse.json(
    {},
    {
      status: 200,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type',
      },
    }
  );
}
