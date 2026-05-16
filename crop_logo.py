from PIL import Image, ImageChops

def trim_white_bg(im):
    # Convert image to RGB to handle alpha gracefully if any
    bg = Image.new('RGB', im.size, (255, 255, 255))
    diff = ImageChops.difference(im.convert('RGB'), bg)
    diff = ImageChops.add(diff, diff, 2.0, -100)
    bbox = diff.getbbox()
    if bbox:
        return im.crop(bbox)
    return im

def main():
    path = "logo.png"
    out_path = "assets/icon/icon_1024.png"
    out_fg_path = "assets/icon/android/icon_foreground.png"
    
    # Backup original just in case
    import shutil
    if os.path.exists(path):
        shutil.copy(path, "logo_backup.png")
    
    im = Image.open(path).convert("RGBA")
    cropped = trim_white_bg(im)
    
    # Calculate new square size allowing 10% padding
    w, h = cropped.size
    max_dim = max(w, h)
    
    # For Adaptive icons, the safe zone is inner 66%. 
    # We will make the canvas large enough so the cropped image fills ~65% of it.
    canvas_size = int(max_dim / 0.65)
    
    # Create transparent canvas
    # Actually, the user might expect it to replace white bg with transparent, but let's just make the canvas transparent
    canvas = Image.new('RGBA', (canvas_size, canvas_size), (255, 255, 255, 0))
    
    # paste in center
    offset = ((canvas_size - w) // 2, (canvas_size - h) // 2)
    canvas.paste(cropped, offset)
    
    # Resize to 1024x1024 for optimization
    canvas = canvas.resize((1024, 1024), Image.Resampling.LANCZOS)
    
    canvas.save(path)
    canvas.save(out_path)
    canvas.save(out_fg_path)
    
    print("Cropped logo.png and updated assets.")

if __name__ == '__main__':
    import os
    main()
