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

  /// No description provided for @aboutCraftedWith.
  ///
  /// In zh, this message translates to:
  /// **'在台灣，用 🍚 傾心打造'**
  String get aboutCraftedWith;

  /// No description provided for @testerControlsTitle.
  ///
  /// In zh, this message translates to:
  /// **'測試員工具'**
  String get testerControlsTitle;

  /// No description provided for @testerControlsDesc.
  ///
  /// In zh, this message translates to:
  /// **'快速穿梭時空，體驗完整的稻米旅程。'**
  String get testerControlsDesc;

  /// No description provided for @testerLocationTitle.
  ///
  /// In zh, this message translates to:
  /// **'🇹🇼 1. 台灣 (品種測試)'**
  String get testerLocationTitle;

  /// No description provided for @testerLocationDesc.
  ///
  /// In zh, this message translates to:
  /// **'瞬間移動會自動更新該地區的天氣與在地品種。'**
  String get testerLocationDesc;

  /// No description provided for @testerLocCurrent.
  ///
  /// In zh, this message translates to:
  /// **'📍 回到目前真實位置'**
  String get testerLocCurrent;

  /// No description provided for @testerLocTaipei.
  ///
  /// In zh, this message translates to:
  /// **'📍 台北 (北部 - 台稉9號)'**
  String get testerLocTaipei;

  /// No description provided for @testerLocTaichung.
  ///
  /// In zh, this message translates to:
  /// **'📍 台中 (中部 - 台農71號)'**
  String get testerLocTaichung;

  /// No description provided for @testerLocKaohsiung.
  ///
  /// In zh, this message translates to:
  /// **'📍 高雄 (南部 - 台南11號)'**
  String get testerLocKaohsiung;

  /// No description provided for @testerLocTaitung.
  ///
  /// In zh, this message translates to:
  /// **'📍 台東 (東部 - 高雄139號)'**
  String get testerLocTaitung;

  /// No description provided for @testerGlobalTitle.
  ///
  /// In zh, this message translates to:
  /// **'✈️ 2. 海外 (氣象測試)'**
  String get testerGlobalTitle;

  /// No description provided for @testerLocNewYork.
  ///
  /// In zh, this message translates to:
  /// **'🗽 紐約'**
  String get testerLocNewYork;

  /// No description provided for @testerLocTokyo.
  ///
  /// In zh, this message translates to:
  /// **'🗼 東京'**
  String get testerLocTokyo;

  /// No description provided for @testerLocParis.
  ///
  /// In zh, this message translates to:
  /// **'🥐 巴黎'**
  String get testerLocParis;

  /// No description provided for @testerLocSydney.
  ///
  /// In zh, this message translates to:
  /// **'🦘 雪梨'**
  String get testerLocSydney;

  /// No description provided for @testerLocLondon.
  ///
  /// In zh, this message translates to:
  /// **'💂 倫敦'**
  String get testerLocLondon;

  /// No description provided for @testerLocCairo.
  ///
  /// In zh, this message translates to:
  /// **'🏜️ 開羅'**
  String get testerLocCairo;

  /// No description provided for @testerLocRio.
  ///
  /// In zh, this message translates to:
  /// **'💃 里約'**
  String get testerLocRio;

  /// No description provided for @testerTimeTitle.
  ///
  /// In zh, this message translates to:
  /// **'⏳ 3. 時間'**
  String get testerTimeTitle;

  /// No description provided for @testerNextMonth.
  ///
  /// In zh, this message translates to:
  /// **'快轉一個月'**
  String get testerNextMonth;

  /// No description provided for @testerToNight.
  ///
  /// In zh, this message translates to:
  /// **'切換至夜晚'**
  String get testerToNight;

  /// No description provided for @testerToDay.
  ///
  /// In zh, this message translates to:
  /// **'切換至白天'**
  String get testerToDay;

  /// No description provided for @testerEventsTitle.
  ///
  /// In zh, this message translates to:
  /// **'⛈️ 4. 事件與天氣'**
  String get testerEventsTitle;

  /// No description provided for @testerForceHarvest.
  ///
  /// In zh, this message translates to:
  /// **'強制進入收割期'**
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
