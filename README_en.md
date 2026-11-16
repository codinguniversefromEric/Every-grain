# Rice Journey · 粒粒皆辛苦

[繁體中文](README.md) · [日本語](README_ja.md) · [MIT License](LICENSE)

Rice Journey is a Flutter app about rice farming in Taiwan. The rice grows from transplanting to harvest as daylight, weather, and ambient sounds change. The app includes a farming journal and a rice field home-screen widget for iOS and Android.

The project explores how rice farming might fit into the everyday lives of university students and office workers. Over a lunchbox, a glance at the field on your home screen can bring to mind what the rice in your meal looked like before harvest.

![Rice Journey at the seedling stage](screenshots/screenshot_1_seedling.png)

## Run locally

Use Flutter stable 3.44.0 or later with Dart 3.12.2 or a later 3.x version. Start an Android emulator or iOS simulator, or connect a development device. Run `flutter doctor` to check your setup and `flutter devices` to list available devices.

For a physical iOS device, set your signing team in Xcode. To test the iOS widget, configure the app and widget to use the same provisioned App Group.

```sh
git clone https://github.com/codinguniversefromEric/Every-grain.git
cd Every-grain
flutter pub get
flutter run
```

Open-Meteo works with the default configuration. When location is unavailable, the app uses coordinates in Miaoli, Taiwan. To try Taiwan's Central Weather Administration data, run `flutter run --dart-define=CWA_API_KEY=your_key`. In debug mode, use the wrench in the top-right corner to switch the time of day, weather, and growth stage.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development checks and how to report issues. The [code map](README.md#程式碼導覽) in the main README links to the app's main components.
