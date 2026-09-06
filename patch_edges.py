import re

with open("lib/visuals/scenery/biome_scenery_layer.dart", "r", encoding="utf-8") as f:
    content = f.read()

# Fix plains
content = content.replace("for (double x = 0; x <= size.width; x += 2)", "for (double x = 0; x <= size.width + 10; x += 2)")

# Fix terraces
content = content.replace("for (double x = 0; x <= size.width; x += 40)", "for (double x = 0; x <= size.width + 40; x += 40)")

# Fix coast
content = content.replace("for (double x = 0; x <= size.width; x += 10)", "for (double x = 0; x <= size.width + 15; x += 10)")

with open("lib/visuals/scenery/biome_scenery_layer.dart", "w", encoding="utf-8") as f:
    f.write(content)

with open("lib/widgets/rice_plant.dart", "r", encoding="utf-8") as f:
    content = f.read()

# Fix water ripples
content = content.replace("for (double x = 0; x < size.width; x += 30)", "for (double x = 0; x <= size.width + 30; x += 30)")

with open("lib/widgets/rice_plant.dart", "w", encoding="utf-8") as f:
    f.write(content)

