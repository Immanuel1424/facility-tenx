#!/bin/bash

# Run both backend and frontend development servers
# Make sure Node.js is in your PATH (restart terminal or run: export PATH="/usr/local/bin:$PATH")

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$SCRIPT_DIR/apps/backend"
FRONTEND_DIR="$SCRIPT_DIR/apps/frontend"

echo "🚀 Starting TENX Development Environment"
echo "================================================"
echo ""

# Check Node.js
if ! command -v node &> /dev/null; then
    echo "❌ Node.js not found. Please install Node.js or add it to PATH:"
    echo "   export PATH=\"/usr/local/bin:\$PATH\""
    echo "   Or restart your terminal"
    exit 1
fi

# Check npm
if ! command -v npm &> /dev/null; then
    echo "❌ npm not found. Please add Node.js to PATH:"
    echo "   export PATH=\"/usr/local/bin:\$PATH\""
    echo "   Or restart your terminal"
    exit 1
fi

# Check Flutter
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter not found. Please install Flutter first."
    exit 1
fi

echo "✅ Prerequisites check passed"
echo ""

# Install backend dependencies if needed
if [ ! -d "$BACKEND_DIR/node_modules" ]; then
    echo "📦 Installing backend dependencies..."
    cd "$BACKEND_DIR"
    npm install
fi

# Install frontend dependencies if needed
if [ ! -d "$FRONTEND_DIR/.dart_tool" ]; then
    echo "📦 Installing frontend dependencies..."
    cd "$FRONTEND_DIR"
    flutter pub get
fi

# Function to cleanup on exit
cleanup() {
    echo ""
    echo "🛑 Shutting down servers..."
    kill $BACKEND_PID $FRONTEND_PID 2>/dev/null || true
    exit
}

trap cleanup SIGINT SIGTERM

# Start backend
echo "🔧 Starting backend server on http://localhost:3000..."
cd "$BACKEND_DIR"
npm run start:dev &
BACKEND_PID=$!

# Wait for backend to start
echo "⏳ Waiting for backend to start..."
sleep 5

# Start frontend
echo "📱 Starting frontend app..."
cd "$FRONTEND_DIR"
flutter run -d macos --dart-define=API_BASE_URL=http://localhost:3000/api/v1 &
FRONTEND_PID=$!

echo ""
echo "✅ Both servers are running!"
echo ""
echo "   Backend API: http://localhost:3000/api/v1"
echo "   Swagger Docs: http://localhost:3000/api/docs"
echo "   Frontend: macOS app launching"
echo ""
echo "Press Ctrl+C to stop both servers"

# Wait for both processes
wait $BACKEND_PID $FRONTEND_PID

