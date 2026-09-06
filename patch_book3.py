with open("lib/widgets/book_modal.dart", "r", encoding="utf-8") as f:
    content = f.read()

content = content.replace("final angle = -openProgress * pi;", "final angle = openProgress * pi;")
content = content.replace("final isCoverVisible = angle >= -pi / 2;", "final isCoverVisible = angle <= pi / 2;")

with open("lib/widgets/book_modal.dart", "w", encoding="utf-8") as f:
    f.write(content)
