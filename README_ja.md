# Rice Journey · 粒粒皆辛苦

[繁體中文](README.md) · [English](README_en.md) · [MIT ライセンス](LICENSE)

Rice Journey は、台湾の稲作をテーマにした Flutter アプリです。田植えから収穫まで稲が育ち、時刻や天気に合わせて田んぼの光と環境音が変わります。農作業の日誌と、iOS・Android のホーム画面に置ける田んぼのウィジェットもあります。

大学生や会社員の日常に、稲作を身近に感じるひとときを作ることを目指しています。昼休みにお弁当を食べながらホーム画面の田んぼを眺めると、ごはんになる前の稲の姿を思い浮かべられます。

![苗の時期の田んぼ](screenshots/screenshot_1_seedling.png)

## ローカルで実行

Dart 3.12.2 以上の 3.x を含む Flutter stable 3.44.0 以降を用意し、Android エミュレーターか iOS シミュレーターを起動するか、開発用端末を接続してください。環境の確認には `flutter doctor`、端末の一覧には `flutter devices` を使います。

iOS 実機では Xcode で自分の署名チームを設定してください。ウィジェットを試す場合は、アプリとウィジェットに同じプロビジョニング済みの App Group を設定します。

```sh
git clone https://github.com/codinguniversefromEric/Every-grain.git
cd Every-grain
flutter pub get
flutter run
```

標準設定では Open-Meteo から天気を取得します。位置情報を取得できない場合は台湾の苗栗の座標を使います。台湾の中央気象署のデータを試す場合は `flutter run --dart-define=CWA_API_KEY=your_key` を実行してください。デバッグモードでは、右上のレンチアイコンから時刻・天気・成長段階を切り替えられます。

## 貢献

開発時の確認手順やバグ報告については、[貢献ガイド](CONTRIBUTING.md)を参照してください。主なコードの場所は、[繁体字中国語版の README](README.md#程式碼導覽)にまとめています。
