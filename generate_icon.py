"""
Generate app icon for Catatan Keuangan (Financial Notes) Flutter app.
Uses Instagram logo style: icon with text below.
"""
from PIL import Image, ImageDraw, ImageFont, ImageFilter
import math

# Icon size (1024x1024 for high quality, will be resized)
SIZE = 1024
RADIUS = 160  # corner radius for the background

def create_icon():
    # === LAYER 1: Background with gradient ===
    bg = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(bg)

    # Green gradient background (dark emerald to bright green)
    for y in range(SIZE):
        ratio = y / SIZE
        # Gradient from #1B5E20 (dark green) at top to #00C853 (bright green) at bottom
        r = int(27 + (0 - 27) * ratio)
        g = int(94 + (200 - 94) * ratio)
        b = int(32 + (83 - 32) * ratio)
        draw.line([(0, y), (SIZE, y)], fill=(r, g, b, 255))

    # === LAYER 2: Subtle radial glow in center ===
    for i in range(80, 0, -1):
        alpha = int(15 * (1 - i / 80))
        draw.ellipse(
            [(SIZE//2 - i*6, SIZE//2 - i*6), (SIZE//2 + i*6, SIZE//2 + i*6)],
            fill=(255, 255, 255, alpha)
        )

    # === LAYER 3: Main icon element - stylized wallet/ledger book ===
    cx, cy = SIZE // 2, SIZE // 2 - 40

    # Book/wallet body (rounded rectangle)
    book_w, book_h = 500, 380
    book_x0 = cx - book_w // 2
    book_y0 = cy - book_h // 2
    book_x1 = cx + book_w // 2
    book_y1 = cy + book_h // 2

    # Draw rounded rect for book
    _rounded_rect(draw, [book_x0, book_y0, book_x1, book_y1], 40, fill=(255, 255, 255, 240))

    # Book spine (left side)
    draw.rectangle([book_x0, book_y0, book_x0 + 60, book_y1], fill=(220, 220, 220, 240))

    # Lines on book (ledger lines)
    line_spacing = 36
    line_start = book_x0 + 90
    line_end = book_x1 - 30
    for i in range(7):
        ly = book_y0 + 70 + i * line_spacing
        draw.line([(line_start, ly), (line_end, ly)], fill=(200, 200, 200, 200), width=3)

    # === LAYER 4: Currency symbol overlay (Rupiah) ===
    # Draw a circle badge with Rp symbol
    badge_r = 110
    badge_cx = cx + 160
    badge_cy = cy - 50

    # Badge circle with shadow
    _rounded_circle(draw, badge_cx, badge_cy, badge_r + 6, fill=(0, 0, 0, 60))
    _rounded_circle(draw, badge_cx, badge_cy, badge_r, fill=(255, 215, 0, 255))  # Gold

    # Inner circle border
    _rounded_circle(draw, badge_cx, badge_cy, badge_r - 6, fill=(255, 235, 59, 255))

    # Draw "Rp" text on badge
    try:
        font_badge = ImageFont.truetype("arialbd.ttf", 72)
    except:
        font_badge = ImageFont.load_default()

    draw.text((badge_cx, badge_cy), "Rp", fill=(27, 94, 32, 255), font=font_badge, anchor="mm")

    # === LAYER 5: Coin stack ===
    coin_y = cy + 110
    for i in range(3):
        cy_coin = coin_y - i * 22
        _ellipse_filled(draw, cx - 160, cy_coin, cx - 100, cy_coin + 18, fill=(255, 193, 7, 255 - i*30))
        draw.ellipse([cx - 160, cy_coin, cx - 100, cy_coin + 18], outline=(200, 160, 0, 255), width=2)

    # === LAYER 6: Pen/pencil ===
    pen_x0, pen_y0 = book_x1 - 40, book_y0 - 30
    pen_x1, pen_y1 = book_x1 + 20, book_y1 + 30
    _rounded_rect(draw, [pen_x0, pen_y0, pen_x1, pen_y1], 10, fill=(100, 100, 100, 255))

    # === LAYER 7: Text "CATATAN KEUANGAN" at bottom ===
    text_y = SIZE - 130

    # Text background pill
    _rounded_rect(draw, [80, text_y - 30, SIZE - 80, text_y + 70], 35, fill=(0, 0, 0, 100))

    # Main text
    try:
        font_title = ImageFont.truetype("arialbd.ttf", 64)
        font_subtitle = ImageFont.truetype("arial.ttf", 36)
    except:
        font_title = ImageFont.load_default()
        font_subtitle = ImageFont.load_default()

    # Draw text with white color
    draw.text((SIZE // 2, text_y + 5), "CATATAN", fill=(255, 255, 255, 255), font=font_title, anchor="mm")
    draw.text((SIZE // 2, text_y + 55), "KEUANGAN", fill=(255, 255, 255, 255), font=font_title, anchor="mm")

    # === LAYER 8: Top text "Rp" watermark ===
    draw.text((SIZE // 2, 80), "Rp", fill=(255, 255, 255, 40), font=ImageFont.load_default(size=80), anchor="mm")

    # === FINAL: Round corners to make it circular/rounded icon ===
    # Mask with circle for app icon shape
    mask = Image.new('L', (SIZE, SIZE), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.ellipse([0, 0, SIZE, SIZE], fill=255)

    # Apply rounded corner overlay
    result = bg.copy()
    result.paste(bg, (0, 0), mask)

    return result

def _rounded_rect(draw, coords, radius, fill=None, outline=None, width=1):
    x0, y0, x1, y1 = coords
    draw.rounded_rectangle(coords, radius, fill=fill, outline=outline, width=width)

def _rounded_circle(draw, cx, cy, radius, fill=None, outline=None, width=1):
    draw.ellipse([cx - radius, cy - radius, cx + radius, cy + radius], fill=fill, outline=outline, width=width)

def _ellipse_filled(draw, x0, y0, x1, y1, fill):
    draw.ellipse([x0, y0, x1, y1], fill=fill)

def main():
    print("Generating Catatan Keuangan app icon...")
    icon = create_icon()

    # Save in multiple sizes for Flutter launcher icons
    output_dir = "assets/icon"

    # Create sizes directory
    import os
    os.makedirs(output_dir, exist_ok=True)

    # Save master (1024x1024)
    icon.save(f"{output_dir}/icon_1024.png")
    print(f"  [OK] Saved {output_dir}/icon_1024.png")

    # Save adaptive icon foreground (same as master)
    os.makedirs(f"{output_dir}/android", exist_ok=True)
    icon.save(f"{output_dir}/android/icon_foreground.png")
    print(f"  [OK] Saved {output_dir}/android/icon_foreground.png")

    # Generate adaptive icon background (solid green gradient simplified to solid)
    bg_img = Image.new('RGBA', (SIZE, SIZE), (27, 94, 32, 255))
    bg_img.save(f"{output_dir}/android/icon_background.png")
    print(f"  [OK] Saved {output_dir}/android/icon_background.png")

    # Also save a preview at smaller size
    preview = icon.resize((256, 256), Image.LANCZOS)
    preview.save(f"{output_dir}/icon_preview.png")
    print(f"  [OK] Saved {output_dir}/icon_preview.png")

    print(f"\nIcon generated successfully! Files in: {output_dir}/")
    print("Next: Add to pubspec.yaml and run: flutter pub run flutter_launcher_icons")

if __name__ == "__main__":
    main()
