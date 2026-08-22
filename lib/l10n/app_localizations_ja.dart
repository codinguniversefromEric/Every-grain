// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => '粒粒皆辛苦';

  @override
  String get swipeToHarvest => '右にスワイプして収穫';

  @override
  String get developerControls => 'Developer Controls';

  @override
  String get aboutUs => 'アプリについて';

  @override
  String get virtualFieldNotice => 'バーチャル台湾農地モード（台東・池上）';

  @override
  String get weatherClear => '晴れ';

  @override
  String get weatherCloudy => '曇り';

  @override
  String get weatherRainy => '雨';

  @override
  String get weatherStormy => '雷雨';

  @override
  String get stageSeedling => '春の種まき：どんな新しい始まりを期待していますか？';

  @override
  String get stageTillering => '成長の分げつ：今日はどんな努力をしましたか？';

  @override
  String get stageHeading => '出穂の時期：今、何が実を結ぼうとしていますか？';

  @override
  String get stageRipening => '豊穣の成熟：今日、感謝したいことは何ですか？';

  @override
  String get stageFallow => '冬の休耕：心を落ち着かせ、今日はゆっくり休めましたか？';

  @override
  String get seasonFirstCrop => '一期作';

  @override
  String get seasonSecondCrop => '二期作';

  @override
  String get seasonWinterFallow => '休耕期';

  @override
  String get harvestDialogMessage => '一株の苗が、時間と人の寄り添いを経て、\n最後には一杯のご飯になります。';

  @override
  String get harvestDialogReplant => 'もう一度種をまく';

  @override
  String get varietyKnowledgeCardPrefix => '品種図鑑：';

  @override
  String get varietyTainan11Name => '台南11号';

  @override
  String get varietyTainan11Desc =>
      '台湾で最も栽培面積が広く、高い収量を誇る品種。もちもちとした食感で、冷めても風味が損なわれません。';

  @override
  String get varietyTainan11Fact =>
      '豆知識：台湾国内のお弁当チェーン店の多くがこの品種を使用しており、台湾の「国民のお米」とも呼ばれています。';

  @override
  String get varietyKaohsiung139Name => '高雄139号 (醜美人)';

  @override
  String get varietyKaohsiung139Desc =>
      '東部の美しい水と土壌で育まれる品種。見た目は少し白っぽいですが、食感は極めて優れています。';

  @override
  String get varietyKaohsiung139Fact =>
      '豆知識：見た目は良くないですが非常に美味しいため、農家からは「醜美人」と呼ばれています。日本の市場にも輸出されています。';

  @override
  String get varietyTainung71Name => '台農71号（益全香米）';

  @override
  String get varietyTainung71Desc => '炊き上がるとタロイモのような独特の香りが漂う、台湾中部の有名な香り高いお米。';

  @override
  String get varietyTainung71Fact =>
      '豆知識：「益全」という名は、この品種の開発に生涯を捧げ、発表の直前に過労で亡くなった郭益全博士を記念して付けられました。';

  @override
  String get varietyTaikeng9Name => '台稉9号';

  @override
  String get varietyTaikeng9Desc =>
      '北部でよく見られる高品質な品種。冷めても硬くなりにくく、高級おにぎりや寿司に最適です。';

  @override
  String get varietyTaikeng9Fact =>
      '豆知識：冷めても硬くなりにくい特性から、多くの大手コンビニのおにぎりに指定されています。';

  @override
  String get aboutTitle => '一粒の米\nRice Journey';

  @override
  String get aboutSubtitle => 'これは農業ゲームではありません。\n時間、食、そして大地を再発見するための静かな時間です。';

  @override
  String get aboutDataSourceTitle => 'データソースと謝辞';

  @override
  String get aboutDataWeatherTitle => '⛅️ リアルタイム気象データ';

  @override
  String get aboutDataWeatherDesc =>
      '台湾交通部中央気象署 (CWA)\nグローバル気象データ提供: Open-Meteo.com';

  @override
  String get aboutDataRiceTitle => '🌾 台湾の稲品種データ';

  @override
  String get aboutDataRiceDesc => '農業部各区農業改良場 (TARI) および台湾米食推進資料';

  @override
  String get aboutOpenSourceTitle => 'オープンソース';

  @override
  String get aboutOpenSourceDesc =>
      'このプロジェクトは完全無料でオープンソースです。コードの閲覧、学習、貢献をいつでも歓迎します。';

  @override
  String get aboutGithubButton => '💻 GitHubでプロジェクトを見る';

  @override
  String get aboutCraftedWith => '台湾で 🍚 と共に作られました';

  @override
  String get testerControlsTitle => 'テストツール';

  @override
  String get testerControlsDesc => '時空を超えて、稲の旅を体験しましょう。';

  @override
  String get testerLocationTitle => '🇹🇼 1. 台湾 (品種テスト)';

  @override
  String get testerLocationDesc => 'テレポートすると、その地域の天候と品種が自動的に更新されます。';

  @override
  String get testerLocCurrent => '📍 現在地に戻る';

  @override
  String get testerLocTaipei => '📍 台北 (北部 - 台稉9号)';

  @override
  String get testerLocTaichung => '📍 台中 (中部 - 台農71号)';

  @override
  String get testerLocKaohsiung => '📍 高雄 (南部 - 台南11号)';

  @override
  String get testerLocTaitung => '📍 台東 (東部 - 高雄139号)';

  @override
  String get testerGlobalTitle => '✈️ 2. 海外 (気象テスト)';

  @override
  String get testerLocNewYork => '🗽 ニューヨーク';

  @override
  String get testerLocTokyo => '🗼 東京';

  @override
  String get testerLocParis => '🥐 パリ';

  @override
  String get testerLocSydney => '🦘 シドニー';

  @override
  String get testerLocLondon => '💂 ロンドン';

  @override
  String get testerLocCairo => '🏜️ カイロ';

  @override
  String get testerLocRio => '💃 リオ';

  @override
  String get testerTimeTitle => '⏳ 3. 時間';

  @override
  String get testerNextMonth => '次の月へ';

  @override
  String get testerToNight => '夜へ';

  @override
  String get testerToDay => '昼へ';

  @override
  String get testerEventsTitle => '⛈️ 4. イベントと天気';

  @override
  String get testerForceHarvest => '強制的に収穫期へ';

  @override
  String get languageName => '言語 / Language';

  @override
  String get languageSystem => 'システム設定に従う';
}
