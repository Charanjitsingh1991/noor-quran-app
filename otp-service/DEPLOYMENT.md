# 🚀 Deploying Noor OTP Service to Vercel

## Prerequisites

1. **Vercel Account**: Sign up at [vercel.com](https://vercel.com)
2. **Vercel CLI**: Install globally
   ```bash
   npm install -g vercel
   ```

## Quick Deployment

### Method 1: Using the Deploy Script (Recommended)

```bash
cd otp-service
./deploy.sh
```

### Method 2: Manual Deployment

1. **Login to Vercel**:
   ```bash
   vercel login
   ```

2. **Deploy to Production**:
   ```bash
   cd otp-service
   vercel --prod
   ```

3. **Set Environment Variables** (if not using vercel.json):
   ```bash
   vercel env add SMTP_HOST
   vercel env add SMTP_PORT
   vercel env add SMTP_SECURE
   vercel env add SMTP_USER
   vercel env add SMTP_PASS
   ```

## Configuration

### Environment Variables

The following environment variables are automatically set via `vercel.json`:

```json
{
  "SMTP_HOST": "smtp.hostinger.com",
  "SMTP_PORT": "465",
  "SMTP_SECURE": "true",
  "SMTP_USER": "noreply@thecharanjitsingh.com",
  "SMTP_PASS": "Sw33thrt@123",
  "PORT": "3001"
}
```

### Custom Domain (Optional)

1. **Add Custom Domain**:
   ```bash
   vercel domains add yourdomain.com
   ```

2. **Update Flutter App**:
   ```dart
   // In lib/services/otp_service.dart
   static const String baseUrl = 'https://yourdomain.com';
   ```

## Testing the Deployment

### 1. Health Check
```bash
curl https://your-vercel-url.vercel.app/api/health
```

### 2. Test OTP Sending
```bash
curl -X POST https://your-vercel-url.vercel.app/api/send-otp \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","name":"Test User"}'
```

### 3. Update Flutter App
Once deployed, update the OTP service URL in your Flutter app:

```dart
// In lib/services/otp_service.dart
static const String baseUrl = 'https://your-vercel-url.vercel.app';
```

## Troubleshooting

### Common Issues

1. **SMTP Connection Failed**
   - Verify Hostinger SMTP credentials
   - Check if SMTP port 465 is allowed
   - Ensure email account has SMTP enabled

2. **Environment Variables Not Set**
   - Check Vercel dashboard → Project Settings → Environment Variables
   - Redeploy after adding variables

3. **CORS Issues**
   - Vercel automatically handles CORS for serverless functions
   - No additional configuration needed

4. **Cold Start Issues**
   - First request might be slow (normal for serverless)
   - Subsequent requests will be faster

### Logs and Monitoring

- **View Logs**: `vercel logs`
- **Monitor Performance**: Vercel Dashboard → Functions
- **Check Errors**: Vercel Dashboard → Errors

## Production Checklist

- ✅ Environment variables configured
- ✅ SMTP credentials verified
- ✅ Domain configured (optional)
- ✅ Flutter app updated with production URL
- ✅ Health check endpoint working
- ✅ OTP send/verify endpoints tested

## Cost Estimation

- **Vercel Hobby Plan**: Free for personal projects
- **Email Costs**: Depends on Hostinger plan
- **Bandwidth**: Minimal for OTP service

## Security Notes

- ✅ Environment variables are encrypted
- ✅ No sensitive data in logs
- ✅ Rate limiting implemented
- ✅ OTP expiration enforced
- ✅ HTTPS enabled by default

## Support

If you encounter issues:
1. Check Vercel function logs
2. Verify SMTP credentials
3. Test with a simple email first
4. Check Hostinger email settings

---

**🎉 Your OTP service is now ready for production!**
