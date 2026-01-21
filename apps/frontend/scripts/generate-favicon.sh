#!/bin/bash
# Script to generate favicon.png from favicon.svg
# Requires: Inkscape or ImageMagick

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WEB_DIR="$SCRIPT_DIR/../web"
SVG_FILE="$WEB_DIR/favicon.svg"
PNG_FILE="$WEB_DIR/favicon.png"

if [ ! -f "$SVG_FILE" ]; then
    echo "Error: $SVG_FILE not found"
    exit 1
fi

# Try Inkscape first (preferred for SVG)
if command -v inkscape &> /dev/null; then
    echo "Using Inkscape to generate favicon.png..."
    inkscape "$SVG_FILE" --export-filename="$PNG_FILE" --export-width=64 --export-height=64
    echo "✅ Generated $PNG_FILE"
# Fallback to ImageMagick
elif command -v convert &> /dev/null; then
    echo "Using ImageMagick to generate favicon.png..."
    convert -background none -resize 64x64 "$SVG_FILE" "$PNG_FILE"
    echo "✅ Generated $PNG_FILE"
# Fallback to rsvg-convert (librsvg)
elif command -v rsvg-convert &> /dev/null; then
    echo "Using rsvg-convert to generate favicon.png..."
    rsvg-convert -w 64 -h 64 "$SVG_FILE" -o "$PNG_FILE"
    echo "✅ Generated $PNG_FILE"
else
    echo "Error: No SVG converter found. Please install one of:"
    echo "  - Inkscape: brew install inkscape (macOS) or apt-get install inkscape (Linux)"
    echo "  - ImageMagick: brew install imagemagick (macOS) or apt-get install imagemagick (Linux)"
    echo "  - librsvg: brew install librsvg (macOS) or apt-get install librsvg2-bin (Linux)"
    echo ""
    echo "Alternatively, you can use an online tool like:"
    echo "  https://convertio.co/svg-png/"
    echo "  https://cloudconvert.com/svg-to-png"
    exit 1
fi

