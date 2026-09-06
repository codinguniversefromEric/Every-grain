with open("lib/widgets/book_modal.dart", "r", encoding="utf-8") as f:
    content = f.read()

# Fix perspective inversion by negating the perspective coefficient or angle.
# Usually standard is 0.001, if it's backward, we make it -0.001.
content = content.replace("..setEntry(3, 2, 0.001)", "..setEntry(3, 2, 0.002)")
content = content.replace("final angle = -openProgress * pi;", "final angle = openProgress * pi; // Flip open left with positive angle")
content = content.replace("final isCoverVisible = angle >= -pi / 2;", "final isCoverVisible = angle <= pi / 2;")

with open("lib/widgets/book_modal.dart", "w", encoding="utf-8") as f:
    f.write(content)
