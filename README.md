# PhotoVault - Photo Viewer App

A beautiful Flutter photo gallery app with local and online photo management.

## Features

✅ **Gallery View** - Browse your photos in a beautiful grid layout
✅ **Add Photos** - Pick multiple photos from your device
✅ **Online Photos** - Browse and download photos from Unsplash
✅ **Photo Viewer** - View photos with pinch-to-zoom and interactive controls
✅ **Photo Editing** - Edit images with filters, cropping, and adjustments
✅ **Favorites** - Mark photos as favorites for quick access
✅ **Share & Save** - Share photos or save them to your device gallery
✅ **Local Storage** - All photos stored locally, no cloud required
✅ **Albums** - Organize photos by folders
✅ **Dark/Light Theme** - Toggle between dark and light modes
✅ **Cross-Platform** - Works on Android, iOS, Windows, macOS, and Linux

## Getting Started

### Prerequisites
- Flutter SDK 3.35.7 or higher
- Dart 3.9.2 or higher

### Installation

1. Clone the repository
2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Platform Support

- ✅ Android (API 21+)
- ✅ iOS
- ✅ Windows
- ✅ macOS  
- ✅ Linux
- ✅ Web

## Architecture

- **Provider** - State management
- **Local Storage** - SharedPreferences for metadata, local files for photos
- **Material Design 3** - Modern UI with custom theme

## Key Dependencies

- `image_picker` - Select photos from device
- `photo_view` - Zoom and pan images
- `image_editor_plus` - Edit images with filters and adjustments
- `provider` - State management
- `path_provider` - Access device directories
- `shared_preferences` - Store photo metadata and favorites
- `http` - Fetch photos from Unsplash API
- `share_plus` - Share photos with other apps
- `image_gallery_saver` - Save photos to device gallery

## Project Structure

```
lib/
├── main.dart                      # App entry point
├── models/                        # Data models
│   └── photo.dart
├── providers/                     # State management
│   ├── photo_provider.dart
│   └── theme_provider.dart
├── repositories/                  # Data layer
│   └── photo_repository.dart
├── services/                      # Business logic
│   ├── device_photo_service.dart
│   └── favorites_service.dart
├── screens/                       # UI screens
│   ├── home_screen.dart
│   ├── gallery_screen.dart
│   ├── albums_screen.dart
│   ├── online_photos_screen.dart
│   └── viewer_screen.dart
├── theme/                         # App theming
│   └── app_theme.dart
└── widgets/                       # Reusable widgets
    └── network_image.dart
```

## Building for Production

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

### Windows
```bash
flutter build windows --release
```

## App Icon

To generate app icons:

1. Place your icon image (1024x1024 PNG) at `assets/icon.png`
2. Run: `dart run flutter_launcher_icons`

The app uses a modern indigo gradient theme (#6366F1).

## Screens

### Home Screen
- Quick access to all sections
- View recent photos
- Navigate to Gallery, Albums, or Online Photos

### Gallery Screen
- Grid view of all your photos
- Add photos from device
- Search and filter options
- Quick access to favorites

### Albums Screen
- Organize photos by albums/folders
- Create and manage albums
- View photos by album

### Online Photos Screen
- Browse curated photos from Unsplash
- Download photos to your gallery
- Search for specific topics

### Viewer Screen
- Full-screen photo viewing
- Pinch-to-zoom and pan
- Like/unlike photos
- Share photos with other apps
- Save photos to device gallery
- Edit photos with filters and adjustments
- View photo information

## Known Issues

- Image editor has compatibility issues on some platforms
- Camera not supported on desktop platforms (Windows/Linux/macOS)
- To add photos, use the "Add Photos" button (camera option only works on mobile)
- Unsplash API requires internet connection for online photos

## License

This project is open source and available under the MIT License.
