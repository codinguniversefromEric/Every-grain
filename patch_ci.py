with open(".github/workflows/flutter_ci.yml", "r", encoding="utf-8") as f:
    lines = f.readlines()

new_lines = []
skip = False
for line in lines:
    if line.startswith("  push:"):
        skip = True
        continue
    if skip and "branches:" in line:
        skip = False
        continue
    new_lines.append(line)

with open(".github/workflows/flutter_ci.yml", "w", encoding="utf-8") as f:
    f.writelines(new_lines)
