#!/bin/bash

echo "🚀 Deploying Noor Flutter Web App to Vercel..."

# Check if Vercel CLI is installed
if ! command -v vercel &> /dev/null; then
    echo "❌ Vercel CLI is not installed. Please install it first:"
    echo "npm install -g vercel"
    exit 1
fi

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first:"
    echo "https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Check if user is logged in to Vercel
if ! vercel whoami &> /dev/null; then
    echo "🔐 Please login to Vercel first:"
    vercel login
fi

# Enable web support
echo "🔧 Enabling Flutter web support..."
flutter config --enable-web

# Clean and build
echo "🧹 Cleaning previous builds..."
flutter clean

echo "📦 Getting dependencies..."
flutter pub get

echo "🏗️ Building for web..."
flutter build web --release --web-renderer canvaskit

if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi

# Deploy to Vercel
echo "📦 Deploying to Vercel..."
vercel --prod

echo "✅ Deployment complete!"
echo "🔗 Your Flutter web app will be available at the URL shown above"
echo "📝 Don't forget to update the OTP service URL in your Flutter app if needed"
