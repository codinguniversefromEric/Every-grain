with open("lib/widgets/micro_simulation_overlay.dart", "r", encoding="utf-8") as f:
    content = f.read()
content = content.replace("const Padding(\n              padding: EdgeInsets.all(32.0),", "Padding(\n              padding: const EdgeInsets.all(32.0),")
content = content.replace("child: const Center(\n        child: Text(", "child: Center(\n        child: Text(")
# Also remove string interpolation
content = content.replace('"${AppLocalizations.of(context)!.microSimInstruction}"', 'AppLocalizations.of(context)!.microSimInstruction')
content = content.replace('"${AppLocalizations.of(context)!.microSimCompleted}"', 'AppLocalizations.of(context)!.microSimCompleted')

with open("lib/widgets/micro_simulation_overlay.dart", "w", encoding="utf-8") as f:
    f.write(content)
