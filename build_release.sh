#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "========================================"
echo "🚀 準備進行 100% 乾淨的雙平台發布打包 🚀"
echo "========================================"

echo "🧹 [1/5] 清理 Flutter 暫存檔與依賴..."
flutter clean
flutter pub get

echo "🗑️ [2/5] 刪除 Xcode DerivedData 與 CocoaPods 快取..."
# 刪除 Xcode 衍生資料，確保沒有舊的快取
rm -rf ~/Library/Developer/Xcode/DerivedData/
# 刪除 iOS 專案內的 Pods
rm -rf ios/Pods
rm -f ios/Podfile.lock

echo "📦 [3/5] 重新安裝 iOS Pod 依賴..."
cd ios
# 更新 repo 並重新安裝 Pod
pod install --repo-update
cd ..

echo "🤖 [4/5] 開始打包 Android (AAB)..."
flutter build aab

echo "🍎 [5/5] 開始打包 iOS (IPA / xcarchive)..."
# 生成 xcarchive，讓你可以去 Xcode Organizer 匯出
flutter build ipa

echo "========================================"
echo "✅ 打包完成！"
echo "🤖 Android AAB 路徑: build/app/outputs/bundle/release/app-release.aab"
echo "🍎 iOS: 請打開 Xcode，點選上方選單 Window -> Organizer 來將 App 上傳至 TestFlight 或 App Store。"
echo "========================================"
