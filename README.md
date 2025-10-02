# 🎵 Hymnes & Louanges

A beautiful Flutter application for French Adventist hymns with MIDI audio playback, featuring clean architecture and elegant design.

## ✨ Features

- **📚 Hymn Library**: Browse through a collection of French Adventist hymns with full lyrics
- **🎵 MIDI Audio Playback**: Listen to hymns with MIDI audio files
- **🔍 Search**: Find hymns by title, lyrics, author, composer, or hymn number
- **⭐ Favorites**: Save your favorite hymns (coming soon)
- **🌐 Bilingual Support**: French and English interface
- **📱 Modern UI**: Clean, responsive design with Material Design 3
- **🎨 Elegant Theme**: Forest Green, Gold, and White color scheme

## 📱 Preview

<div align="center">
  <img src="screenshot_1.png" alt="Hymnes App Screenshot" width="300" />
  <p><em>Home screen showing hymn list with search functionality</em></p>
</div>

## 🚀 Quick Start

### Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK**: 3.2.3 or higher
- **Dart SDK**: 3.0.0 or higher
- **Git**: For cloning the repository
- **IDE**: Android Studio, VS Code, or IntelliJ with Flutter plugin

### Installation Steps

1. **Clone the Repository**

   ```bash
   git clone https://github.com/yourusername/hymnes.git
   cd hymnes
   ```

2. **Install Flutter Dependencies**

   ```bash
   flutter pub get
   ```

3. **Generate Localization Files**

   ```bash
   flutter gen-l10n
   ```

4. **Generate Code (Optional - for Hive adapters)**

   ```bash
   flutter packages pub run build_runner build
   ```

5. **Run the Application**
   ```bash
   flutter run
   ```

### Platform-Specific Setup

#### For Android Development

- Install Android Studio
- Set up Android SDK (API level 21 or higher)
- Enable USB debugging on your device or use an emulator

#### For iOS Development (macOS only)

- Install Xcode from the App Store
- Install iOS Simulator
- Ensure you have a valid Apple Developer account for device testing

#### For Web Development

- No additional setup required
- Run with: `flutter run -d chrome`

## 🛠️ Technology Stack

- **Framework**: Flutter 3.2.3+
- **Language**: Dart 3.0.0+
- **State Management**: BLoC Pattern (flutter_bloc 8.1.3)
- **Audio**: Just Audio 0.9.36 for MIDI playback
- **Storage**: Hive 2.2.3 for local data persistence
- **Navigation**: Go Router 12.1.3
- **Internationalization**: Built-in Flutter i18n
- **Architecture**: Clean Architecture with Repository Pattern

## 📦 Key Dependencies

```yaml
dependencies:
  flutter_bloc: ^8.1.3 # State management
  just_audio: ^0.9.36 # Audio playback
  hive: ^2.2.3 # Local storage
  go_router: ^12.1.3 # Navigation
  equatable: ^2.0.5 # Value equality
  shared_preferences: ^2.2.2 # Settings storage
  showcaseview: ^2.0.3 # Feature highlights
```

## 🏗️ Project Structure

```
lib/
├── core/                     # Core functionality
│   ├── models/              # Data models (Hymn)
│   ├── providers/           # Global providers (Language)
│   ├── repositories/        # Data access layer
│   └── services/            # Business logic services
├── features/                # Feature modules
│   ├── audio/              # Audio playback (BLoC)
│   ├── favorites/          # Favorites management
│   ├── hymns/              # Hymns feature (BLoC)
│   ├── midi/               # MIDI playback (BLoC)
│   └── search/             # Search functionality
├── l10n/                   # Localization files
│   ├── app_en.arb          # English translations
│   └── app_fr.arb          # French translations
├── presentation/           # UI layer
│   └── screens/            # App screens
└── shared/                 # Shared components
    ├── constants/          # App constants & colors
    ├── utils/              # Utility functions
    └── widgets/            # Reusable widgets
```

## 🎵 Audio Features

### MIDI Playback

