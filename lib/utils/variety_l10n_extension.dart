import 'package:flutter/widgets.dart';
import '../models/rice_variety.dart';
import '../l10n/app_localizations.dart';

extension RiceVarietyL10n on RiceVariety {
  String localizedName(AppLocalizations loc) {
    switch (id) {
      case 'tainan_11': return loc.varietyTainan11Name;
      case 'taikeng_9': return loc.varietyTaikeng9Name;
      case 'tainung_71': return loc.varietyTainung71Name;
      case 'kaohsiung_139': return loc.varietyKaohsiung139Name;
      case 'taoyuan_3': return loc.varietyTaoyuan3Name;
      case 'taichung_sen_10': return loc.varietyTaichungSen10Name;
      case 'kaohsiung_147': return loc.varietyKaohsiung147Name;
      case 'koshihikari': return loc.varietyKoshihikariName;
      case 'tainung_67': return loc.varietyTainung67Name;
      default: return name;
    }
  }

  String localizedDesc(AppLocalizations loc) {
    switch (id) {
      case 'tainan_11': return loc.varietyTainan11Desc;
      case 'taikeng_9': return loc.varietyTaikeng9Desc;
      case 'tainung_71': return loc.varietyTainung71Desc;
      case 'kaohsiung_139': return loc.varietyKaohsiung139Desc;
      case 'taoyuan_3': return loc.varietyTaoyuan3Desc;
      case 'taichung_sen_10': return loc.varietyTaichungSen10Desc;
      case 'kaohsiung_147': return loc.varietyKaohsiung147Desc;
      case 'koshihikari': return loc.varietyKoshihikariDesc;
      case 'tainung_67': return loc.varietyTainung67Desc;
      default: return description;
    }
  }

  String localizedFact(AppLocalizations loc) {
    switch (id) {
      case 'tainan_11': return loc.varietyTainan11Fact;
      case 'taikeng_9': return loc.varietyTaikeng9Fact;
      case 'tainung_71': return loc.varietyTainung71Fact;
      case 'kaohsiung_139': return loc.varietyKaohsiung139Fact;
      case 'taoyuan_3': return loc.varietyTaoyuan3Fact;
      case 'taichung_sen_10': return loc.varietyTaichungSen10Fact;
      case 'kaohsiung_147': return loc.varietyKaohsiung147Fact;
      case 'koshihikari': return loc.varietyKoshihikariFact;
      case 'tainung_67': return loc.varietyTainung67Fact;
      default: return funFact;
    }
  }
}

extension VarietyTariDataL10n on VarietyTariData {
  String localizedParents(AppLocalizations loc, RiceVariety variety) {
    switch (variety.id) {
      case 'tainan_11': return loc.varietyTainan11Parents;
      case 'taikeng_9': return loc.varietyTaikeng9Parents;
      case 'tainung_71': return loc.varietyTainung71Parents;
      case 'kaohsiung_139': return loc.varietyKaohsiung139Parents;
      case 'taoyuan_3': return loc.varietyTaoyuan3Parents;
      case 'taichung_sen_10': return loc.varietyTaichungSen10Parents;
      case 'kaohsiung_147': return loc.varietyKaohsiung147Parents;
      case 'koshihikari': return loc.varietyKoshihikariParents;
      case 'tainung_67': return loc.varietyTainung67Parents;
      default: return crossParents;
    }
  }

  String localizedBlast(AppLocalizations loc, RiceVariety variety) {
    switch (variety.id) {
      case 'tainan_11': return loc.varietyTainan11Blast;
      case 'taikeng_9': return loc.varietyTaikeng9Blast;
      case 'tainung_71': return loc.varietyTainung71Blast;
      case 'kaohsiung_139': return loc.varietyKaohsiung139Blast;
      case 'taoyuan_3': return loc.varietyTaoyuan3Blast;
      case 'taichung_sen_10': return loc.varietyTaichungSen10Blast;
      case 'kaohsiung_147': return loc.varietyKaohsiung147Blast;
      case 'koshihikari': return loc.varietyKoshihikariBlast;
      case 'tainung_67': return loc.varietyTainung67Blast;
      default: return blastResistance;
    }
  }

  String localizedGrainType(AppLocalizations loc, RiceVariety variety) {
    switch (variety.id) {
      case 'tainan_11': return loc.varietyTainan11Grain;
      case 'taikeng_9': return loc.varietyTaikeng9Grain;
      case 'tainung_71': return loc.varietyTainung71Grain;
      case 'kaohsiung_139': return loc.varietyKaohsiung139Grain;
      case 'taoyuan_3': return loc.varietyTaoyuan3Grain;
      case 'taichung_sen_10': return loc.varietyTaichungSen10Grain;
      case 'kaohsiung_147': return loc.varietyKaohsiung147Grain;
      case 'koshihikari': return loc.varietyKoshihikariGrain;
      case 'tainung_67': return loc.varietyTainung67Grain;
      default: return grainType;
    }
  }
}
