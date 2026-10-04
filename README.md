<img src="https://raw.githubusercontent.com/drunkmonkkk/drunkmonkkk/main/assets/kabadiwala.svg" width="100%" alt="Kabadiwala Connect — scrap identification and handover prototype">

# Kabadiwala Connect

A Flutter prototype for scrap collectors: photograph a material, inspect a classification, compare estimated rates, and record a handover.

[App screens](lib/screens) · [Local inference API](https://github.com/drunkmonkkk/kabadiwala_backend) · [Cloud inference API](https://github.com/drunkmonkkk/kabadiwala_backend_v2)

## Inside the app

- **Capture and identification** — image capture, classification progress, and material results.
- **Prices and recyclers** — sample material rates and recycler listings, with location-aware distance ranking.
- **Handover and receipts** — confirmation, proof, receipt, and earnings screens.
- **Shared interface** — a dedicated design system for colour, spacing, typography, and components.

Recycler listings and prices are sample data in [lib/mock_data.dart](lib/mock_data.dart). This is a prototype, not a live recycler marketplace.

## Run locally

Install Flutter with a Dart SDK compatible with the constraint in [pubspec.yaml](pubspec.yaml), then run from this repository:

```bash
flutter pub get
flutter run
```

### Connect the backend

Configuration lives in [lib/config/api_config.dart](lib/config/api_config.dart). The committed `customBaseUrl` overrides platform defaults and points to a temporary Cloudflare tunnel. For your own setup, change it to your backend URL, or set it to an empty string to use the platform defaults:

| Target | Default backend address |
| --- | --- |
| Local web / desktop | `http://127.0.0.1:8000` |
| Android emulator | `http://10.0.2.2:8000` |
| Physical device | Set `customBaseUrl` to a reachable backend address |

The app's [AI API service](lib/services/ai_api_service.dart) calls `POST /predict`, provided by [kabadiwala_backend](https://github.com/drunkmonkkk/kabadiwala_backend). The separate [v2 backend](https://github.com/drunkmonkkk/kabadiwala_backend_v2) exposes cloud classification and PCB analysis routes; it is not a drop-in replacement for `/predict`.

The on-device model asset is currently a placeholder. See [assets/ml/PLACEHOLDER.md](assets/ml/PLACEHOLDER.md) before enabling local model inference.

## Find your way around

| Location | Purpose |
| --- | --- |
| [lib/screens](lib/screens) | Capture, results, recyclers, handover, receipts, and earnings |
| [lib/design_system](lib/design_system) | Shared visual components and tokens |
| [lib/services](lib/services) | Classification, API calls, and location |
| [lib/app_state.dart](lib/app_state.dart) | Shared application state |
| [lib/mock_data.dart](lib/mock_data.dart) | Prototype materials, rates, and recycler data |

## Development checks

```bash
flutter analyze
flutter test
```
