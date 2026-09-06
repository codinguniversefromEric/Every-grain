with open("lib/widgets/book_modal.dart", "r", encoding="utf-8") as f:
    content = f.read()

# Revert angle back to negative so it swings towards the user
content = content.replace("final angle = openProgress * pi; // Flip open left with positive angle", "final angle = -openProgress * pi;")
content = content.replace("final isCoverVisible = angle <= pi / 2;", "final isCoverVisible = angle >= -pi / 2;")

# The standard Flutter perspective is 0.001, but if it feels backward (shrinks when coming towards you), we change the sign!
content = content.replace("..setEntry(3, 2, 0.002)", "..setEntry(3, 2, 0.0015)")

with open("lib/widgets/book_modal.dart", "w", encoding="utf-8") as f:
    f.write(content)
