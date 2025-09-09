# Noor OTP Service

A Node.js/Express service for handling email OTP verification for the Noor Quran App.

## Features

- ✅ Email OTP generation and sending
- ✅ OTP verification with expiration
- ✅ Rate limiting (3 attempts per OTP)
- ✅ Automatic OTP cleanup
- ✅ CORS enabled for Flutter and web apps
- ✅ Gmail SMTP integration

## Setup Instructions

### 1. Install Dependencies
```bash
cd otp-service
npm install
```

### 2. Configure Email Service

#### Option A: Gmail (Easiest - Recommended)
1. Go to your Google Account settings
2. Enable 2-Factor Authentication
3. Go to Security → App passwords
4. Generate a password for "Mail"
5. Use this password as `EMAIL_APP_PASSWORD`

#### Option B: Custom Domain Email (Professional)
Use any SMTP service with your custom domain:
- **Outlook/Hotmail**: `smtp-mail.outlook.com:587`
- **Yahoo**: `smtp.mail.yahoo.com:587`
- **Custom Domain**: Check with your hosting provider
- **Professional Services**: SendGrid, Mailgun, AWS SES

### 3. Environment Configuration
```bash
# Copy the example file
cp .env.example .env

# Choose ONE option and edit .env accordingly
```

#### For Gmail:
```bash
EMAIL_USER=your-email@gmail.com
EMAIL_APP_PASSWORD=your-app-password
PORT=3001
```

#### For Custom SMTP:
```bash
SMTP_HOST=smtp.yourdomain.com
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=your-email@yourdomain.com
SMTP_PASS=your-smtp-password
PORT=3001
```

### 4. Start the Service
```bash
# Development mode
npm run dev

# Production mode
npm start
```

The service will run on `http://localhost:3001` by default.

## API Endpoints

### Send OTP
```http
POST /api/send-otp
Content-Type: application/json

{
  "email": "user@example.com",
  "name": "John Doe"
}
```

**Response:**
```json
{
  "success": true,
  "message": "OTP sent successfully"
}
```

### Verify OTP
```http
POST /api/verify-otp
Content-Type: application/json

{
  "email": "user@example.com",
  "otp": "123456"
}
```

**Response:**
```json
{
  "success": true,
  "message": "OTP verified successfully",
  "user": {
    "email": "user@example.com",
    "name": "John Doe"
  }
}
```

### Health Check
```http
GET /api/health
```

**Response:**
```json
{
  "status": "OK",
  "timestamp": "2025-01-09T11:00:00.000Z"
}
```

## Error Handling

### Send OTP Errors
- `400`: Email is required
- `500`: Failed to send OTP (SMTP error)

### Verify OTP Errors
- `400`: Email/OTP required, OTP expired, invalid OTP, too many attempts
- `500`: Failed to verify OTP

## Security Features

- ✅ OTP expiration (10 minutes)
- ✅ Rate limiting (3 attempts per OTP)
- ✅ Automatic cleanup of expired OTPs
- ✅ Input validation
- ✅ CORS protection

## Deployment

### For Production
1. Set environment variables securely
2. Use a process manager like PM2
3. Set up SSL/TLS
4. Configure firewall rules
5. Use a reverse proxy (nginx)

### Environment Variables
```bash
EMAIL_USER=your-production-email@gmail.com
EMAIL_APP_PASSWORD=your-production-app-password
PORT=3001
NODE_ENV=production
```

## Integration with Flutter/Web Apps

### Flutter Integration
```dart
// Send OTP
final result = await OTPService.sendOTP(
  email: 'user@example.com',
  name: 'John Doe',
);

// Verify OTP
final result = await OTPService.verifyOTP(
  email: 'user@example.com',
  otp: '123456',
);
```

### Web App Integration
```javascript
// Send OTP
const response = await fetch('http://your-server:3001/api/send-otp', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    email: 'user@example.com',
    name: 'John Doe'
  })
});

// Verify OTP
const response = await fetch('http://your-server:3001/api/verify-otp', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    email: 'user@example.com',
    otp: '123456'
  })
});
```

## Troubleshooting

### Common Issues

1. **"Authentication failed" error**
   - Check your Gmail credentials
   - Ensure 2FA is enabled and App Password is correct
   - Try enabling "Less secure app access" (not recommended for production)

2. **"Invalid login" error**
   - Verify EMAIL_USER and EMAIL_APP_PASSWORD
   - Check if Gmail account has sending limits

3. **CORS errors**
   - Ensure the service is running and accessible
   - Check firewall settings

4. **OTP not received**
   - Check spam/junk folder
   - Verify email address is correct
   - Check Gmail sending limits

### Gmail Sending Limits
- **Daily limit**: 500 emails per day for free accounts
- **Per minute**: ~20 emails
- Consider upgrading to Google Workspace for higher limits

## Support

For issues or questions:
1. Check the logs in the console
2. Verify your environment configuration
3. Test with a simple email first
4. Check Gmail's security settings

## License

This project is part of the Noor Quran App ecosystem.
