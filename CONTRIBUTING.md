# 貢獻指南 · Contributing

## 回報問題

請用 [GitHub Issues](https://github.com/codinguniversefromEric/Every-grain/issues) 回報問題。附上 App 版本、手機與作業系統版本、重現步驟，以及預期和實際的結果。若問題和天氣、定位或桌面小工具有關，可一併說明當時的權限設定。

## 提交修改

1. Fork 專案，建立分支。依照 [README](README.md#在本機執行) 啟動 App。
2. 用 `dart format` 格式化改過的 Dart 檔案，並執行下方的檢查。
3. 開 Pull Request，說明改了什麼和怎麼驗證。介面變更可附上截圖。

```sh
flutter analyze
flutter test test/services test/widget_test.dart
```

商店截圖生成器位於 [test/aso_generator_test.dart](test/aso_generator_test.dart)，執行時會寫入 `website/assets/screenshots/`。

翻譯請編輯 [lib/l10n/](lib/l10n/) 的 `.arb` 檔案，再用 `flutter gen-l10n` 更新產生的 Dart 檔案。涉及桌面小工具、定位或背景音效的修改，請在受影響的 iOS 或 Android 裝置上確認行為。

## English

Use [GitHub Issues](https://github.com/codinguniversefromEric/Every-grain/issues) for bug reports. Include your app version, device and OS, steps to reproduce, and the expected and actual behavior.

To contribute a change, fork the repository and follow the [local setup](README_en.md#run-locally). Format the Dart files you edit with `dart format`, run `flutter analyze` and `flutter test test/services test/widget_test.dart`, then describe the change and how you checked it in your pull request.

For translations, edit the `.arb` files in [lib/l10n/](lib/l10n/) and run `flutter gen-l10n`. For platform features such as widgets, location, or background audio, check the change on the affected platform.
