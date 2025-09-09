#!/bin/bash

echo "🚀 Deploying Full Noor Project to Vercel..."
echo "This will deploy both the OTP service and Flutter web app"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
print_status "Checking prerequisites..."

if ! command -v vercel &> /dev/null; then
    print_error "Vercel CLI is not installed. Please install it first:"
    echo "npm install -g vercel"
    exit 1
fi

if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed. Please install Flutter first:"
    echo "https://flutter.dev/docs/get-started/install"
    exit 1
fi

if ! command -v node &> /dev/null; then
    print_error "Node.js is not installed. Please install Node.js first:"
    echo "https://nodejs.org/"
    exit 1
fi

# Check if user is logged in to Vercel
if ! vercel whoami &> /dev/null; then
    print_warning "Please login to Vercel first:"
    vercel login
    if [ $? -ne 0 ]; then
        print_error "Vercel login failed!"
        exit 1
    fi
fi

print_success "Prerequisites check passed!"

# Deploy OTP Service first
print_status "Deploying OTP Service..."
cd otp-service

if [ ! -f ".env" ]; then
    print_warning "OTP service .env file not found. Creating from example..."
    cp .env.example .env
    print_warning "Please edit otp-service/.env with your SMTP credentials before proceeding!"
    read -p "Press Enter after updating the .env file..."
fi

print_status "Installing OTP service dependencies..."
npm install

print_status "Deploying OTP service to Vercel..."
OTP_URL=$(vercel --prod 2>&1 | grep -o 'https://[^ ]*\.vercel\.app')

if [ -z "$OTP_URL" ]; then
    print_error "Failed to get OTP service URL from deployment!"
    exit 1
fi

print_success "OTP Service deployed successfully!"
print_success "OTP Service URL: $OTP_URL"

cd ..

# Update Flutter app with OTP service URL
print_status "Updating Flutter app with OTP service URL..."
sed -i.bak "s|https://noor-otp-service.vercel.app|$OTP_URL|g" noor_flutter/lib/services/otp_service.dart
rm noor_flutter/lib/services/otp_service.dart.bak

print_success "Flutter app updated with production OTP URL!"

# Deploy Flutter Web App
print_status "Deploying Flutter Web App..."
cd noor_flutter

print_status "Enabling Flutter web support..."
flutter config --enable-web

print_status "Cleaning previous builds..."
flutter clean

print_status "Getting dependencies..."
flutter pub get

print_status "Building for web..."
flutter build web --release --web-renderer canvaskit

if [ $? -ne 0 ]; then
    print_error "Flutter build failed!"
    exit 1
fi

print_status "Deploying Flutter app to Vercel..."
FLUTTER_URL=$(vercel --prod 2>&1 | grep -o 'https://[^ ]*\.vercel\.app')

if [ -z "$FLUTTER_URL" ]; then
    print_error "Failed to get Flutter app URL from deployment!"
    exit 1
fi

cd ..

# Final summary
echo ""
echo "🎉 DEPLOYMENT COMPLETE!"
echo "========================================"
print_success "OTP Service: $OTP_URL"
print_success "Flutter Web App: $FLUTTER_URL"
echo ""
print_status "Next steps:"
echo "1. Test the OTP functionality by visiting: $FLUTTER_URL"
echo "2. Try the signup process to ensure emails are sent"
echo "3. Check Vercel dashboard for any errors or logs"
echo "4. Update your domain DNS if you want custom domains"
echo ""
print_warning "Important: Keep your SMTP credentials secure!"
print_warning "Monitor your email usage to avoid hitting limits."