- **All Voices**: Play complete MIDI arrangements
- **Individual Voices**: Soprano, Alto, Tenor, Bass (coming soon)
- **Playback Controls**: Play, pause, stop, seek
- **Volume Control**: Adjustable audio levels

### Audio Files

MIDI files should be placed in `assets/midi/` with the naming convention:

- `h001.mid` for Hymn 1
- `h002.mid` for Hymn 2
- etc.

## 🌐 Localization

The app supports French and English:

- **French**: Default language
- **English**: Available through settings
- **Adding Languages**: Add new `.arb` files in `lib/l10n/`

## 🧪 Development

### Running Tests

```bash
flutter test
```

### Code Generation

```bash
# Generate localization files
flutter gen-l10n

# Generate Hive adapters (if needed)
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Linting

```bash
flutter analyze
```

## 📱 Building for Production

### Android APK

```bash
flutter build apk --release
```

### Android App Bundle

```bash
flutter build appbundle --release
```

### iOS App

```bash
flutter build ios --release
```

### Web App

```bash
flutter build web --release
```

## 🎯 State Management

The app uses **BLoC Pattern** consistently:

### Available BLoCs

- **LanguageBloc**: Language selection and persistence
- **MidiBloc**: MIDI playback control
- **AudioBloc**: Audio playback management
- **HymnsBloc**: Hymn data and search management

### Usage Example

```dart
// Dispatch events
context.read<MidiBloc>().add(PlayMidi('h001'));

// Listen to state
BlocBuilder<MidiBloc, MidiState>(
  builder: (context, state) {
    if (state is MidiLoaded && state.isPlaying) {
      return Text('Playing: ${state.currentMidiFile}');
    }
    return Text('Stopped');
  },
)
```

## 🔧 Troubleshooting

### Common Issues

1. **Dependencies not found**

   ```bash
   flutter clean
   flutter pub get
   ```

2. **Localization not working**

   ```bash
   flutter gen-l10n
   flutter run
   ```

3. **Build errors**

   ```bash
   flutter clean
   flutter pub get
   flutter packages pub run build_runner build --delete-conflicting-outputs
   ```

4. **Audio not playing**
   - Ensure MIDI files are in `assets/midi/` directory
   - Check that assets are declared in `pubspec.yaml`
   - Verify device audio is not muted

### Platform-Specific Issues

#### Android

- Minimum SDK version: 21
- If build fails, check `android/app/build.gradle` configuration

#### iOS

- Requires Xcode 12 or later
- Ensure iOS deployment target is 11.0 or higher

#### Web

- Audio playback may have limitations in some browsers
- Use Chrome for best compatibility

## 📊 Performance

### Optimization Tips

- MIDI files are loaded on-demand
- Images and assets are cached automatically
- BLoC pattern ensures efficient state updates
- Local storage with Hive for fast data access

## 🤝 Contributing

1. **Fork** the repository
2. **Create** a feature branch: `git checkout -b feature/amazing-feature`
3. **Commit** changes: `git commit -m 'Add amazing feature'`
4. **Push** to branch: `git push origin feature/amazing-feature`
5. **Open** a Pull Request

### Development Guidelines

- Follow Flutter/Dart style guidelines
- Use BLoC pattern for state management
- Add tests for new features
- Update documentation as needed
- Ensure localization for both languages

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Flutter Team**: For the amazing framework
- **BLoC Library**: For excellent state management
- **Just Audio**: For reliable audio playback
- **Material Design**: For design guidelines
- **Adventist Hymnal**: For the hymn content

## 📞 Support

Need help? Here's how to get support:

- **🐛 Bug Reports**: [Open an issue](https://github.com/yourusername/hymnes/issues)
- **💡 Feature Requests**: [Submit a request](https://github.com/yourusername/hymnes/issues)
- **📧 Questions**: Contact through GitHub issues

## 🌟 Show Your Support

If this project helps you, please consider:

- ⭐ **Starring** the repository
- 🐛 **Reporting** bugs you find
- 💡 **Suggesting** new features
- 🤝 **Contributing** to the codebase

---

**Built with ❤️ using Flutter and BLoC**

_"Make a joyful noise unto the Lord, all ye lands!"_ - Psalm 100:1
