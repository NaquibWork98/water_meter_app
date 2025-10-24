# 💧 Water Meter Reading App

A modern Flutter application designed to automate water meter reading and billing processes for commercial buildings. This app streamlines the manual meter reading process by leveraging QR code scanning, camera integration, and OCR technology.

![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)
![License](https://img.shields.io/badge/License-Private-red.svg)

## 📱 Features

### Core Functionality
- 🔐 **User Authentication** - Secure login/logout system
- 📷 **QR Code Scanner** - Quick meter identification via QR codes
- 📸 **Camera Integration** - Capture meter reading photos
- 🔍 **OCR Technology** - Automatic reading extraction from photos
- ✅ **Reading Confirmation** - Review and edit readings before submission
- 📊 **Reading History** - Track all meter readings over time
- 👥 **Tenant Management** - View and manage multiple tenants

### User Experience
- 🎨 **Material Design 3** - Modern, clean UI following latest design principles
- 🌙 **Responsive Layout** - Optimized for various screen sizes
- ⚡ **Fast Performance** - Smooth animations and transitions
- 📱 **Offline Support** - Local data caching with Hive

## 🛠 Tech Stack

### Framework & Language
- **Flutter** 3.0+ - Cross-platform mobile framework
- **Dart** 3.0+ - Programming language

### Architecture & Patterns
- **Clean Architecture** - Separation of concerns with clear layers
- **BLoC Pattern** - Predictable state management
- **Repository Pattern** - Data access abstraction
- **Dependency Injection** - Using GetIt

### Key Packages

#### State Management
- `flutter_bloc` ^8.1.6 - Business logic component
- `bloc` ^8.1.4 - Core bloc library
- `equatable` ^2.0.5 - Value equality

#### Networking
- `dio` ^5.4.3 - HTTP client
- `http` ^1.2.1 - HTTP requests
- `internet_connection_checker` ^1.0.0 - Connectivity check

#### Local Storage
- `hive` ^2.2.3 - NoSQL database
- `hive_flutter` ^1.1.0 - Hive Flutter integration
- `shared_preferences` ^2.2.3 - Key-value storage

#### Camera & Scanning
- `camera` ^0.10.5 - Camera access
- `mobile_scanner` ^5.1.1 - QR/barcode scanner
- `image_picker` ^1.1.2 - Image selection

#### Image Processing
- `image` ^4.2.0 - Image manipulation
- `path_provider` ^2.1.3 - File system paths

#### Utilities
- `intl` ^0.19.0 - Internationalization
- `permission_handler` ^11.3.1 - Runtime permissions
- `logger` ^2.3.0 - Logging
- `dartz` ^0.10.1 - Functional programming

## 🚀 Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** 3.0 or higher ([Install Flutter](https://docs.flutter.dev/get-started/install))
- **Dart SDK** 3.0 or higher (comes with Flutter)
- **Android Studio** or **Xcode** (for emulators)
- **Git** ([Install Git](https://git-scm.com/downloads))

### Installation

1. **Clone the repository**
```bash
   git clone https://github.com/NaquibWork98/meter_reading_app.git
   cd meter_reading_app
```

2. **Install dependencies**
```bash
   flutter pub get
```

3. **Run code generation** (if needed)
```bash
   flutter pub run build_runner build --delete-conflicting-outputs
```

4. **Check Flutter setup**
```bash
   flutter doctor -v
```

5. **Run the app**
```bash
   # On connected device
   flutter run

   # On specific device
   flutter devices
   flutter run -d <device_id>

   # Release mode
   flutter run --release
```

## 🔐 Demo Credentials

For testing purposes, use these mock credentials:

### Test User
- **Email:** `test@example.com`
- **Password:** `password`

### Admin User
- **Email:** `admin@example.com`
- **Password:** `admin123`

### Staff User
- **Email:** `staff@example.com`
- **Password:** `staff123`

> ⚠️ **Note:** These are mock credentials for development. Replace with real authentication when connecting to a backend.

## 📂 Project Structure
```
lib/
├── core/                           # Core functionality
│   ├── error/                      # Error handling & exceptions
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── theme/                      # App theming
│   │   └── app_theme.dart
│   ├── utils/                      # Utilities & constants
│   │   └── constants.dart
│   └── usecases/                   # Base use case
│       └── usecase.dart
│
├── features/                       # Feature modules
│   ├── authentication/             # Authentication feature
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── bloc/
│   │       ├── pages/
│   │       └── widgets/
│   │
│   └── meter_reading/              # Meter reading feature
│       ├── data/
│       │   ├── datasources/
│       │   ├── models/
│       │   └── repositories/
│       ├── domain/
│       │   ├── entities/
│       │   ├── repositories/
│       │   └── usecases/
│       └── presentation/
│           ├── bloc/
│           ├── pages/
│           └── widgets/
│
├── injection_container.dart        # Dependency injection setup
└── main.dart                       # App entry point
```

## 🎨 App Flow
```
┌─────────────┐
│   Splash    │ (Auto-check authentication)
└──────┬──────┘
       │
       ├─────── Authenticated? ──────┐
       │                             │
       ▼                             ▼
┌─────────────┐              ┌─────────────┐
│    Login    │              │    Home     │
└──────┬──────┘              └──────┬──────┘
       │                             │
       └──────── Login Success ──────┤
                                     │
                                     ├─► Scan QR Code
                                     │
                                     ├─► Capture Photo
                                     │
                                     ├─► Confirm Reading
                                     │
                                     ├─► Submit Reading
                                     │
                                     └─► View History
```

## 🧪 Running Tests
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/features/authentication/domain/usecases/login_test.dart
```

## 📱 Build & Release

### Android
```bash
# Build APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release

# Build split APKs
flutter build apk --split-per-abi
```

### iOS
```bash
# Build iOS
flutter build ios --release

# Build IPA
flutter build ipa
```

## 🐛 Troubleshooting

### Common Issues

**Issue: Gradle build fails**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

**Issue: Pod install fails (iOS)**
```bash
cd ios
pod deintegrate
pod install
cd ..
```

**Issue: Camera permission denied**
- Check `AndroidManifest.xml` has camera permissions
- Check `Info.plist` has camera usage description

## 🔮 Future Enhancements

- [ ] Real-time data synchronization
- [ ] Push notifications for reading reminders
- [ ] Multi-language support
- [ ] Dark mode theme
- [ ] Export readings to PDF/Excel
- [ ] Offline mode with sync queue
- [ ] Advanced analytics dashboard
- [ ] Tenant mobile app integration

## 📄 License

This project is private and proprietary. All rights reserved.

## 👨‍💻 Author

**Naquib**
- GitHub: [@NaquibWork98](https://github.com/NaquibWork98)

## 🤝 Contributing

This is a private project. If you have access and would like to contribute:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request
