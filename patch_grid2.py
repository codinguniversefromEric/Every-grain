import re

with open("lib/visuals/collection/collection_grid.dart", "r", encoding="utf-8") as f:
    content = f.read()

content = content.replace("Widget _buildFront() {", "Widget _buildFront() {\n    final loc = AppLocalizations.of(context)!;")
content = content.replace("Widget _buildBack() {\n    final data = widget.variety.tariData;", "Widget _buildBack() {\n    final loc = AppLocalizations.of(context)!;\n    final data = widget.variety.tariData;")

with open("lib/visuals/collection/collection_grid.dart", "w", encoding="utf-8") as f:
    f.write(content)
