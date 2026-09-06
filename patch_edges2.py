import re

with open("lib/visuals/scenery/biome_scenery_layer.dart", "r", encoding="utf-8") as f:
    content = f.read()

# Fix plains path close
content = content.replace("path.lineTo(size.width, size.height);", "path.lineTo(size.width + 50, size.height);")

with open("lib/visuals/scenery/biome_scenery_layer.dart", "w", encoding="utf-8") as f:
    f.write(content)
