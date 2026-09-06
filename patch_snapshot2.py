with open("lib/widgets/widget_scenery_snapshot.dart", "r", encoding="utf-8") as f:
    content = f.read()

content = content.replace("import '../visuals/biome_scenery_layer.dart';", "import '../visuals/scenery/biome_scenery_layer.dart';")
content = content.replace("state.isDaytime", "state.dayPeriod != DayPhase.night")
content = content.replace("state.variety", "state.currentVariety")
content = content.replace("""BiomeSceneryLayer(
              isDaytime: state.dayPeriod != DayPhase.night,
              weatherCondition: state.weatherCondition,
            )""", """BiomeSceneryLayer(
              biome: state.currentBiome,
              dayPhase: state.dayPeriod,
            )""")

with open("lib/widgets/widget_scenery_snapshot.dart", "w", encoding="utf-8") as f:
    f.write(content)
