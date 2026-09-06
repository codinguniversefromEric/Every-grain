import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In zh, this message translates to:
  /// **'粒粒皆辛苦'**
  String get appTitle;

  /// No description provided for @swipeToHarvest.
  ///
  /// In zh, this message translates to:
  /// **'向右滑動來收割'**
  String get swipeToHarvest;

  /// No description provided for @developerControls.
  ///
  /// In zh, this message translates to:
  /// **'Developer Controls'**
  String get developerControls;

  /// No description provided for @aboutUs.
  ///
  /// In zh, this message translates to:
  /// **'關於與開源'**
  String get aboutUs;

  /// No description provided for @virtualFieldNotice.
  ///
  /// In zh, this message translates to:
  /// **'虛擬台灣農田模式 (台東池上)'**
  String get virtualFieldNotice;

  /// No description provided for @weatherClear.
  ///
  /// In zh, this message translates to:
  /// **'晴'**
  String get weatherClear;

  /// No description provided for @weatherCloudy.
  ///
  /// In zh, this message translates to:
  /// **'多雲/陰'**
  String get weatherCloudy;

  /// No description provided for @weatherRainy.
  ///
  /// In zh, this message translates to:
  /// **'雨'**
  String get weatherRainy;

  /// No description provided for @weatherStormy.
  ///
  /// In zh, this message translates to:
  /// **'雷雨'**
  String get weatherStormy;

  /// No description provided for @stageSeedling.
  ///
  /// In zh, this message translates to:
  /// **'春天播種：有什麼新的開始值得期待？'**
  String get stageSeedling;

  /// No description provided for @stageTillering.
  ///
  /// In zh, this message translates to:
  /// **'成長分蘖：今天付出了什麼努力？'**
  String get stageTillering;

  /// No description provided for @stageHeading.
  ///
  /// In zh, this message translates to:
  /// **'抽穗孕育：什麼事情正在開花結果？'**
  String get stageHeading;

  /// No description provided for @stageRipening.
  ///
  /// In zh, this message translates to:
  /// **'豐收成熟：今天，有什麼值得好好感謝？'**
  String get stageRipening;

  /// No description provided for @stageFallow.
  ///
  /// In zh, this message translates to:
  /// **'冬日休耕：讓心沉澱，今天好好休息了嗎？'**
  String get stageFallow;

  /// No description provided for @seasonFirstCrop.
  ///
  /// In zh, this message translates to:
  /// **'一期作'**
  String get seasonFirstCrop;

  /// No description provided for @seasonSecondCrop.
  ///
  /// In zh, this message translates to:
  /// **'二期作'**
  String get seasonSecondCrop;

  /// No description provided for @seasonWinterFallow.
  ///
  /// In zh, this message translates to:
  /// **'休耕期'**
  String get seasonWinterFallow;

  /// No description provided for @harvestDialogMessage.
  ///
  /// In zh, this message translates to:
  /// **'一株秧苗，經過時間與人的陪伴\n最後成為一碗飯。'**
  String get harvestDialogMessage;

  /// No description provided for @harvestDialogReplant.
  ///
  /// In zh, this message translates to:
  /// **'重新播種'**
  String get harvestDialogReplant;

  /// No description provided for @varietyKnowledgeCardPrefix.
  ///
  /// In zh, this message translates to:
  /// **'在地品種知識卡：'**
  String get varietyKnowledgeCardPrefix;

  /// No description provided for @varietyTainan11Name.
  ///
  /// In zh, this message translates to:
  /// **'台南 11 號'**
  String get varietyTainan11Name;

  /// No description provided for @varietyTainan11Desc.
  ///
  /// In zh, this message translates to:
  /// **'全台產量最大、適應性最強的「全民天菜」。米粒飽滿、產量高，是台灣最常見的白米品種。'**
  String get varietyTainan11Desc;

  /// No description provided for @varietyTainan11Fact.
  ///
  /// In zh, this message translates to:
  /// **'知識卡：台南11號的抗病蟲害能力極強，不僅在台灣南部廣泛種植，甚至還曾外銷到日本，是真正的「台灣之光」！'**
  String get varietyTainan11Fact;

  /// No description provided for @varietyKaohsiung139Name.
  ///
  /// In zh, this message translates to:
  /// **'高雄 139 號 (醜美人)'**
  String get varietyKaohsiung139Name;

  /// No description provided for @varietyKaohsiung139Desc.
  ///
  /// In zh, this message translates to:
  /// **'花東地區的主力品種。雖然米粒心腹白較多，外觀不如其他品種晶瑩剔透，但吃起來口感極佳。'**
  String get varietyKaohsiung139Desc;

  /// No description provided for @varietyKaohsiung139Fact.
  ///
  /// In zh, this message translates to:
  /// **'知識卡：外表不美麗卻極度美味，因此被農民暱稱為「醜美人」。多虧了東部的好水與較長的生長期，造就了它的絕佳風味。'**
  String get varietyKaohsiung139Fact;

  /// No description provided for @varietyTainung71Name.
  ///
  /// In zh, this message translates to:
  /// **'台農 71 號 (益全香米)'**
  String get varietyTainung71Name;

  /// No description provided for @varietyTainung71Desc.
  ///
  /// In zh, this message translates to:
  /// **'台灣中部名米，烹煮時會散發出濃郁的芋頭香氣。米粒短圓飽滿，口感黏彈。'**
  String get varietyTainung71Desc;

  /// No description provided for @varietyTainung71Fact.
  ///
  /// In zh, this message translates to:
  /// **'知識卡：「益全」二字是為了紀念畢生奉獻於此品種研發，卻在品種發表前夕因過勞辭世的郭益全博士。'**
  String get varietyTainung71Fact;

  /// No description provided for @varietyTaikeng9Name.
  ///
  /// In zh, this message translates to:
  /// **'台稉 9 號'**
  String get varietyTaikeng9Name;

  /// No description provided for @varietyTaikeng9Desc.
  ///
  /// In zh, this message translates to:
  /// **'北部常見的優質品種，即使放冷了依然Q彈好吃，是製作頂級御飯糰與壽司的首選。'**
  String get varietyTaikeng9Desc;

  /// No description provided for @varietyTaikeng9Fact.
  ///
  /// In zh, this message translates to:
  /// **'知識卡：因為其冷卻後不易變硬的特性，許多知名連鎖超商的飯糰都是指定使用台稉9號喔！'**
  String get varietyTaikeng9Fact;

  /// No description provided for @aboutTitle.
  ///
  /// In zh, this message translates to:
  /// **'粒粒皆辛苦\nRice Journey'**
  String get aboutTitle;

  /// No description provided for @aboutSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'這不是教人種田的遊戲，\n而是一個重新感受時間、食物與土地的陪伴。'**
  String get aboutSubtitle;

  /// No description provided for @aboutDataSourceTitle.
  ///
  /// In zh, this message translates to:
  /// **'資料來源與鳴謝'**
  String get aboutDataSourceTitle;

  /// No description provided for @aboutDataWeatherTitle.
  ///
  /// In zh, this message translates to:
  /// **'⛅️ 即時氣象連動資料'**
  String get aboutDataWeatherTitle;

  /// No description provided for @aboutDataWeatherDesc.
  ///
  /// In zh, this message translates to:
  /// **'台灣交通部中央氣象署 (CWA)\n全球氣象資料由 Open-Meteo.com 提供'**
  String get aboutDataWeatherDesc;

  /// No description provided for @aboutDataRiceTitle.
  ///
  /// In zh, this message translates to:
  /// **'🌾 在地稻米品種知識'**
  String get aboutDataRiceTitle;

  /// No description provided for @aboutDataRiceDesc.
  ///
  /// In zh, this message translates to:
  /// **'農業部各區農業改良場 (TARI) 及台灣米食推廣資料'**
  String get aboutDataRiceDesc;

  /// No description provided for @aboutOpenSourceTitle.
  ///
  /// In zh, this message translates to:
  /// **'開源與程式碼'**
  String get aboutOpenSourceTitle;

  /// No description provided for @aboutOpenSourceDesc.
  ///
  /// In zh, this message translates to:
  /// **'本專案為完全免費之開源軟體，您可以隨時檢視、學習或貢獻程式碼。'**
  String get aboutOpenSourceDesc;

  /// No description provided for @aboutGithubButton.
  ///
  /// In zh, this message translates to:
  /// **'💻 前往 GitHub 檢視專案'**
  String get aboutGithubButton;

  /// No description provided for @aboutRateButton.
  ///
  /// In zh, this message translates to:
  /// **'⭐ 給予評價 (Rate this App)'**
  String get aboutRateButton;

  /// No description provided for @aboutCraftedWith.
  ///
  /// In zh, this message translates to:
  /// **'在台灣，用 🍚 傾心打造'**
  String get aboutCraftedWith;

  /// No description provided for @testerControlsTitle.
  ///
  /// In zh, this message translates to:
  /// **'測試員工具 (DevTools)'**
  String get testerControlsTitle;

  /// No description provided for @testerControlsDesc.
  ///
  /// In zh, this message translates to:
  /// **'快速穿梭時空，體驗完整的稻米旅程 (Time travel & testing).'**
  String get testerControlsDesc;

  /// No description provided for @testerLocationTitle.
  ///
  /// In zh, this message translates to:
  /// **'🇹🇼 1. 台灣 (Location & Varieties)'**
  String get testerLocationTitle;

  /// No description provided for @testerLocationDesc.
  ///
  /// In zh, this message translates to:
  /// **'瞬間移動會自動更新該地區的天氣與在地品種 (Updates local weather and variety).'**
  String get testerLocationDesc;

  /// No description provided for @testerLocCurrent.
  ///
  /// In zh, this message translates to:
  /// **'📍 回到目前真實位置 (Reset to Real Location)'**
  String get testerLocCurrent;

  /// No description provided for @testerLocTaipei.
  ///
  /// In zh, this message translates to:
  /// **'📍 台北 Taipei (北部 - 台稉9號)'**
  String get testerLocTaipei;

  /// No description provided for @testerLocTaichung.
  ///
  /// In zh, this message translates to:
  /// **'📍 台中 Taichung (中部 - 台中秈10號/台農71號)'**
  String get testerLocTaichung;

  /// No description provided for @testerLocKaohsiung.
  ///
  /// In zh, this message translates to:
  /// **'📍 高雄 Kaohsiung (南部 - 高雄147號)'**
  String get testerLocKaohsiung;

  /// No description provided for @testerLocTaitung.
  ///
  /// In zh, this message translates to:
  /// **'📍 花東 Hualien/Taitung (東部 - 高雄139號)'**
  String get testerLocTaitung;

  /// No description provided for @testerGlobalTitle.
  ///
  /// In zh, this message translates to:
  /// **'✈️ 2. 海外 (Global Weather)'**
  String get testerGlobalTitle;

  /// No description provided for @testerLocNewYork.
  ///
  /// In zh, this message translates to:
  /// **'🗽 紐約 New York'**
  String get testerLocNewYork;

  /// No description provided for @testerLocTokyo.
  ///
  /// In zh, this message translates to:
  /// **'🗼 東京 Tokyo'**
  String get testerLocTokyo;

  /// No description provided for @testerLocParis.
  ///
  /// In zh, this message translates to:
  /// **'🥐 巴黎 Paris'**
  String get testerLocParis;

  /// No description provided for @testerLocSydney.
  ///
  /// In zh, this message translates to:
  /// **'🦘 雪梨 Sydney'**
  String get testerLocSydney;

  /// No description provided for @testerLocLondon.
  ///
  /// In zh, this message translates to:
  /// **'💂 倫敦 London'**
  String get testerLocLondon;

  /// No description provided for @testerLocCairo.
  ///
  /// In zh, this message translates to:
  /// **'🏜️ 開羅 Cairo'**
  String get testerLocCairo;

  /// No description provided for @testerLocRio.
  ///
  /// In zh, this message translates to:
  /// **'💃 里約 Rio'**
  String get testerLocRio;

  /// No description provided for @testerTimeTitle.
  ///
  /// In zh, this message translates to:
  /// **'⏳ 3. 時間 (Time Control)'**
  String get testerTimeTitle;

  /// No description provided for @testerNextMonth.
  ///
  /// In zh, this message translates to:
  /// **'快轉一個月 (Fast Forward 1 Month)'**
  String get testerNextMonth;

  /// No description provided for @testerToNight.
  ///
  /// In zh, this message translates to:
  /// **'切換至夜晚 (Switch to Night)'**
  String get testerToNight;

  /// No description provided for @testerToDay.
  ///
  /// In zh, this message translates to:
  /// **'切換至白天 (Switch to Day)'**
  String get testerToDay;

  /// No description provided for @testerEventsTitle.
  ///
  /// In zh, this message translates to:
  /// **'⛈️ 4. 事件與天氣 (Events & Weather)'**
  String get testerEventsTitle;

  /// No description provided for @testerForceHarvest.
  ///
  /// In zh, this message translates to:
  /// **'強制進入收割期 (Force Harvest)'**
  String get testerForceHarvest;

  /// No description provided for @languageName.
  ///
  /// In zh, this message translates to:
  /// **'Language / 語言'**
  String get languageName;

  /// No description provided for @languageSystem.
  ///
  /// In zh, this message translates to:
  /// **'System Default / 跟隨系統'**
  String get languageSystem;

  /// No description provided for @testerLocTaoyuan.
  ///
  /// In zh, this message translates to:
  /// **'📍 桃園 Taoyuan (北部 - 桃園3號)'**
  String get testerLocTaoyuan;

  /// No description provided for @testerLocTainan.
  ///
  /// In zh, this message translates to:
  /// **'📍 台南 Tainan (南部 - 台南11號)'**
  String get testerLocTainan;

  /// No description provided for @testerLocYilan.
  ///
  /// In zh, this message translates to:
  /// **'📍 宜蘭 Yilan (東部 - 越光米)'**
  String get testerLocYilan;

  /// No description provided for @collectionTitle.
  ///
  /// In zh, this message translates to:
  /// **'台灣米護照'**
  String get collectionTitle;

  /// No description provided for @collectionTooltip.
  ///
  /// In zh, this message translates to:
  /// **'圖鑑 (Collection)'**
  String get collectionTooltip;

  /// No description provided for @collectionSourceText.
  ///
  /// In zh, this message translates to:
  /// **'學術數據授權 / 資料來源：\n農業部農業試驗所 (TARI) - 水稻品種資訊系統'**
  String get collectionSourceText;

  /// No description provided for @journalTitle.
  ///
  /// In zh, this message translates to:
  /// **'農事日誌'**
  String get journalTitle;

  /// No description provided for @journalTooltip.
  ///
  /// In zh, this message translates to:
  /// **'日誌 (Journal)'**
  String get journalTooltip;

  /// No description provided for @journalGrandpaTitle.
  ///
  /// In zh, this message translates to:
  /// **'阿公的信'**
  String get journalGrandpaTitle;

  /// No description provided for @journalGrandpaContent.
  ///
  /// In zh, this message translates to:
  /// **'孩子，歡迎來到這片田。\n\n這裡不需要你每天辛苦登入除草，也不需要你花錢買肥料。\n你只需要偶爾看著它，聽聽風聲、聽聽蟲鳴。\n\n每一粒米都是時間的餽贈。去感受這片土地的呼吸吧。'**
  String get journalGrandpaContent;

  /// No description provided for @journalGrandpaButton.
  ///
  /// In zh, this message translates to:
  /// **'我明白了'**
  String get journalGrandpaButton;

  /// No description provided for @journalDeadTitle.
  ///
  /// In zh, this message translates to:
  /// **'天有不測風雲'**
  String get journalDeadTitle;

  /// No description provided for @journalDeadContent.
  ///
  /// In zh, this message translates to:
  /// **'極端的氣候讓植物枯萎了。\n\n這就是務農的無奈，大自然有它自己的脾氣。\n我們只能認命翻土，等待下個節氣到來，重新來過。'**
  String get journalDeadContent;

  /// No description provided for @journalDeadButton.
  ///
  /// In zh, this message translates to:
  /// **'認命翻土'**
  String get journalDeadButton;

  /// No description provided for @journalNothingContent.
  ///
  /// In zh, this message translates to:
  /// **'今天田裡沒什麼特別的事，稻子正安靜地生長著。\n\n「看天田，隨遇而安。」'**
  String get journalNothingContent;

  /// No description provided for @journalPrayButton.
  ///
  /// In zh, this message translates to:
  /// **'氣象局報錯了，去向土地公抱怨'**
  String get journalPrayButton;

  /// No description provided for @journalCloseButton.
  ///
  /// In zh, this message translates to:
  /// **'關閉'**
  String get journalCloseButton;

  /// No description provided for @journalFallowTitle.
  ///
  /// In zh, this message translates to:
  /// **'休養生息'**
  String get journalFallowTitle;

  /// No description provided for @journalFallowContent.
  ///
  /// In zh, this message translates to:
  /// **'田地正在休養生息。\n我們靜待下一個節氣到來，再重新播種。'**
  String get journalFallowContent;

  /// No description provided for @devControlTeleportReset.
  ///
  /// In zh, this message translates to:
  /// **'恢復真實定位'**
  String get devControlTeleportReset;

  /// No description provided for @devControlTeleportResetDesc.
  ///
  /// In zh, this message translates to:
  /// **'您目前正在模擬其他地區，氣象與品種已強制鎖定'**
  String get devControlTeleportResetDesc;

  /// No description provided for @bwaTitle.
  ///
  /// In zh, this message translates to:
  /// **'田邊土地公廟'**
  String get bwaTitle;

  /// No description provided for @bwaDesc.
  ///
  /// In zh, this message translates to:
  /// **'你帶著一炷香，走到田埂邊的土地公廟，祈求風調雨順。\n\n(點擊下方擲筊)'**
  String get bwaDesc;

  /// No description provided for @bwaButton.
  ///
  /// In zh, this message translates to:
  /// **'擲筊'**
  String get bwaButton;

  /// No description provided for @bwaClose.
  ///
  /// In zh, this message translates to:
  /// **'離開'**
  String get bwaClose;

  /// No description provided for @bwaResultHoly.
  ///
  /// In zh, this message translates to:
  /// **'聖筊！\n\n土地公聽到了你的祈求。\n天氣已為您修正為晴天。'**
  String get bwaResultHoly;

  /// No description provided for @bwaResultLaughing.
  ///
  /// In zh, this message translates to:
  /// **'笑筊。\n\n土地公笑了笑，沒有答應。\n或許大自然有它的安排吧。'**
  String get bwaResultLaughing;

  /// No description provided for @bwaResultNegative.
  ///
  /// In zh, this message translates to:
  /// **'陰筊。\n\n土地公認為現在這樣最好。\n請順應天意。'**
  String get bwaResultNegative;

  /// No description provided for @tariGrowthDays.
  ///
  /// In zh, this message translates to:
  /// **'日數'**
  String get tariGrowthDays;

  /// No description provided for @tariWeight.
  ///
  /// In zh, this message translates to:
  /// **'千粒重'**
  String get tariWeight;

  /// No description provided for @tariType.
  ///
  /// In zh, this message translates to:
  /// **'型態'**
  String get tariType;

  /// No description provided for @tariBlast.
  ///
  /// In zh, this message translates to:
  /// **'稻熱病'**
  String get tariBlast;

  /// No description provided for @tariParents.
  ///
  /// In zh, this message translates to:
  /// **'親本'**
  String get tariParents;

  /// No description provided for @varietyTainan11Parents.
  ///
  /// In zh, this message translates to:
  /// **'嘉農育811221 / 台稉7號'**
  String get varietyTainan11Parents;

  /// No description provided for @varietyTainan11Blast.
  ///
  /// In zh, this message translates to:
  /// **'中抗'**
  String get varietyTainan11Blast;

  /// No description provided for @varietyTainan11Grain.
  ///
  /// In zh, this message translates to:
  /// **'稉米'**
  String get varietyTainan11Grain;

  /// No description provided for @varietyTaikeng9Parents.
  ///
  /// In zh, this message translates to:
  /// **'北育29號 / 台農67號'**
  String get varietyTaikeng9Parents;

  /// No description provided for @varietyTaikeng9Blast.
  ///
  /// In zh, this message translates to:
  /// **'中抗'**
  String get varietyTaikeng9Blast;

  /// No description provided for @varietyTaikeng9Grain.
  ///
  /// In zh, this message translates to:
  /// **'稉米'**
  String get varietyTaikeng9Grain;

  /// No description provided for @varietyTainung71Parents.
  ///
  /// In zh, this message translates to:
  /// **'絹光 / 台稉4號'**
  String get varietyTainung71Parents;

  /// No description provided for @varietyTainung71Blast.
  ///
  /// In zh, this message translates to:
  /// **'中感'**
  String get varietyTainung71Blast;

  /// No description provided for @varietyTainung71Grain.
  ///
  /// In zh, this message translates to:
  /// **'稉米'**
  String get varietyTainung71Grain;

  /// No description provided for @varietyKaohsiung139Parents.
  ///
  /// In zh, this message translates to:
  /// **'屏東9號 / 臺中65號'**
  String get varietyKaohsiung139Parents;

  /// No description provided for @varietyKaohsiung139Blast.
  ///
  /// In zh, this message translates to:
  /// **'極感'**
  String get varietyKaohsiung139Blast;

  /// No description provided for @varietyKaohsiung139Grain.
  ///
  /// In zh, this message translates to:
  /// **'稉米'**
  String get varietyKaohsiung139Grain;

  /// No description provided for @varietyTaichungSen10Name.
  ///
  /// In zh, this message translates to:
  /// **'台中秈 10 號'**
  String get varietyTaichungSen10Name;

  /// No description provided for @varietyTaichungSen10Desc.
  ///
  /// In zh, this message translates to:
  /// **'台灣產量最大、也是最好吃的「秈米」(長米)。高纖低澱粉，口感鬆軟不黏。'**
  String get varietyTaichungSen10Desc;

  /// No description provided for @varietyTaichungSen10Fact.
  ///
  /// In zh, this message translates to:
  /// **'知識卡：打破了長米「乾硬」的刻板印象，是米粉與蘿蔔糕的頂級原料，深受中部農民喜愛。'**
  String get varietyTaichungSen10Fact;

  /// No description provided for @varietyTaichungSen10Parents.
  ///
  /// In zh, this message translates to:
  /// **'IR 24 / Chianung-Sen 8'**
  String get varietyTaichungSen10Parents;

  /// No description provided for @varietyTaichungSen10Blast.
  ///
  /// In zh, this message translates to:
  /// **'抗'**
  String get varietyTaichungSen10Blast;

  /// No description provided for @varietyTaichungSen10Grain.
  ///
  /// In zh, this message translates to:
  /// **'秈米'**
  String get varietyTaichungSen10Grain;

  /// No description provided for @varietyKoshihikariName.
  ///
  /// In zh, this message translates to:
  /// **'越光米 (Koshihikari)'**
  String get varietyKoshihikariName;

  /// No description provided for @varietyKoshihikariDesc.
  ///
  /// In zh, this message translates to:
  /// **'來自日本的超級名種。米粒晶瑩剔透，黏性強，口感無與倫比，但極難照顧。'**
  String get varietyKoshihikariDesc;

  /// No description provided for @varietyKoshihikariFact.
  ///
  /// In zh, this message translates to:
  /// **'知識卡：原本只適合高緯度氣候，後來引進台灣後，發現在氣候涼爽、水質純淨的蘭陽平原也能種出頂級的越光米！'**
  String get varietyKoshihikariFact;

  /// No description provided for @varietyKoshihikariParents.
  ///
  /// In zh, this message translates to:
  /// **'農林22號 / 農林1號'**
  String get varietyKoshihikariParents;

  /// No description provided for @varietyKoshihikariBlast.
  ///
  /// In zh, this message translates to:
  /// **'極感'**
  String get varietyKoshihikariBlast;

  /// No description provided for @varietyKoshihikariGrain.
  ///
  /// In zh, this message translates to:
  /// **'稉米'**
  String get varietyKoshihikariGrain;

  /// No description provided for @varietyTaoyuan3Name.
  ///
  /// In zh, this message translates to:
  /// **'桃園 3 號 (新香米)'**
  String get varietyTaoyuan3Name;

  /// No description provided for @varietyTaoyuan3Desc.
  ///
  /// In zh, this message translates to:
  /// **'北部著名的香米品種，散發淡淡的爆米花香與芋香。穀粒大且飽滿。'**
  String get varietyTaoyuan3Desc;

  /// No description provided for @varietyTaoyuan3Fact.
  ///
  /// In zh, this message translates to:
  /// **'知識卡：為桃竹地區的代表性品種，由於其耐寒性極佳，非常適應北部秋冬的濕冷氣候。'**
  String get varietyTaoyuan3Fact;

  /// No description provided for @varietyTaoyuan3Parents.
  ///
  /// In zh, this message translates to:
  /// **'台稉4號 / 台稉2號'**
  String get varietyTaoyuan3Parents;

  /// No description provided for @varietyTaoyuan3Blast.
  ///
  /// In zh, this message translates to:
  /// **'感'**
  String get varietyTaoyuan3Blast;

  /// No description provided for @varietyTaoyuan3Grain.
  ///
  /// In zh, this message translates to:
  /// **'稉米'**
  String get varietyTaoyuan3Grain;

  /// No description provided for @varietyKaohsiung147Name.
  ///
  /// In zh, this message translates to:
  /// **'高雄 147 號 (香鑽)'**
  String get varietyKaohsiung147Name;

  /// No description provided for @varietyKaohsiung147Desc.
  ///
  /// In zh, this message translates to:
  /// **'南部新興的冠軍香米。擁有獨特的淡雅芋香與光澤，入口甘甜，連年在比賽中奪冠。'**
  String get varietyKaohsiung147Desc;

  /// No description provided for @varietyKaohsiung147Fact.
  ///
  /// In zh, this message translates to:
  /// **'知識卡：專為高屏地區炎熱氣候培育，它的出現讓南台灣有了屬於自己驕傲的頂級香米。'**
  String get varietyKaohsiung147Fact;

  /// No description provided for @varietyKaohsiung147Parents.
  ///
  /// In zh, this message translates to:
  /// **'高雄145號 / 台農74號'**
  String get varietyKaohsiung147Parents;

  /// No description provided for @varietyKaohsiung147Blast.
  ///
  /// In zh, this message translates to:
  /// **'中感'**
  String get varietyKaohsiung147Blast;

  /// No description provided for @varietyKaohsiung147Grain.
  ///
  /// In zh, this message translates to:
  /// **'稉米'**
  String get varietyKaohsiung147Grain;

  /// No description provided for @varietyTainung67Name.
  ///
  /// In zh, this message translates to:
  /// **'台農 67 號'**
  String get varietyTainung67Name;

  /// No description provided for @varietyTainung67Desc.
  ///
  /// In zh, this message translates to:
  /// **'曾經統治台灣稻田的傳奇品種！適應力極強、產量極高，是 1980 年代台灣農村的共同記憶。'**
  String get varietyTainung67Desc;

  /// No description provided for @varietyTainung67Fact.
  ///
  /// In zh, this message translates to:
  /// **'知識卡：雖然現在已經因為食味品質不如新品種而逐漸被淘汰，但它強悍的生命力曾拯救了無數農家的生計。'**
  String get varietyTainung67Fact;

  /// No description provided for @varietyTainung67Parents.
  ///
  /// In zh, this message translates to:
  /// **'嘉農242號 / 台南5號'**
  String get varietyTainung67Parents;

  /// No description provided for @varietyTainung67Blast.
  ///
  /// In zh, this message translates to:
  /// **'抗'**
  String get varietyTainung67Blast;

  /// No description provided for @varietyTainung67Grain.
  ///
  /// In zh, this message translates to:
  /// **'稉米'**
  String get varietyTainung67Grain;

  /// No description provided for @microSimInstruction.
  ///
  /// In zh, this message translates to:
  /// **'請在發光處插下秧苗\n(點擊光點)'**
  String get microSimInstruction;

  /// No description provided for @microSimCompleted.
  ///
  /// In zh, this message translates to:
  /// **'今日農事已畢\n田水正好\n去忙你的吧。'**
  String get microSimCompleted;

  /// No description provided for @journalPlantingTitle.
  ///
  /// In zh, this message translates to:
  /// **'今日農事：插秧'**
  String get journalPlantingTitle;

  /// No description provided for @journalPlantingContent.
  ///
  /// In zh, this message translates to:
  /// **'田水正好，是時候把秧苗插下去了。\n雖然辛苦，但這是一切的開始。'**
  String get journalPlantingContent;

  /// No description provided for @journalPlantingButton.
  ///
  /// In zh, this message translates to:
  /// **'去田裡看看'**
  String get journalPlantingButton;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
