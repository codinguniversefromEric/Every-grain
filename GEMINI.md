# Every-grain (Rice Journey) Project Context

## 專案類型與用途
這是一個名為 `rice_journey` 的 Flutter 應用程式，主題是模擬或展示稻米生長過程（Rice Journey App）。
App 會根據各種條件（例如節氣、地點、時間等）來呈現對應的農田狀態與環境音效。

## 技術棧與相依套件 (Tech Stack & Dependencies)
- **Framework**: Flutter
- **狀態管理**: 採用基於原生的 `ChangeNotifier` 與 `ListenableBuilder` 架構 (集中於 `StateManager`)，取代零散的 `setState`，保持業務邏輯與 UI 渲染分離。
- **主要外部依賴** (`pubspec.yaml`):
  - `shared_preferences`: 用於儲存使用者的 reflections（心得/紀錄）等本地持久化資料。
  - `geolocator`: 取得使用者位置（用於計算台灣南北部的節氣差異與品種設定）。
  - `battery_plus`: 取得裝置電量（用於隱藏彩蛋或畫面變化）。
  - `just_audio`: 播放環境音效 (Ambient sound) 與收割音效。
  - `google_fonts`: 字體管理。
  - `http`: 處理網路請求，目前用於串接台灣中央氣象署 (CWA) Open Data API 取得真實天氣。

## 專案目錄結構 (Architecture)
- `lib/models/`: 資料模型與列舉。
  - `field_state.dart`, `rice_variety.dart`: 定義核心狀態與品種特徵模型。
- `lib/services/`: 封裝業務邏輯與硬體/外部 API 的整合。
  - `state_manager.dart`: 統一管理 App 核心狀態的 `ChangeNotifier`。
  - `agricultural_calendar.dart`: 農民曆/節氣與定位相關邏輯。
  - `ambient_sound.dart`: 音效播放邏輯。
  - `weather_service.dart`, `variety_service.dart`: 氣象與在地品種判定服務。
  - `app_logger.dart`: 統一的日誌紀錄工具。
- `lib/theme/`: 統一管理的設計系統。
  - `app_colors.dart`, `animation_constants.dart`, `strings.dart`: 集中管理色彩、動畫時長與文字常數。
- `lib/visuals/`: 分層的視覺特效元件 (如 `cloud_layer.dart`, `living_sky.dart` 等)。
- `lib/widgets/`: 可重用的 UI 元件 (如 `rice_plant.dart`, `about_screen.dart`)。
- `lib/main.dart`: 程式進入點與主畫面組裝。

## 開發規範與習慣 (Development Rules)
1. **條件式渲染除錯 UI (Debug UI)**: 
   - 專案中有專門給開發者使用的控制按鈕與選單（如 Developer Controls）。
   - **重要**：所有只應該在開發階段出現的 UI 元件，必須引入 `package:flutter/foundation.dart`，並且使用 `if (kDebugMode)` 進行條件判斷。

2. **金鑰與機密資訊 (Secrets & API Keys)**:
   - 絕對禁止將 API Key (例如 `CWA_API_KEY`) 寫死在程式碼中。
   - 必須使用 `String.fromEnvironment('API_KEY_NAME')` 從編譯環境變數中讀取。

3. **錯誤處理與日誌 (Error Handling & Logging)**:
   - 禁止在 `catch` 區塊中直接吞掉錯誤 (Silent fail)。
   - 必須使用 `AppLogger.e('Error message', e, stackTrace)` 進行錯誤捕捉與紀錄。
   - 避免使用原生的 `print()`，全面改用 `AppLogger` (`i`, `d`, `w`, `e`) 以確保在 Release 模式下不會印出非必要資訊。

4. **資料來源鳴謝 (Data Source Attribution)**:
   - 對於開放資料與外部知識庫有極高的要求，使用任何外部資料（如氣象、農業知識）時，**必須在 App 內適當位置（如「關於」畫面）清楚標示資料來源出處**。

5. **商業化與 API 選擇 (Commercial API Usage)**: 
   - 串接外部 API 時，**必須**選擇合法授權商業使用的服務。
   - 氣候連動採用 **台灣中央氣象署 (CWA) Open Data API**（免費、開放商業使用）。絕對避免使用限制商業用途的免費 API。

## 產品願景與體驗設計 (Product Vision)
**核心精神**：「真實、安靜、陪伴」。這不是傳統的農場養成遊戲，避免使用任何商業化的遊戲機制（如金幣、體力、抽卡、看廣告等）。
- **商業化模式 (Monetization)**：採用極度低調的 **「免費下載 + 隨喜贊助 (Tip Jar)」** 模式。贊助選項融入在「關於」設定頁中，不打擾使用者的靜謐體驗。
- **在地連結**：根據 GPS 決定種植品種 (如高雄139號、台南11號)，並在收割時解鎖在地知識卡。
- 詳細的設計理念與 MVP 規格，請參閱專屬設計手冊：
👉 [docs/PRODUCT_VISION.md](file:///Users/giyoshimiken/Documents/Every-grain/docs/PRODUCT_VISION.md)
