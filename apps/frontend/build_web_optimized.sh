#!/bin/bash

# Flutter Web Optimized Build Script
# This script builds the Flutter web app with all performance optimizations enabled

set -e

echo "🚀 Building Flutter Web App with Performance Optimizations..."

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    exit 1
fi

# Get Flutter version
FLUTTER_VERSION=$(flutter --version | head -n 1)
echo "${BLUE}Using: $FLUTTER_VERSION${NC}"

# Clean previous build
echo "${BLUE}Cleaning previous build...${NC}"
flutter clean

# Get dependencies
echo "${BLUE}Getting dependencies...${NC}"
flutter pub get

# Build for web with optimizations
echo "${BLUE}Building web app with optimizations...${NC}"
flutter build web \
    --release \
    --web-renderer canvaskit \
    --tree-shake-icons \
    --no-sound-null-safety \
    --base-href "/"

# Check build result
if [ $? -eq 0 ]; then
    echo "${GREEN}✅ Build completed successfully!${NC}"
    echo "${BLUE}Build output: build/web/${NC}"
    
    # Show build size
    echo "${BLUE}Build size:${NC}"
    du -sh build/web
    
    # Show main bundle size
    if [ -f "build/web/main.dart.js" ]; then
        MAIN_SIZE=$(du -h build/web/main.dart.js | cut -f1)
        echo "${BLUE}main.dart.js size: $MAIN_SIZE${NC}"
    fi
    
    echo "${GREEN}🎉 Your optimized Flutter web app is ready!${NC}"
else
    echo "❌ Build failed. Please check the errors above."
    exit 1
fi
