# 發布與打包指南 (Release & Build Guide)

本指南說明如何為「粒粒皆辛苦 (Rice Journey)」專案進行正式版的打包發布，包含 **iOS 的本機自動化腳本**，以及 **Android 的 GitHub Actions 自動化 CI**，並解釋腳本背後的快取原理。

## 自動化打包腳本：`build_release.sh`

為確保每次打包上架的版本都是「100% 乾淨、無殘留快取」的最佳狀態，我們在專案根目錄提供了一支自動化打包腳本：`build_release.sh`。

### 如何使用？

當你需要準備發布新版本到 Google Play 或是 App Store 時，請打開終端機 (Terminal) 並在專案根目錄執行：

```bash
./build_release.sh
```

執行完畢後：
- **iOS**: 將會生成 `.xcarchive`，腳本會自動幫你呼叫 Xcode 打開 Organizer 並匯入。請在彈出的視窗中點擊 `Distribute App` 即可上傳至 TestFlight 或 App Store。
- **Android (GitHub Actions)**: 本機腳本執行完畢後，請記得將變更後的 `pubspec.yaml` 進行 `git commit`，接著建立並推播版號標籤（例如 `git tag v2.0.2` 然後 `git push origin v2.0.2`）。推播標籤後，雲端的 GitHub Actions 就會自動觸發並幫你完成 Android 版本的打包與發布。

---

## 為什麼需要這支腳本？（快取原理大揭密）

很多開發者在更新了 `pubspec.yaml` 中的套件，或是在除錯原生問題時，常常會發現：**「明明已經跑過 `flutter clean`，為什麼 iOS 打出來還是舊版的 UI，或是依然大噴錯？」**

這是因為 Flutter 專案中存在著 **「雙層快取機制」**：

### 1. Flutter / Dart 層快取
`flutter clean` 實際上只能清掉 Dart 和 Flutter 層的產物（也就是 `build/` 和 `.dart_tool/` 資料夾）。它**管不到原生 iOS 的編譯中介檔**。

### 2. 原生層 (Xcode / CocoaPods) 快取
當你使用了需要呼叫硬體底層的套件 (例如 `geolocator`) 時，裡面其實包含了原生的 Swift 程式碼。Flutter 會呼叫 **CocoaPods** (iOS 的套件管理員) 去幫你下載這些程式碼。

而 CocoaPods 和 Xcode 都有非常頑固的快取機制：
- **Xcode DerivedData**: Xcode 會把你編譯過的中介檔 (AST、Module 快取) 存在 `~/Library/Developer/Xcode/DerivedData/`。有時候就算你在 Xcode 點了 `Clean Build Folder`，也未必能完全清乾淨。
- **CocoaPods Global Cache**: CocoaPods 會把你曾經下載過的套件壓縮檔藏在系統深處，如果舊套件有 Bug 但快取沒清，它依然會把你壞掉的舊程式碼包進去。

### 腳本的「四重清理」防呆機制

為了解決上述問題，`build_release.sh` 依序執行了以下暴力且徹底的清理動作：

1. **`flutter clean`**：清空 Dart 產物。
2. **刪除 Xcode `DerivedData`**：核彈級刪除全域編譯快取，保證 Xcode 砍掉重練。
3. **撕毀 `Podfile.lock` 與 `ios/Pods`**：切斷 CocoaPods 對舊套件版本的記憶。
4. **`pod install --repo-update`**：強迫 CocoaPods 連上網路，重新下載最正確、最新的原生套件。

透過這套「由內而外」的清理流程，下次如果打包出錯，你就會非常清楚：**「絕對不是快取的鍋，而是程式碼真的有 Bug！」**
