#!/usr/bin/env python3
"""
Generate favicon.png from design specifications.
Creates a helpdesk-themed favicon with TENX branding.
"""

import os
import sys

try:
    from PIL import Image, ImageDraw, ImageFont
except ImportError:
    print("Error: PIL (Pillow) is required. Install with: pip install Pillow")
    sys.exit(1)

# Configuration
SIZE = 64
BG_COLOR = "#007be5"  # Primary brand color
TEXT_COLOR = "#FFFFFF"
OUTPUT_DIR = os.path.join(os.path.dirname(__file__), "..", "web")
OUTPUT_FILE = os.path.join(OUTPUT_DIR, "favicon.png")

def hex_to_rgb(hex_color):
    """Convert hex color to RGB tuple."""
    hex_color = hex_color.lstrip('#')
    return tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))

def create_favicon():
    """Create the favicon image."""
    # Create image with transparent background initially
    img = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    bg_rgb = hex_to_rgb(BG_COLOR)
    text_rgb = hex_to_rgb(TEXT_COLOR)
    
    # Draw rounded rectangle background
    corner_radius = 12
    # Draw main rectangle
    draw.rectangle([corner_radius, 0, SIZE - corner_radius, SIZE], fill=bg_rgb)
    draw.rectangle([0, corner_radius, SIZE, SIZE - corner_radius], fill=bg_rgb)
    # Draw corner circles
    draw.ellipse([0, 0, corner_radius * 2, corner_radius * 2], fill=bg_rgb)
    draw.ellipse([SIZE - corner_radius * 2, 0, SIZE, corner_radius * 2], fill=bg_rgb)
    draw.ellipse([0, SIZE - corner_radius * 2, corner_radius * 2, SIZE], fill=bg_rgb)
    draw.ellipse([SIZE - corner_radius * 2, SIZE - corner_radius * 2, SIZE, SIZE], fill=bg_rgb)
    
    # Draw helpdesk ticket icon (simplified)
    ticket_y = 20
    ticket_width = 28
    ticket_height = 20
    ticket_x = (SIZE - ticket_width) // 2
    
    # Ticket body
    draw.rounded_rectangle(
        [ticket_x, ticket_y, ticket_x + ticket_width, ticket_y + ticket_height],
        radius=3,
        fill=text_rgb
    )
    
    # Ticket perforations
    perf_y = ticket_y + ticket_height // 2
    draw.ellipse([ticket_x + 4, perf_y - 2.5, ticket_x + 9, perf_y + 2.5], fill=bg_rgb)
    draw.ellipse([ticket_x + ticket_width - 9, perf_y - 2.5, ticket_x + ticket_width - 4, perf_y + 2.5], fill=bg_rgb)
    
    # Draw TENX text
    try:
        # Try to use a system font
        font_size = 14
        # Try different font paths
        font_paths = [
            "/System/Library/Fonts/Helvetica.ttc",  # macOS
            "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",  # Linux
            "C:/Windows/Fonts/arialbd.ttf",  # Windows
        ]
        font = None
        for path in font_paths:
            if os.path.exists(path):
                try:
                    font = ImageFont.truetype(path, font_size)
                    break
                except:
                    continue
        
        if font is None:
            # Fallback to default font
            font = ImageFont.load_default()
    except:
        font = ImageFont.load_default()
    
    text = "TENX"
    text_bbox = draw.textbbox((0, 0), text, font=font)
    text_width = text_bbox[2] - text_bbox[0]
    text_height = text_bbox[3] - text_bbox[1]
    text_x = (SIZE - text_width) // 2
    text_y = SIZE - text_height - 8
    
    draw.text((text_x, text_y), text, fill=text_rgb, font=font)
    
    # Save the image
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    img.save(OUTPUT_FILE, 'PNG')
    print(f"✅ Generated favicon.png at {OUTPUT_FILE}")

if __name__ == "__main__":
    create_favicon()

