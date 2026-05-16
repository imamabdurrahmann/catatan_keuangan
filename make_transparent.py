import os
from PIL import Image, ImageDraw

def trim_and_transparent(im):
    # Convert to RGBA
    im = im.convert("RGBA")
    
    # 1. Trim the extra white background first
    bg = Image.new('RGB', im.size, (255, 255, 255))
    diff = Image.frombytes('RGB', im.size, bytes(a ^ b for a, b in zip(im.convert('RGB').tobytes(), bg.tobytes())))
    bbox = diff.getbbox()
    if bbox:
        im = im.crop(bbox)

    # 2. Make exterior white transparent
    # We do this by flood-filling the corners with transparency
    # Then paste the result
    
    # Create a mask for flood fill
    # We'll use a tolerance approach
    datas = im.getdata()
    new_data = []
    
    # Simple thresholding for white (e.g. > 240)
    # But floodfill is safer to keep interior white.
    # Instead of manual floodfill, we can just replace pure white (or near white) with transparent.
    # We'll replace pixels where r > 240, g > 240, b > 240 with transparent 0 alpha.
    for item in datas:
        if item[0] > 245 and item[1] > 245 and item[2] > 245:
            new_data.append((255, 255, 255, 0))
        else:
            new_data.append(item)
            
    im.putdata(new_data)
    return im

def main():
    # Use the backup file
    path = "logo_backup.png"
    out_path = "assets/icon/icon_1024.png"
    out_fg_path = "assets/icon/android/icon_foreground.png"
    
    if not os.path.exists(path):
        print("Backup not found, using logo.png")
        path = "logo.png"
        
    im = Image.open(path)
    cropped = trim_and_transparent(im)
    
    w, h = cropped.size
    max_dim = max(w, h)
    
    # Scale to fill ~60% of the canvas so it perfectly aligns with Android 66% safe zone
    canvas_size = int(max_dim / 0.60)
    
    canvas = Image.new('RGBA', (canvas_size, canvas_size), (255, 255, 255, 0))
    offset = ((canvas_size - w) // 2, (canvas_size - h) // 2)
    canvas.paste(cropped, offset, cropped)
    
    canvas = canvas.resize((1024, 1024), Image.Resampling.LANCZOS)
    
    canvas.save(out_path, "PNG")
    canvas.save(out_fg_path, "PNG")
    print("Done generating transparent icon.")

if __name__ == '__main__':
    main()
