const express = require('express');
const nodemailer = require('nodemailer');
const cors = require('cors');
const crypto = require('crypto');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3001;

// Middleware
app.use(cors());
app.use(express.json());

// In-memory storage for OTPs (in production, use Redis or database)
const otpStore = new Map();

// Email configuration - supports both Gmail and custom SMTP
let transporter;

if (process.env.SMTP_HOST) {
  // Custom SMTP configuration
  transporter = nodemailer.createTransport({
    host: process.env.SMTP_HOST,
    port: parseInt(process.env.SMTP_PORT) || 587,
    secure: process.env.SMTP_SECURE === 'true', // true for 465, false for other ports
    auth: {
      user: process.env.SMTP_USER,
      pass: process.env.SMTP_PASS
    },
    tls: {
      rejectUnauthorized: false // For self-signed certificates
    }
  });
} else {
  // Gmail configuration (default)
  transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user: process.env.EMAIL_USER,
      pass: process.env.EMAIL_APP_PASSWORD
    }
  });
}

// Generate 6-digit OTP
function generateOTP() {
  return crypto.randomInt(100000, 999999).toString();
}

// Send OTP email
async function sendOTPEmail(email, otp) {
  const fromEmail = process.env.SMTP_USER || process.env.EMAIL_USER;

  const mailOptions = {
    from: fromEmail,
    to: email,
    subject: 'Your OTP for Noor Quran App',
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h2 style="color: #D97706;">Welcome to Noor Quran App</h2>
        <p>Your verification code is:</p>
        <div style="background-color: #f4f4f4; padding: 20px; text-align: center; margin: 20px 0;">
          <h1 style="color: #D97706; font-size: 32px; margin: 0; letter-spacing: 5px;">${otp}</h1>
        </div>
        <p>This code will expire in 10 minutes.</p>
        <p>If you didn't request this code, please ignore this email.</p>
        <br>
        <p>Best regards,<br>Noor Quran App Team</p>
      </div>
    `
  };

  return transporter.sendMail(mailOptions);
}

// Routes
app.post('/api/send-otp', async (req, res) => {
  try {
    const { email, name } = req.body;

    if (!email) {
      return res.status(400).json({ error: 'Email is required' });
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

    // Send email
    await sendOTPEmail(email, otp);

    console.log(`OTP sent to ${email}: ${otp}`);
    res.json({ success: true, message: 'OTP sent successfully' });

  } catch (error) {
    console.error('Error sending OTP:', error);
    res.status(500).json({ error: 'Failed to send OTP' });
  }
});

app.post('/api/verify-otp', async (req, res) => {
  try {
    const { email, otp } = req.body;

    if (!email || !otp) {
      return res.status(400).json({ error: 'Email and OTP are required' });
    }

    const storedData = otpStore.get(email);

    if (!storedData) {
      return res.status(400).json({ error: 'OTP not found or expired' });
    }

    // Check if OTP is expired
    if (Date.now() > storedData.expiresAt) {
      otpStore.delete(email);
      return res.status(400).json({ error: 'OTP has expired' });
    }

    // Check attempts
    if (storedData.attempts >= 3) {
      otpStore.delete(email);
      return res.status(400).json({ error: 'Too many failed attempts' });
    }

    // Verify OTP
    if (storedData.otp === otp) {
      // Success - remove OTP from store
      otpStore.delete(email);
      res.json({
        success: true,
        message: 'OTP verified successfully',
        user: {
          email,
          name: storedData.name
        }
      });
    } else {
      // Failed attempt
      storedData.attempts++;
      otpStore.set(email, storedData);
      res.status(400).json({
        error: 'Invalid OTP',
        attemptsLeft: 3 - storedData.attempts
      });
    }

  } catch (error) {
    console.error('Error verifying OTP:', error);
    res.status(500).json({ error: 'Failed to verify OTP' });
  }
});

// Health check
app.get('/api/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

// Clean up expired OTPs every 5 minutes
setInterval(() => {
  const now = Date.now();
  for (const [email, data] of otpStore.entries()) {
    if (now > data.expiresAt) {
      otpStore.delete(email);
    }
  }
}, 5 * 60 * 1000);

app.listen(PORT, () => {
  console.log(`OTP Service running on port ${PORT}`);
  if (process.env.SMTP_HOST) {
    console.log('Using custom SMTP configuration');
    console.log('Make sure to set SMTP_HOST, SMTP_USER, and SMTP_PASS environment variables');
  } else {
    console.log('Using Gmail configuration');
    console.log('Make sure to set EMAIL_USER and EMAIL_APP_PASSWORD environment variables');
  }
});
