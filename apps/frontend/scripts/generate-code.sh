#!/bin/bash

# Code Generation Script for Flutter TENX
# This script generates all freezed and JSON serialization files

echo "🧹 Cleaning previous generated files..."
flutter pub run build_runner clean

echo "📦 Getting dependencies..."
flutter pub get

echo "🔨 Generating code..."
flutter pub run build_runner build --delete-conflicting-outputs

echo "✅ Code generation complete!"
echo ""
echo "Generated files:"
echo "  - *.freezed.dart (Freezed classes for events/states/entities)"
echo "  - *.g.dart (JSON serialization for DTOs)"
echo ""
echo "You can now run the app with: flutter run"

