import sys
from PIL import Image

def make_transparent(input_path, output_path):
    img = Image.open(input_path).convert("RGBA")
    datas = img.getdata()

    new_data = []
    # The generated image background is off-white/beige. 
    # We will convert any pixel that is very bright/close to white into a transparent pixel.
    for item in datas:
        # Check if the pixel is bright (background)
        # R, G, B > 200 is a safe threshold for a light background
        if item[0] > 200 and item[1] > 200 and item[2] > 200:
            new_data.append((255, 255, 255, 0)) # Fully transparent
        else:
            new_data.append(item)

    img.putdata(new_data)
    img.save(output_path, "PNG")
    print(f"Saved {output_path}")

if __name__ == "__main__":
    make_transparent("assets/icon.jpg", "assets/icon_foreground.png")
