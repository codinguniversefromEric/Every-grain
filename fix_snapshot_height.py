with open("lib/widgets/widget_scenery_snapshot.dart", "r", encoding="utf-8") as f:
    content = f.read()

# Replace the Container height which was accidentally set to 200 back to 400
content = content.replace("width: 400,\n        height: 200,", "width: 400,\n        height: 400,")

# Plant height is 200, but we also want it to look good in 400x400
# Plant height is fine at 200 inside 400x400.

with open("lib/widgets/widget_scenery_snapshot.dart", "w", encoding="utf-8") as f:
    f.write(content)
