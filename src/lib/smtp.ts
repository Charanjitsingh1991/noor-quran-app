import nodemailer from 'nodemailer';

// SMTP Configuration for Hostinger - Working STARTTLS Configuration
const smtpConfig = {
  host: process.env.SMTP_HOST || 'smtp.hostinger.com',
  port: parseInt(process.env.SMTP_PORT || '587'), // STARTTLS port
  secure: false, // false for STARTTLS, true for SSL
  requireTLS: true, // Require TLS upgrade
  auth: {
    user: process.env.SMTP_USER || 'noreply@thecharanjitsingh.com',
    pass: process.env.SMTP_PASS || 'Sw33thrt@123'
  },
  // Connection settings
  connectionTimeout: 10000, // 10 seconds
  greetingTimeout: 5000,   // 5 seconds
  socketTimeout: 10000,    // 10 seconds
  // Debug settings (disable in production)
  debug: process.env.NODE_ENV === 'development',
  logger: process.env.NODE_ENV === 'development'
};

// Create transporter
const transporter = nodemailer.createTransport(smtpConfig);

// Verify connection
export const verifySMTPConnection = async (): Promise<boolean> => {
  try {
    await transporter.verify();
    console.log('SMTP connection verified successfully');
    return true;
  } catch (error) {
    console.error('SMTP connection failed:', error);
    return false;
  }
};

// Send OTP email
export const sendOTPEmail = async (email: string, otp: string, name?: string): Promise<boolean> => {
  try {
    const mailOptions = {
      from: `"Noor Al Quran" <noreply@thecharanjitsingh.com>`,
      to: email,
      subject: 'Your Verification Code - Noor Al Quran',
      html: `
        <!DOCTYPE html>
        <html lang="en">
        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>Noor Al Quran - OTP Verification</title>
        </head>
        <body style="margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh;">
          <div style="max-width: 600px; margin: 0 auto; background: #ffffff; border-radius: 20px; overflow: hidden; box-shadow: 0 20px 40px rgba(0,0,0,0.1);">
            <!-- Header with Islamic Pattern -->
            <div style="background: linear-gradient(135deg, #2c3e50 0%, #3498db 100%); padding: 40px 30px; text-align: center; position: relative;">
              <div style="position: absolute; top: 0; left: 0; right: 0; height: 100%; background-image: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><text fill="rgba(255,255,255,0.1)" font-size="20" y="50%">﷽</text></svg>'); background-repeat: repeat; opacity: 0.3;"></div>
              <h1 style="color: #ffffff; margin: 0; font-size: 28px; font-weight: 700; text-shadow: 2px 2px 4px rgba(0,0,0,0.3); position: relative; z-index: 2;">
                نور القرآن
              </h1>
              <p style="color: #ecf0f1; margin: 10px 0 0 0; font-size: 16px; opacity: 0.9; position: relative; z-index: 2;">
                Noor Al Quran
              </p>
            </div>

            <!-- Main Content -->
            <div style="padding: 40px 30px; text-align: center;">
              <div style="margin-bottom: 30px;">
                <h2 style="color: #2c3e50; margin: 0 0 10px 0; font-size: 24px; font-weight: 600;">
                  Assalamu Alaikum${name ? `, ${name}` : ''}!
                </h2>
                <p style="color: #7f8c8d; margin: 0; font-size: 16px; line-height: 1.6;">
                  Welcome to Noor Al Quran. To complete your verification, please use the code below:
                </p>
              </div>

              <!-- OTP Card -->
              <div style="background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%); border: 2px solid #3498db; border-radius: 15px; padding: 30px; margin: 30px 0; position: relative; box-shadow: 0 8px 25px rgba(52, 152, 219, 0.2);">
                <div style="position: absolute; top: -15px; left: 50%; transform: translateX(-50%); background: #3498db; color: white; padding: 8px 20px; border-radius: 20px; font-size: 14px; font-weight: 600;">
                  🔐 VERIFICATION CODE
                </div>
                <div style="font-size: 42px; font-weight: 900; color: #2c3e50; letter-spacing: 8px; margin: 20px 0; text-shadow: 2px 2px 4px rgba(0,0,0,0.1); font-family: 'Courier New', monospace;">
                  ${otp}
                </div>
                <div style="border-top: 1px solid #bdc3c7; padding-top: 15px; margin-top: 20px;">
                  <p style="color: #95a5a6; margin: 0; font-size: 14px;">
                    This code will expire in <strong style="color: #e74c3c;">10 minutes</strong>
                  </p>
                </div>
              </div>

              <!-- Instructions -->
              <div style="background: #f8f9fa; border-radius: 10px; padding: 20px; margin: 20px 0; border-left: 4px solid #3498db;">
                <h3 style="color: #2c3e50; margin: 0 0 10px 0; font-size: 18px;">📋 How to use:</h3>
                <p style="color: #7f8c8d; margin: 0; font-size: 14px; line-height: 1.5;">
                  1. Copy the verification code above<br>
                  2. Return to the Noor Al Quran app<br>
                  3. Enter the code to complete verification
                </p>
              </div>

              <!-- Security Notice -->
              <div style="background: #fff3cd; border: 1px solid #ffeaa7; border-radius: 8px; padding: 15px; margin: 20px 0;">
                <p style="color: #856404; margin: 0; font-size: 14px; font-weight: 500;">
                  🔒 <strong>Security Notice:</strong> If you didn't request this verification code, please ignore this email. Your account remains secure.
                </p>
              </div>

              <!-- Footer -->
              <div style="border-top: 1px solid #ecf0f1; padding-top: 30px; margin-top: 30px;">
                <div style="text-align: center;">
                  <p style="color: #95a5a6; margin: 0 0 10px 0; font-size: 14px;">
                    <strong>Noor Al Quran Team</strong>
                  </p>
                  <p style="color: #bdc3c7; margin: 0; font-size: 12px;">
                    Bringing the light of Quran to your digital world 🌙📖
                  </p>
                  <div style="margin: 20px 0;">
                    <span style="display: inline-block; background: #3498db; color: white; padding: 8px 16px; border-radius: 20px; font-size: 12px; font-weight: 600;">
                      ﷽ Bismillah ﷽
                    </span>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Bottom spacing -->
          <div style="height: 40px;"></div>
        </body>
        </html>
      `
    };

    const info = await transporter.sendMail(mailOptions);
    console.log('OTP email sent successfully:', info.messageId);
    return true;
  } catch (error) {
    console.error('Error sending OTP email:', error);
    return false;
  }
};

// Generate 6-digit OTP
export const generateOTP = (): string => {
  return Math.floor(100000 + Math.random() * 900000).toString();
};

export default transporter;
