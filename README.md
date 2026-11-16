# 粒粒皆辛苦 · Rice Journey

[English](README_en.md) · [日本語](README_ja.md) · [MIT 授權](LICENSE)

《粒粒皆辛苦》是以台灣稻作為主題的 Flutter 作品。從插秧到收割，稻株會隨時間生長，田裡的光線、天氣和環境聲也會跟著變化。App 裡有農事日誌，並提供 iOS 和 Android 的桌面稻田小工具。

這個作品想把稻作放回大學生和上班族的日常。午餐吃便當時，瞄一眼手機桌面上的田，看看那碗飯在收割以前，稻子可能是什麼模樣。

![粒粒皆辛苦的秧苗期畫面](screenshots/screenshot_1_seedling.png)

## 在本機執行

準備 Flutter stable 3.44.0 以上（內含 Dart 3.12.2 以上的 3.x 版本），並啟動 Android 模擬器、iOS 模擬器或接上開發用手機。可用 `flutter doctor` 檢查工具鏈，用 `flutter devices` 確認裝置。

在 iOS 實機上測試時，請在 Xcode 設定自己的簽署團隊。測試 iOS 小工具時，也要讓 App 和小工具使用同一個已佈建的 App Group。

```sh
git clone https://github.com/codinguniversefromEric/Every-grain.git
cd Every-grain
flutter pub get
flutter run
```

預設可透過 Open-Meteo 取得天氣，使用苗栗座標作為無定位時的預設位置。若要測試台灣中央氣象署資料，可執行 `flutter run --dart-define=CWA_API_KEY=你的金鑰`。Debug 模式的右上角扳手可切換時段、天氣和生長階段。

## 程式碼導覽

| 路徑 | 內容 |
| --- | --- |
| [lib/main.dart](lib/main.dart) | App 入口與稻田主畫面 |
| [lib/services/](lib/services/) | 稻作模擬、天氣、音效、存檔與小工具更新 |
| [lib/visuals/](lib/visuals/) | 天空、水面和天氣等視覺圖層 |
| [lib/widgets/](lib/widgets/) | 農事日誌、收割畫面等介面元件 |
| [lib/l10n/](lib/l10n/) | 繁體中文、英文與日文翻譯 |
| [scripts/generate_audio.py](scripts/generate_audio.py) | 程式化音效的生成腳本 |

## 貢獻

歡迎回報問題或提交修正。請參考[貢獻指南](CONTRIBUTING.md)。[產品願景](docs/PRODUCT_VISION.md)記錄設計構想，[發布指南](docs/RELEASE_GUIDE.md)記錄原專案的打包流程。
