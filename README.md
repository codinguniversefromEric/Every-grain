# 粒粒皆辛苦 (Rice Journey)

[🇹🇼 繁體中文](README.md) | [🇺🇸 English](README_en.md) | [🇯🇵 日本語](README_ja.md)

「一年一田、一季一冊」—— 這是一個真實、安靜、陪伴的台灣在地水稻文化 App。沒有廣告，沒有體力值，只有隨時間與真實天氣變化的稻田。  
[![Buy Me A Boba](https://img.shields.io/badge/Donate-請我喝珍奶-CCA78C?style=for-the-badge&logo=coffeescript&logoColor=white)](https://codinguniversefromeric.bobaboba.me)
[![TestFlight](https://img.shields.io/badge/iOS-TestFlight_Beta-0070c9?style=for-the-badge&logo=apple&logoColor=white)](https://testflight.apple.com/join/MpNSu2c8)
[![Android](https://img.shields.io/badge/Android-Coming_Soon-3DDC84?style=for-the-badge&logo=android&logoColor=white)](#)

## 技術棧 (Tech Stack)

- **Framework**: Flutter
- **State Management**: 原生 `setState` + `ChangeNotifier` (於 `StateManager` 協調)
- **多語系 (i18n)**: 全面採用 `.arb` 檔案架構 (如 `app_zh.arb`, `app_en.arb`, `app_ja.arb`) 進行語系隔離與多國語言支援。
- **硬體與外部服務**:
  - `geolocator`: 獲取定位以判斷南北部節氣與品種
  - `just_audio`: 環境音效播放 (結合連續性動態音量與隨機 One-Shot 觸發)
  - **天氣 API**: 雙軌制自動切換（台灣境內使用 CWA Open Data，海外使用 Open-Meteo），具備全域快取與靜默降級保護。

## 特色亮點 (Highlights)

1. **本地日照運算 (Solar Calculator)**
   無須依賴額外的日出日落 API，完全透過本機的 GPS 座標與真實時間，利用純數學運算求出精確的太陽仰角。天空漸層與環境光影會隨著真實時間一分一秒**無縫且平滑地**漸變，且陰雨天會自動觸發真實的暗沉覆蓋。

2. **零版權疑慮的程式化音效 (Procedural Audio)**
   為確保專案 100% 開源自由度並徹底杜絕版權疑慮，應用內使用的特殊音效（如水滴聲、遠處悶雷）皆非使用任何有版權的素材庫，而是直接透過自製的 Python 腳本（利用指數衰減、頻率下沈與低通濾波白噪音）**純數學合成產生**。

## 專案架構 (Architecture)

本專案採用職責分離的架構，確保高可維護性與效能：

```mermaid
graph TD
    A["main.dart (UI 組裝)"] --> B[StateManager]
    B --> C[WeatherService]
    B --> E[AmbientSoundService]
    B --> F[AgriculturalCalendar]
    B --> G[VarietyService]
    A --> H[Visual Layers]
    H --> I["LivingSky, Clouds, Rain, etc."]
    A --> J["RicePlant Layer"]
```

- **`lib/services/`**: 純業務邏輯與 API 串接，不依賴 UI。包含狀態管理、天氣、定位、節氣計算與環境音。
- **`lib/visuals/`**: 獨立的視覺圖層，每個檔案負責一種天氣或大氣現象，如水紋、螢火蟲、雲朵等。
- **`lib/theme/`**: 集中式的設計系統，管理顏色 (`app_colors.dart`)、常數 (`animation_constants.dart`) 與字串 (`strings.dart`)。
- **`lib/widgets/`**: 可重用的 UI 元件。
- **`lib/models/`**: 不可變的資料模型與列舉。

## 開發環境與編譯指令

本專案已實作完善的氣象 API 雙軌制與防呆機制，可直接執行而無需配置額外的金鑰。

### 執行開發版 (Debug)
```bash
flutter run
```
*(在開發模式下，如果沒有提供 CWA API Key，天氣模組會自動靜默改用open-meteo)*

### 執行測試 (Tests)
專案內含 `services/` 層的單元測試。
```bash
flutter test
```

### 程式碼品質與 Linter
```bash
flutter analyze
```

## 開發者控制面板 (Developer Controls)

在開發模式 (`kDebugMode`) 下，畫面右上角會出現隱藏的扳手圖示。點擊可開啟控制面板，進行：
- 任意切換稻作生長階段
- 改變日夜時段與天氣
- 模擬位置（瞬間移動）

此功能在 `flutter build ios` (Release) 打包時會自動從 UI 樹中移除。
