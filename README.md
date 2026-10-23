# MM spinning calculator

A Flutter application for planning, balancing, and costing a spinning mill. The package name is `spin_logic`; the app targets the web and Android.

## Calculation modules

- Production calculation for carding, draw frame, comber, simplex, ring frame, and winding.
- Yarn count conversion between Ne, Nm, Tex, and Denier.
- Blow room and card waste.
- Profit/loss and cotton blend costing.
- Pressure conversion.
- Relative humidity from dry and wet bulb readings.
- Target count feasibility.
- Ring doff and roving consumption.
- New mills planning.
- Spin plan and department balancing.

See [the user guide](Spin_Logic_User_Guide.pdf) for the application manual.

## Run locally

The web build script and Android workflow currently pin **Flutter 3.47.7**. Use that SDK to match their dependency resolution. The package declares Dart `>=3.12.0 <4.0.0`.

```sh
git clone https://github.com/Muqeet04/spinning-calculator.git
cd spinning-calculator
flutter --version
flutter doctor
flutter pub get --enforce-lockfile
flutter run -d chrome
```

For Android, configure the Android SDK, connect an emulator or device, and select its ID from `flutter devices`:

```sh
flutter devices
flutter run -d <device-id>
```

## Check changes

Run from the repository root:

```sh
flutter test --no-pub
flutter analyze
```

The existing tests cover conversions, humidity, ring doff calculations, mobile layouts, and PDF reports. Fetch dependencies before running these commands.

## Release builds

Web:

```sh
bash scripts/build-web.sh
```

The script obtains the pinned Flutter SDK if needed, resolves the lockfile, and writes the site to `build/web/`. Set `FLUTTER_SDK_DIR` to reuse an SDK at another location. It also writes `build/web/deployment.json` with the source commit SHA.

Android:

```sh
flutter build apk --release --no-pub --no-tree-shake-icons
```

The APK is written to `build/app/outputs/flutter-apk/app-release.apk`. The [Android workflow](.github/workflows/build-android.yml) runs tests and builds the APK for pushes and pull requests targeting `main`; release publishing is restricted to `main` outside pull requests. [Vercel configuration](vercel.json) uses the web build script and serves `build/web/`.

## Source layout

| Path | Purpose |
| --- | --- |
| `lib/core/calc/` | Calculation functions |
| `lib/ui/screens/` | Calculation screens and home page |
| `lib/ui/widgets/` | Shared inputs, layouts, and PDF helpers |
| `lib/app/` | Routing and theme |
| `assets/data/` | Reference tables |
| `test/` | Flutter regression checks |
| `web/`, `android/` | Platform entry points |

