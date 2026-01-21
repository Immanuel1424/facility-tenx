#!/bin/bash

# Flutter Installation Script for macOS

set -e

echo "🚀 Flutter Installation Script"
echo "================================"
echo ""

# Check if Flutter is already installed
if command -v flutter &> /dev/null; then
    echo "✅ Flutter is already installed!"
    flutter --version
    exit 0
fi

# Detect installation method preference
INSTALL_METHOD=${1:-homebrew}

if [ "$INSTALL_METHOD" = "homebrew" ]; then
    echo "📦 Installing Flutter using Homebrew..."
    
    # Check if Homebrew is installed
    if ! command -v brew &> /dev/null; then
        echo "❌ Homebrew is not installed. Installing Homebrew first..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    
    brew install --cask flutter
    
    echo ""
    echo "✅ Flutter installed via Homebrew!"
    
elif [ "$INSTALL_METHOD" = "manual" ]; then
    echo "📦 Installing Flutter manually..."
    
    cd ~
    
    # Check if Flutter directory already exists
    if [ -d "flutter" ]; then
        echo "⚠️  Flutter directory already exists. Skipping clone..."
    else
        echo "📥 Cloning Flutter repository..."
        git clone https://github.com/flutter/flutter.git -b stable
    fi
    
    # Add to PATH
    FLUTTER_PATH="$HOME/flutter/bin"
    SHELL_RC=""
    
    if [ -f "$HOME/.zshrc" ]; then
        SHELL_RC="$HOME/.zshrc"
    elif [ -f "$HOME/.bash_profile" ]; then
        SHELL_RC="$HOME/.bash_profile"
    elif [ -f "$HOME/.bashrc" ]; then
        SHELL_RC="$HOME/.bashrc"
    fi
    
    if [ -n "$SHELL_RC" ]; then
        if ! grep -q "flutter/bin" "$SHELL_RC"; then
            echo "" >> "$SHELL_RC"
            echo "# Flutter SDK" >> "$SHELL_RC"
            echo "export PATH=\"\$HOME/flutter/bin:\$PATH\"" >> "$SHELL_RC"
            echo "✅ Added Flutter to $SHELL_RC"
        else
            echo "✅ Flutter already in PATH"
        fi
        
        echo "📝 Please run: source $SHELL_RC"
    else
        echo "⚠️  Could not find shell RC file. Please add Flutter to PATH manually:"
        echo "   export PATH=\"\$HOME/flutter/bin:\$PATH\""
    fi
    
    echo ""
    echo "✅ Flutter cloned to ~/flutter"
    echo "📝 Please run: source $SHELL_RC (or restart your terminal)"
fi

echo ""
echo "🔍 Running Flutter doctor..."
export PATH="$HOME/flutter/bin:$PATH" 2>/dev/null || true
flutter doctor

echo ""
echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "1. If PATH was updated, restart your terminal or run: source ~/.zshrc"
echo "2. Run: cd apps/frontend && flutter pub get"
echo "3. Run: flutter pub run build_runner build --delete-conflicting-outputs"
echo "4. Run: flutter run"

