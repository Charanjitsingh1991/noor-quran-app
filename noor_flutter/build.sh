#!/bin/bash

echo "🚀 Building Noor Flutter Web App for Vercel..."

# Install Flutter (if not already installed)
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    exit 1
fi

# Enable web support
echo "🔧 Enabling Flutter web support..."
flutter config --enable-web

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Build for web
echo "🏗️ Building for web..."
flutter build web --release --web-renderer canvaskit

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "✅ Build completed successfully!"
    echo "📁 Build output: build/web/"
    ls -la build/web/
else
    echo "❌ Build failed!"
    exit 1
fi
