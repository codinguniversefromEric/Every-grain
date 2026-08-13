# Every-grain (Rice Journey) Project Context

## 專案類型與用途
這是一個名為 `rice_journey` 的 Flutter 應用程式，主題是模擬或展示稻米生長過程（Rice Journey App）。
App 會根據各種條件（例如節氣、地點、時間等）來呈現對應的農田狀態與環境音效。

## 技術棧與相依套件 (Tech Stack & Dependencies)
- **Framework**: Flutter
- **狀態管理**: 主要使用原生的 `StatefulWidget` 與 `setState`，沒有引入第三方狀態管理套件（如 Provider / BLoC / Riverpod）。
- **主要外部依賴** (`pubspec.yaml`):
  - `shared_preferences`: 用於儲存使用者的 reflections（心得/紀錄）等本地持久化資料。
  - `geolocator`: 取得使用者位置（推測用於計算台灣南北部的節氣差異等）。
  - `battery_plus`: 取得裝置電量。
  - `just_audio`: 播放環境音效 (Ambient sound)。
  - `google_fonts`: 字體管理。
  - `http`: 處理網路請求，目前用於串接台灣中央氣象署 (CWA) Open Data API 取得真實天氣。

## 專案目錄結構 (Architecture)
- `lib/models/`: 資料模型與列舉。
  - `field_state.dart`: 定義了核心狀態模型 `FieldState`，包含 `GrowthStage` (休耕、秧苗、分蘖、抽穗、成熟、收割)、`TaiwanRegion` (台灣南北部)、`DayPhase` (時段)。
- `lib/services/`: 封裝業務邏輯與硬體/外部 API 的整合。
  - `agricultural_calendar.dart`: 農民曆/節氣與定位相關邏輯。
  - `ambient_sound.dart`: 音效播放邏輯。
- `lib/widgets/`: 可重用的 UI 元件。
  - `rice_plant.dart`: 稻米植物的視覺元件。
  - `harvest_dialog.dart`: 收割時的對話框。
  - `developer_controls.dart`: 開發者除錯控制面板。
- `lib/visuals.dart` & `lib/main.dart`: 主畫面與視覺圖層渲染 (Water Ripple, Dragonfly, Wind Gust 等)。

## 開發規範與習慣 (Development Rules)
1. **條件式渲染除錯 UI (Debug UI)**: 
   - 專案中有專門給開發者使用的控制按鈕與選單（如 Developer Controls）。
   - **重要**：所有只應該在開發階段出現的 UI 元件，必須引入 `package:flutter/foundation.dart`，並且使用 `if (kDebugMode)` 進行條件判斷。
   - 這樣才能確保在執行 `flutter build ios` 或打包 Release 版本時，這些除錯按鈕會自動隱藏，不會出現在生產環境中。

2. **商業化與 API 選擇 (Commercial API Usage)**: 
   - 本專案未來有商業化考量（如買斷、訂閱、內購），因此在串接外部 API（如天氣）時，**必須**選擇合法授權商業使用的服務。
   - 目前氣候連動採用 **台灣中央氣象署 (CWA) Open Data API**。不僅完全免費、開放商業使用，且與本 App 「台灣在地水稻文化」的核心精神完美契合。
   - **絕對避免**使用限制商業用途的免費 API（例如 Open-Meteo 免費版）。

## 產品願景與體驗設計 (Product Vision)
**重要**：本專案的核心精神是「真實、安靜、陪伴」，不是傳統的農場養成遊戲，避免使用任何商業化的遊戲機制（如金幣、體力、抽卡、看廣告等）。詳細的設計理念、MVP 規格與台灣稻作文化細節，請參閱專屬設計手冊：
👉 [docs/PRODUCT_VISION.md](file:///Users/giyoshimiken/Documents/Every-grain/docs/PRODUCT_VISION.md)
