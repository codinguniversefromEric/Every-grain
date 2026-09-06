import re

with open("lib/visuals/collection/collection_grid.dart", "r", encoding="utf-8") as f:
    content = f.read()

# Change padding from 8.0 to 4.0
content = content.replace("padding: const EdgeInsets.all(8.0),", "padding: const EdgeInsets.all(4.0),")

# Change padding inside rows from 2.0 to 1.0
content = content.replace("padding: const EdgeInsets.symmetric(vertical: 2.0),", "padding: const EdgeInsets.symmetric(vertical: 1.0),")

# Wrap the Column in an Expanded/FittedBox?
# Actually, the grid is 0.75 aspect ratio. Let's make it 0.7 to give it more height.
content = content.replace("childAspectRatio: 0.75, // slightly taller for back text", "childAspectRatio: 0.70, // slightly taller for back text")

with open("lib/visuals/collection/collection_grid.dart", "w", encoding="utf-8") as f:
    f.write(content)
