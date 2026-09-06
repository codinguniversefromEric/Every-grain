import re

with open("lib/widgets/developer_controls.dart", "r", encoding="utf-8") as f:
    content = f.read()

content = content.replace("final VoidCallback onResetField;", "final VoidCallback onResetField;\n  final VoidCallback onClearWeatherOverride;")
content = content.replace("required this.onResetField,", "required this.onResetField,\n    required this.onClearWeatherOverride,")

clear_btn = """            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey.shade700,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.cloud_off),
              label: const Text('清除天氣覆寫 (Clear Weather Override)'),
              onPressed: () {
                widget.onClearWeatherOverride();
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon("""

content = content.replace("            ElevatedButton.icon(\n              style: ElevatedButton.styleFrom(\n                backgroundColor: const Color(0xFFD4AF37),", clear_btn + "\n              style: ElevatedButton.styleFrom(\n                backgroundColor: const Color(0xFFD4AF37),")

with open("lib/widgets/developer_controls.dart", "w", encoding="utf-8") as f:
    f.write(content)
