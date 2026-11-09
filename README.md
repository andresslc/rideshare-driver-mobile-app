# Driver App

A Flutter driver app for a ride-hailing and carpool platform. Drivers go online, receive and accept ride requests in real time, navigate turn by turn, run carpools with multiple passengers, chat with riders, and manage earnings and payouts.

> **About this repository**
> This code comes from a discontinued project and is published for learning purposes. All branding, credentials, signing keys and backend endpoints were removed or replaced with placeholders. The backend API is not included, so the app does not connect to a live server out of the box.

## Features

| Area | What it does |
| --- | --- |
| Auth | Phone number login with OTP, account review status |
| Dashboard | Online/offline toggle, ride stats, side drawer |
| Ride room | Real-time ride requests over Socket.IO, pickup/drop-off flow, OTP check at pickup, in-app Mapbox turn-by-turn navigation |
| Carpool | Create carpools, add stops, pick up and drop off several passengers on one route |
| Chat | Driver–rider chat during a ride |
| Ride history | Past rides and carpools, passenger details, reviews |
| Wallet and bank account | Transaction history, withdrawals, bank account setup with Stripe |
| Referrals | Driver referral code, share link, referral history |
| Notifications | Firebase Cloud Messaging with local notifications |
| Settings | English/Spanish, light/dark theme, saved locations, account deletion |

## Tech stack

- **Flutter / Dart** (Dart `>=3.9`)
- **State:** Riverpod, **DI:** get_it, **Routing:** go_router
- **Networking:** Dio, socket_io_client
- **Maps:** Google Maps, Google Places API (New), Mapbox Navigation
- **Firebase:** Auth, Cloud Messaging, Remote Config
- **Payments:** Stripe (Financial Connections)
- **Code push:** Shorebird
- Feature-first clean architecture (`data` / `domain` / `presentation` per feature)

```
lib/
├── core/        # config, DI, networking, services, theme, navigation
├── features/    # auth, carpool, chat, dashboard, ride_room, wallet, ...
├── shared/      # reusable widgets and screens
├── l10n/        # English and Spanish translations
└── main_dev.dart / main_staging.dart / main_prod.dart
```

## Getting started

### 1. Install dependencies

```sh
flutter pub get
```

### 2. Connect your own Firebase project

The Firebase config files are not in the repo. Generate them with the [FlutterFire CLI](https://firebase.google.com/docs/flutter/setup):

```sh
flutterfire configure
```

This creates `lib/firebase_options.dart`, `android/app/google-services.json` and `ios/Runner/GoogleService-Info.plist`. The last two are git-ignored.

Optional Remote Config keys the app reads: `BASE_URL_DEV`, `BASE_URL_STAGING`, `BASE_URL_PROD`, `MapApiKey`, `stripePublishableKey`, `serviceRegionId`, `termsURL`, `privacyURL`, `supportEmail`, `minRequiredVersion`, `latestVersion`, `appStoreUrl`, `playStoreUrl`.

### 3. Add your API keys

**Android:** add to `android/local.properties` (git-ignored):

```properties
MAPS_API_KEY=your-google-maps-key
MAPBOX_ACCESS_TOKEN=pk.your-mapbox-public-token
MAPBOX_DOWNLOADS_TOKEN=sk.your-mapbox-secret-downloads-token
```

**iOS:** replace `YOUR_GOOGLE_MAPS_API_KEY` in `ios/Runner/AppDelegate.swift` and `YOUR_MAPBOX_PUBLIC_TOKEN` in `ios/Runner/Info.plist`. The Mapbox iOS SDK download also needs your secret token in `~/.netrc`.

**Dart:** pass keys at run time:

```sh
--dart-define=MAPS_API_KEY=your-google-maps-key \
--dart-define=STRIPE_PUBLISHABLE_KEY=pk_test_...
```

### 4. Run

Android flavors are `dev`, `staging` and `production`. iOS schemes are `Dev`, `Staging` and `Prod`.

```sh
flutter run --flavor dev -t lib/main_dev.dart \
  --dart-define=ENV=dev \
  --dart-define=MAPS_API_KEY=your-google-maps-key
```

### Tests

```sh
flutter test
```

## Release builds

- **Android signing:** create `android/key.properties` (git-ignored) pointing to your own keystore. Without it, release builds fall back to the debug key.
- **Shorebird:** replace `YOUR_SHOREBIRD_APP_ID` in `shorebird.yaml` with your own app IDs.
- **CI:** the GitHub Actions workflows in `.github/workflows` run only on manual dispatch. `.github/SECRETS.md` lists the secrets they need.
