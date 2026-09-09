#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "========================================"
echo "🚀 準備進行 100% 乾淨的雙平台發布打包 🚀"
echo "========================================"

# --- 版號互動更新邏輯 ---
CURRENT_VERSION_LINE=$(grep "^version: " pubspec.yaml)
CURRENT_VERSION=$(echo $CURRENT_VERSION_LINE | awk '{print $2}')
CURRENT_NAME=$(echo $CURRENT_VERSION | cut -d'+' -f1)
CURRENT_BUILD=$(echo $CURRENT_VERSION | cut -d'+' -f2)

NEW_BUILD=$((CURRENT_BUILD + 1))
NEW_NAME=$CURRENT_NAME

echo "🏷️ 目前 pubspec.yaml 中的版號為: $CURRENT_NAME (Build: $CURRENT_BUILD)"
echo "即將自動將 Build 升級至: $NEW_BUILD"
echo "請問需要一併修改主版號嗎？"
read -p "(直接按 Enter 保持 $CURRENT_NAME，或輸入新版號如 2.0.2): " USER_NEW_NAME

if [ ! -z "$USER_NEW_NAME" ]; then
    NEW_NAME=$USER_NEW_NAME
fi

NEW_VERSION="${NEW_NAME}+${NEW_BUILD}"
echo "📝 更新 pubspec.yaml 的版號為: $NEW_VERSION"

# 適用於 macOS 的 sed 語法
sed -i '' "s/^version: .*/version: $NEW_VERSION/" pubspec.yaml
echo "----------------------------------------"

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
