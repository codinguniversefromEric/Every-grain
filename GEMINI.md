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
1. **封測工具與除錯 UI (Tester Controls & Debug UI)**: 
   - 專案中有專門給測試者使用的控制按鈕與選單（如 Developer Controls）。
   - **重要防呆**：Developer Controls 是開放給所有封測員的核心體驗工具（透過 `isBetaTestMode` 控制），因此設計上必須維持「地點 (瞬間移動)、時間快轉、天氣事件切換」的巨集按鈕分類。**嚴禁**使用或改回會導致品種與氣候狀態衝突的細部數值滑桿。
   - **UX 閉環防呆**：任何涉及「虛擬傳送」的功能，都**必須**在介面最醒目處伴隨一個「恢復真實定位 (Reset to Real Location)」的按鈕，絕對不能讓測試員迷失在虛擬時空而無法回到真實體驗。

2. **金鑰與機密資訊 (Secrets & API Keys)**:
   - 絕對禁止將 API Key (例如 `CWA_API_KEY`) 寫死在程式碼中。
   - 必須使用 `String.fromEnvironment('API_KEY_NAME')` 從編譯環境變數中讀取。

3. **錯誤處理與日誌 (Error Handling & Logging)**:
   - 禁止在 `catch` 區塊中直接吞掉錯誤 (Silent fail)。
   - 必須使用 `AppLogger.e('Error message', e, stackTrace)` 進行錯誤捕捉與紀錄。
   - 避免使用原生的 `print()`，全面改用 `AppLogger` (`i`, `d`, `w`, `e`) 以確保在 Release 模式下不會印出非必要資訊。

4. **資料來源鳴謝 (Data Source Attribution)**:
   - 對於開放資料與外部知識庫有極高的要求，使用任何外部資料（如氣象、農業知識）時，**必須在 App 內適當位置（如「關於」畫面）清楚標示資料來源出處**。
   - 氣象資料來源的 UI 文字必須依據當下使用之 API 動態切換顯示（CWA 或 Open-Meteo）。

5. **商業化與 API 選擇 (Commercial API Usage)**: 
   - 串接外部 API 時，**必須**選擇合法授權商業使用的服務。
   - 氣候連動採用 **「雙軌制」：台灣境內使用中央氣象署 (CWA) Open Data API，海外使用 Open-Meteo API**（皆為免費、符合開放商業或開源授權使用）。
   - **重要防呆**：Open-Meteo 的海外氣象與台灣節氣曆法（依據緯度判斷）是可以完美共存的跨文化設計。**絕對禁止**因為使用者在國外，就寫死程式碼強制篡改他們的 GPS 座標至台灣。

6. **多國語系與文化堅持 (Localization & Culture)**:
   - 全面禁止在 UI 程式碼中寫死任何字串（包含中文），所有文字一律強制透過 `app_zh.arb`, `app_en.arb`, `app_ja.arb` 處理，徹底做到語系隔離。
   - **文化彩蛋**：About 畫面的 `[臺灣]` 落款印章是**刻意保留的東方美學與原產地彩蛋**，未來在維護或擴增語系時，**絕對禁止**將其翻譯為英文 (TAIWAN) 或日文，必須在所有語系中維持原本的繁體漢字。

## 產品願景與體驗設計 (Product Vision)
**核心精神**：「真實、安靜、陪伴」。這不是傳統的農場養成遊戲，避免使用任何商業化的遊戲機制（如金幣、體力、抽卡、看廣告等）。
- **完全免費與開源 (Open Source)**：專案定位為純粹的陪伴工具，沒有任何強制的商業營利模式。開放社群自由贊助 (例如請喝珍奶)，並將 App 完全開源於 GitHub，鼓勵社群學習與貢獻。
- **在地連結**：根據 GPS 決定種植品種 (如高雄139號、台南11號)，並在收割時解鎖在地知識卡。
- 詳細的設計理念與 MVP 規格，請參閱專屬設計手冊：
👉 [docs/PRODUCT_VISION.md](file:///Users/giyoshimiken/Documents/Every-grain/docs/PRODUCT_VISION.md)

## 自動化部署與基礎設施 (CI/CD & Infrastructure)
1. **GitHub Pages 網站部署**:
   - 形象網站原始碼放置於 `website/` 目錄中。
   - 使用 `.github/workflows/deploy-pages.yml` 進行部署，任何對 `main` 分支的推播皆會自動觸發並部署至 GitHub Pages，**無需**額外維護 `gh-pages` 分支。
2. **Android APK 自動發布 (GitHub Actions)**:
   - 打包指令已設定於 `.github/workflows/release-apk.yml`，當推播 `v*` 開頭的標籤 (tag) 時，會自動編譯 Release APK 並建立 GitHub Release。
   - **金鑰安全規範**：`upload-keystore.jks` 與 `key.properties` **必須**加入 `.gitignore`，嚴禁提交至 Git。自動打包時是透過 GitHub Secrets (`KEYSTORE_BASE64`, `KEY_PROPERTIES`) 進行動態解密還原。
3. **App Store 宣傳截圖自動化生成**:
   - 截圖生成一律採用 Flutter Integration Test 自動化進行，禁止手動截圖 (以避免解析度錯誤或截到不必要的 Debug UI)。
   - 執行指令：`flutter drive --driver=test_driver/integration_test.dart --target=integration_test/screenshot_test.dart`
   - 產出的截圖會自動儲存於根目錄的 `screenshots/` 中，並可複製至 `website/assets/screenshots/` 供網頁使用。
4. **Git 多帳號推播防呆 (Credential Conflict Prevention)**:
   - 由於開發者本機環境存在多個 GitHub 帳號的憑證衝突，AI 在提供推播指令給使用者時，**絕對禁止**只提供單純的 `git push`。
   - **強制格式**：一律必須在 URL 中帶入指定的帳號名稱 `codinguniversefromEric`，以強制喚起正確的權限認證。指令範例如下：
     `git push https://codinguniversefromEric@github.com/codinguniversefromEric/Every-grain.git main`
