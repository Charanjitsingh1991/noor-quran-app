# 🚀 Complete Noor Project Deployment Guide

This guide will help you deploy both the OTP service and Flutter web app to Vercel for a complete production setup.

## 📋 Prerequisites

### Required Software
- ✅ **Node.js** (v16 or higher) - [Download](https://nodejs.org/)
- ✅ **Flutter** (latest stable) - [Install Guide](https://flutter.dev/docs/get-started/install)
- ✅ **Vercel CLI** - Install globally:
  ```bash
  npm install -g vercel
  ```

### Required Accounts
- ✅ **Vercel Account** - [Sign up](https://vercel.com)
- ✅ **Hostinger Email** - With SMTP access

## 🎯 Quick Deployment (Recommended)

### One-Command Deployment
```bash
# Make the script executable (Windows users skip this)
chmod +x deploy-full.sh

# Run the full deployment
./deploy-full.sh
```

This script will:
1. ✅ Check all prerequisites
2. ✅ Deploy OTP service first
3. ✅ Get the OTP service URL
4. ✅ Update Flutter app with production URL
5. ✅ Deploy Flutter web app
6. ✅ Provide final URLs

## 📝 Manual Deployment Steps

### Step 1: Deploy OTP Service

```bash
cd otp-service

# Install dependencies
npm install

# Deploy to Vercel
vercel --prod
```

**Note the OTP service URL** (e.g., `https://noor-otp-service.vercel.app`)

### Step 2: Update Flutter App

```bash
# Update the OTP service URL in Flutter app
# Replace the placeholder URL with your actual OTP service URL
sed -i 's|https://noor-otp-service.vercel.app|YOUR_OTP_SERVICE_URL|g' noor_flutter/lib/services/otp_service.dart
```

### Step 3: Deploy Flutter Web App

```bash
cd noor_flutter

# Enable web support
flutter config --enable-web

# Clean and build
flutter clean
flutter pub get
flutter build web --release --web-renderer canvaskit

# Deploy to Vercel
vercel --prod
```

## 🔧 Configuration Files Created

### OTP Service (`otp-service/`)
- ✅ **`vercel.json`** - Vercel deployment config
- ✅ **`deploy.sh`** - Individual deployment script
- ✅ **`.env`** - Your Hostinger SMTP credentials
- ✅ **`.gitignore`** - Excludes sensitive files

### Flutter App (`noor_flutter/`)
- ✅ **`vercel.json`** - Vercel deployment config
- ✅ **`build.sh`** - Build script for production
- ✅ **`deploy.sh`** - Individual deployment script
- ✅ **`.gitignore`** - Flutter-specific exclusions

### Root Level
- ✅ **`deploy-full.sh`** - Complete deployment automation

## 📧 Email Configuration

Your Hostinger email is already configured in `otp-service/.env`:

```bash
SMTP_HOST=smtp.hostinger.com
SMTP_PORT=465
SMTP_SECURE=true
SMTP_USER=noreply@thecharanjitsingh.com
SMTP_PASS=Sw33thrt@123
```

## 🌐 Production URLs

After deployment, you'll get two URLs:

1. **OTP Service**: `https://noor-otp-service-[hash].vercel.app`
2. **Flutter Web App**: `https://noor-flutter-[hash].vercel.app`

## 🧪 Testing Your Deployment

### 1. Health Check
```bash
curl https://your-otp-service-url.vercel.app/api/health
```

### 2. Test OTP Sending
```bash
curl -X POST https://your-otp-service-url.vercel.app/api/send-otp \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","name":"Test User"}'
```

### 3. Test Full App
1. Visit your Flutter web app URL
2. Try the signup process
3. Check if OTP emails are received

## 🔧 Troubleshooting

### Common Issues

#### 1. **SMTP Connection Failed**
```bash
# Check your .env file in otp-service/
cat otp-service/.env

# Verify credentials with Hostinger
# Test SMTP connection manually if needed
```

#### 2. **Flutter Build Failed**
```bash
# Clean and rebuild
cd noor_flutter
flutter clean
flutter pub get
flutter build web --release --web-renderer canvaskit
```

#### 3. **Vercel Deployment Failed**
```bash
# Check Vercel logs
vercel logs

# Redeploy
vercel --prod
```

#### 4. **CORS Issues**
- Vercel automatically handles CORS for serverless functions
- No additional configuration needed

### Logs and Monitoring

```bash
# View Vercel function logs
vercel logs

# Monitor performance
# Go to Vercel Dashboard → Functions
```

## 🚀 Production Optimizations

### 1. Custom Domain (Optional)
```bash
# Add custom domain to Vercel
vercel domains add yourdomain.com

# Update DNS records as instructed
```

### 2. Environment Variables
- All sensitive data is encrypted in Vercel
- Use Vercel dashboard to manage environment variables
- Never commit secrets to version control

### 3. Performance Monitoring
- Vercel provides built-in analytics
- Monitor function execution times
- Set up error alerts if needed

## 💰 Cost Estimation

| Service | Free Tier | Paid Plans |
|---------|-----------|------------|
| **Vercel** | 100GB bandwidth/month | $20/month (unlimited) |
| **Hostinger Email** | Included with hosting | Based on plan |
| **Flutter Web** | Free | Free |

## 🔒 Security Best Practices

- ✅ Environment variables are encrypted
- ✅ No sensitive data in logs
- ✅ HTTPS enabled by default
- ✅ Rate limiting implemented
- ✅ OTP expiration enforced

## 📱 Mobile App Considerations

Your Flutter mobile app will continue to work with:
- Local development: `http://localhost:3001`
- Production: Your deployed OTP service URL

Update the mobile app's `otp_service.dart` with the production URL when ready to release.

## 🎯 Next Steps After Deployment

1. ✅ **Test the complete signup flow**
2. ✅ **Verify email delivery**
3. ✅ **Check mobile responsiveness**
4. ✅ **Monitor Vercel analytics**
5. ✅ **Set up error monitoring**
6. ✅ **Configure custom domain** (optional)

## 📞 Support

If you encounter issues:

1. **Check Vercel function logs**: `vercel logs`
2. **Verify SMTP credentials** with Hostinger
3. **Test email sending** from Hostinger control panel
4. **Check Flutter build** locally first
5. **Review deployment configuration** files

## 🎉 Success Checklist

- ✅ OTP service deployed and responding
- ✅ Flutter web app deployed and loading
- ✅ Signup process working end-to-end
- ✅ OTP emails being sent successfully
- ✅ No console errors in browser
- ✅ Mobile responsive design working
- ✅ All features functional

---

**🎊 Your complete Noor project is now live on Vercel!**

**OTP Service**: Handles secure email verification
**Flutter Web App**: Provides the full user experience
**Hostinger Email**: Professional email delivery

Test it out and let your users enjoy the seamless signup experience! 🚀
