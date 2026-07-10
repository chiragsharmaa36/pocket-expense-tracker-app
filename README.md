# 💰 Pocket Expense Tracker App

A powerful, feature-rich Flutter expense tracking application with cloud synchronization, offline-first capabilities, and location-based expense management. Built with clean architecture principles and BLoC state management for a robust, scalable codebase.

## 📋 Table of Contents

- [Overview](#overview)
- [Screenshots](#screenshots)
- [Features](#-features)
- [User Flow](#-user-flow)
- [Tech Stack](#%EF%B8%8F-tech-stack)
- [Architecture](#%EF%B8%8F-architecture)
- [Project Structure](#-project-structure)
- [Firebase Configuration](#-firebase-configuration)
- [Getting Started](#-getting-started)
- [Releases](#-releases)
- [Installation & Setup](#-installation--setup)
- [Usage](#-usage)
- [Development](#-development)

---

## Overview

**Pocket Expense Tracker** is a comprehensive expense management solution designed for iOS, Android, and Web platforms. The application enables users to:

- Track daily expenses with detailed information
- Visualize spending patterns through interactive charts
- Manage expenses offline with automatic cloud synchronization
- Track expense locations using GPS integration
- Monitor sync status with real-time updates
- Access their data seamlessly across multiple devices

The app follows **Clean Architecture** principles and uses **BLoC pattern** for state management, ensuring maintainability, testability, and scalability.

---

## Screenshots

<img width="1080" height="2424" alt="image" src="https://github.com/user-attachments/assets/26a4ecba-ca68-4142-a73d-08e9670e40ae" />

<img width="1080" height="2424" alt="image1" src="https://github.com/user-attachments/assets/ef942799-40c1-43da-bca1-eec8a2e419de" />

<img width="1080" height="2424" alt="image2" src="https://github.com/user-attachments/assets/07d69782-17ce-4ff6-af3e-200d31e166be" />

## 🎯 Features

### 1. **Expense Management**
- ✅ Create and add new expenses with categories
- ✅ View comprehensive list of all expenses
- ✅ Edit and delete existing expenses
- ✅ Detailed expense information view with timestamps
- ✅ Custom expense list tile UI with quick actions

### 2. **Data Visualization**
- ✅ Interactive expense charts for visual analytics
- ✅ Spending pattern analysis
- ✅ Category-wise expense breakdown
- ✅ Date-range filtering for custom views

### 3. **Location Tracking**
- ✅ GPS-based location capture for expenses
- ✅ Interactive map view of expense locations
- ✅ Location-based expense history
- ✅ Custom map cards displaying location details

### 4. **Cloud Synchronization**
- ✅ Real-time sync with Firebase Firestore
- ✅ Automatic background synchronization (1-hour intervals)
- ✅ Conflict resolution for data consistency
- ✅ Sync status monitoring and notifications
- ✅ Manual sync trigger option

### 5. **Offline Support**
- ✅ Offline-first local storage using Isar database
- ✅ Automatic sync when connection is restored
- ✅ Full functionality without internet connection
- ✅ Data integrity and persistence

### 6. **Connectivity Management**
- ✅ Real-time network connectivity detection
- ✅ Connection status indicators
- ✅ Smart sync scheduling based on connectivity
- ✅ Battery-aware background sync

### 7. **Cross-Platform Support**
- ✅ Native iOS experience with Cupertino widgets
- ✅ Native Android experience with Material Design
- ✅ Web platform support
- ✅ Responsive UI across all screen sizes

---

## 🚀 User Flow

### **User Journey Map**

```
┌─────────────────────────────────────────────────────────────┐
│                      App Launch                             │
├─────────────────────────────────────────────────────────────┤
│                         │                                   │
│                    Check Auth                               │
│                         │                                   │
└──────────────┬──────────┴──────────────┬─────────────────────┘
               │                        │
         ┌─────▼──────┐          ┌─────▼──────┐
         │  Logged In │          │ Not Logged │
         └─────┬──────┘          └─────┬──────┘
               │                       │
        ┌──────▼─────────────────────┐ │
        │ Load Expenses from Isar    │ │
        │ (Offline-first approach)   │ │
        └──────┬─────────────────────┘ │
               │                       │
        ┌──────▼────────────────────────┐
        │   Display Home Screen         │
        │   - Expense List             │
        │   - Expense Charts           │
        │   - Sync Status              │
        └──────┬────────┬──────────┬────┘
               │        │          │
        ┌──────▼──┐ ┌──▼────┐ ┌──▼────┐
        │ Add New │ │ View  │ │  Sync │
        │Expense  │ │Detail │ │Station│
        └─────┬───┘ └───┬───┘ └───┬───┘
              │         │         │
         ┌────▼───┐ ┌──▼────┐ ┌──▼──────────┐
         │Get Loc │ │ Edit  │ │Monitor Sync │
         │GPS Info│ │Delete │ │Status       │
         └────┬───┘ └──┬────┘ └──┬──────────┘
              │        │         │
         ┌────▼────────▼─────────▼────┐
         │ Background Sync to Firebase │
         │ (1-hour intervals)          │
         └─────────────────────────────┘
```

### **Step-by-Step User Flow**

#### **1. App Launch & Initialization**
- App starts and loads Firebase configuration
- System checks device connectivity status
- Initializes local Isar database

#### **2. Home Screen**
- Displays list of all expenses from local storage
- Shows expense visualization charts
- Indicates current sync status
- Provides quick access to main features

#### **3. Adding a New Expense**
- User navigates to "Add Expense" screen
- Enters expense details:
  - Name/Description
  - Amount
  - Category
  - Date/Time
- App automatically captures GPS location
- Saves expense to local Isar database
- Queues for sync to Firebase

#### **4. Viewing Expense Details**
- User selects expense from list
- Detailed view shows:
  - All expense information
  - Location map with marker
  - Timestamps and metadata
- Options to edit or delete expense

#### **5. Expense Charts & Analytics**
- User views spending visualization
- Charts categorize expenses by type
- User can filter by date ranges
- Visual insights into spending patterns

#### **6. Sync Station**
- User manually checks sync status
- Monitors active synchronization
- Views connectivity state
- Manually triggers sync if needed

#### **7. Background Sync (Automatic)**
- Every 1 hour, background task runs
- Only when:
  - Device has internet connection
  - Battery level is adequate
- Syncs new/updated expenses to Firebase
- Resolves any conflicts with server data

#### **8. Offline Scenario**
- User creates/edits expenses without internet
- Data stored locally in Isar
- App marks data for sync when offline
- Upon reconnection, automatic sync begins

---

## 🛠️ Tech Stack

### **Mobile Development Framework**
| Technology | Version | Purpose |
|-----------|---------|---------|
| **Flutter** | Latest | Cross-platform mobile framework |
| **Dart** | ^3.11.4 | Programming language |

### **State Management & Architecture**
| Technology | Version | Purpose |
|-----------|---------|---------|
| **BLoC** | ^9.2.0 | Business Logic Component pattern |
| **flutter_bloc** | ^9.1.1 | Flutter integration for BLoC |

### **Local Data Storage**
| Technology | Version | Purpose |
|-----------|---------|---------|
| **Isar** | ^3.1.0+1 | High-performance local database |
| **isar_flutter_libs** | ^3.1.0+1 | Isar Flutter bindings |
| **path_provider** | ^2.1.5 | App directory access |

### **Cloud Services & Backend**
| Technology | Version | Purpose |
|-----------|---------|---------|
| **Firebase Core** | ^4.6.0 | Firebase initialization |
| **Cloud Firestore** | ^6.2.0 | Cloud database & sync |
| **Cloud Storage** | (Firebase) | File storage |

### **Location & Maps**
| Technology | Version | Purpose |
|-----------|---------|---------|
| **geolocator** | ^14.0.2 | GPS & geolocation services |
| **flutter_map** | ^8.3.0 | Interactive map rendering |
| **latlong2** | ^0.9.1 | Latitude/Longitude utilities |

### **Networking & Connectivity**
| Technology | Version | Purpose |
|-----------|---------|---------|
| **connectivity_plus** | ^7.1.0 | Network connectivity monitoring |

### **Background Processing**
| Technology | Version | Purpose |
|-----------|---------|---------|
| **workmanager** | ^0.9.0+3 | Background task scheduling |

### **Navigation & Routing**
| Technology | Version | Purpose |
|-----------|---------|---------|
| **GoRouter** | ^17.2.0 | Declarative routing & navigation |

### **UI & Design**
| Technology | Version | Purpose |
|-----------|---------|---------|
| **cupertino_icons** | ^1.0.8 | iOS-style icon library |

### **Utilities**
| Technology | Version | Purpose |
|-----------|---------|---------|
| **uuid** | ^4.5.3 | Unique identifier generation |

### **Development & Build Tools**
| Technology | Version | Purpose |
|-----------|---------|---------|
| **build_runner** | ^2.4.13 | Code generation framework |
| **isar_generator** | ^3.1.0+1 | Isar schema code generation |
| **flutter_lints** | ^6.0.0 | Dart/Flutter lint rules |
| **flutter_launcher_icons** | ^0.14.4 | App icon generation |

---

## 🏗️ Architecture

### **Clean Architecture Layers**

```
┌─────────────────────────────────────┐
│     Presentation Layer (UI)         │
│  - Screens, Widgets, BLoC, State   │
├─────────────────────────────────────┤
│      Domain Layer (Business Logic)  │
│  - Entities, Use Cases, Contracts  │
├─────────────────────────────────────┤
│       Data Layer (Data Sources)     │
│  - Repositories, Models, DTOs      │
│  - Isar (Local), Firebase (Remote) │
└─────────────────────────────────────┘
```

### **Design Patterns Used**

- **BLoC Pattern**: State management and business logic separation
- **Repository Pattern**: Data source abstraction
- **Dependency Injection**: Loose coupling between components
- **Offline-First**: Local-first synchronization approach
- **Singleton Pattern**: Firebase and Isar instances

---

## 📁 Project Structure

```
lib/
├── main.dart                          # App entry point
├── firebase_options.dart              # Firebase configuration
│
├── features/                          # Feature modules
│   ├── expenses/                      # Expense management feature
│   │   ├── data/
│   │   │   ├── expense.dart          # Isar model
│   │   │   ├── expense.g.dart        # Generated code
│   │   │   ├── repositories/
│   │   │   │   ├── expense_repository.dart
│   │   │   │   └── firebase_repository.dart
│   │   │   └── datasources/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── home_screen.dart
│   │       │   ├── add_expense_screen.dart
│   │       │   └── expense_detail_screen.dart
│   │       ├── widgets/
│   │       │   ├── custom_text_field.dart
│   │       │   ├── expense_list_tile.dart
│   │       │   ├── expense_chart.dart
│   │       │   ├── custom_map_card.dart
│   │       │   ├── custom_action_button.dart
│   │       │   └── custom_detail_header.dart
│   │       └── bloc/
│   │           ├── expense_bloc.dart
│   │           ├── expense_event.dart
│   │           └── expense_state.dart
│   │
│   └── sync_station/                 # Sync management feature
│       ├── data/
│       ├── domain/
│       └── presentation/
│           ├── screens/
│           │   └── sync_screen.dart
│           └── bloc/
│               ├── sync_bloc.dart
│               ├── sync_event.dart
│               └── sync_state.dart
│
├── core/                              # Core utilities & services
│   ├── background_sync.dart          # Background sync service
│   ├── location_service.dart         # GPS/Location service
│   ├── routing/
│   │   └── app_router.dart          # GoRouter configuration
│   ├── network/                      # Network utilities
│   └── theme/                        # Theme configuration

android/                              # Android platform code
ios/                                  # iOS platform code
web/                                  # Web platform code
windows/                              # Windows platform code
linux/                                # Linux platform code
macos/                                # macOS platform code
```

---

## 🔥 Firebase Configuration

### **Project Details**
- **Project ID**: `pocket-expense-tracker-app`
- **Services**: Cloud Firestore, Cloud Storage, Authentication

### **Firebase Enabled Platforms**
- ✅ **Android**
  - Project ID: `1:487965946836:android:84a04da994072a7461dc41`
  - Configuration: `google-services.json`

- ✅ **iOS**
  - Project ID: `1:487965946836:ios:3bcb8a264b80827761dc41`
  - Configuration: `GoogleService-Info.plist`

- ✅ **Web**
  - Project ID: `1:487965946836:web:4f2eb65f73b0d58061dc41`

### **Cloud Firestore Structure**
```
expenses/
├── {userId}/
│   ├── {expenseId}
│   │   ├── title: string
│   │   ├── amount: number
│   │   ├── category: string
│   │   ├── date: timestamp
│   │   ├── location: geopoint
│   │   └── metadata: map
```

---

## 🚀 Getting Started

### **Prerequisites**
- Flutter SDK: Latest stable version
- Dart: ^3.11.4 or higher
- Android Studio / Xcode (for platform-specific development)
- Firebase account with project setup
- Git for version control

### **Environment Setup**
1. Install Flutter from [flutter.dev](https://flutter.dev)
2. Clone the repository
3. Navigate to project directory
4. Run `flutter pub get` to fetch dependencies

---

## 🚀 Releases

### **Pre-Release Builds**
- **Android APK**: Pre-release `.apk` builds are available on the [GitHub Releases](https://github.com/chiragsharmaa36/pocket-expense-tracker-app/releases/) page
  - Download the latest `.apk` file for direct installation on Android devices
  - Ideal for testing and early feature access

---

## 💻 Installation & Setup

### **1. Clone Repository**
```bash
git clone <repository-url>
cd pocket_expense_tracker_app
```

### **2. Install Dependencies**
```bash
flutter pub get
```

### **3. Generate Code**
```bash
flutter pub run build_runner build
```

### **4. Firebase Setup**
- Download Firebase configuration files for your platform
- Place `google-services.json` in `android/app/`
- Place `GoogleService-Info.plist` in `ios/Runner/`

### **5. Run the App**

**Development (Debug)**
```bash
flutter run
```

**Release Build**
```bash
flutter build apk          # Android
flutter build ios          # iOS
flutter build web          # Web
```

---

## 📱 Usage

### **Adding an Expense**
1. Tap the "+" or "Add Expense" button
2. Enter expense details
3. App automatically captures location
4. Confirm and save

### **Viewing Expenses**
1. Home screen displays all expenses
2. Tap on expense to view details
3. View location on map
4. Edit or delete as needed

### **Tracking Sync Status**
1. Navigate to Sync Station
2. View current sync status
3. Check connectivity state
4. Manually trigger sync if needed

### **Offline Usage**
- All features work offline
- Data automatically syncs when connected
- No action required from user

---

## 🔧 Development

### **Build Commands**

**Generate necessary files**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Generate app icons**
```bash
flutter pub run flutter_launcher_icons:main
```

**Check code quality**
```bash
flutter analyze
```

**Run tests**
```bash
flutter test
```

### **Code Generation**
- **Isar Models**: Auto-generated from `expense.dart` annotations
- **BLoC Files**: Created manually using BLoC pattern
- **GoRouter Routes**: Defined in `app_router.dart`

---

## 📄 License

This project is created by **Chirag Sharma** for personal use.

---

## 📞 Support & Contact

For questions, issues, or feature requests, please contact the developer.

---

**Last Updated**: May 1, 2026  
**Version**: 1.0.0+1  
**Status**: Active Development
