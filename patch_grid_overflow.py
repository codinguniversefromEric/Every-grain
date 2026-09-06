with open("lib/visuals/collection/collection_grid.dart", "r", encoding="utf-8") as f:
    content = f.read()

# Change vertical padding from 1.0 to 0.0
content = content.replace("padding: const EdgeInsets.symmetric(vertical: 1.0),", "padding: const EdgeInsets.symmetric(vertical: 0.0),")
# Change fontSize from 10 to 9
content = content.replace("fontSize: 10,", "fontSize: 9,")

with open("lib/visuals/collection/collection_grid.dart", "w", encoding="utf-8") as f:
    f.write(content)
