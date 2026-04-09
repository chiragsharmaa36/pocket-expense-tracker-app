# Pocket Expense Tracker: Architecture & Developer Knowledge Base

## 1. Architectural Philosophy
This application strictly adheres to an **Offline-First Architecture**. 
* **The Single Source of Truth:** The local database (Isar) is the immediate source of truth for the UI. The app never waits for a network request to update the screen.
* **Eventual Consistency:** A background sync engine operates entirely decoupled from the UI, silently pushing local changes to the cloud (Firebase) whenever a reliable network is detected.
* **Conflict Prevention:** The app generates unique IDs (`UUID v4`) locally before saving to the local database. These UUIDs act as the document IDs in the cloud, preventing duplicate entries if a network request is interrupted.

---

## 2. Local Database: Isar & Android 16KB Compliance

### The 16KB Page Size Challenge
Android 15 introduced a strict requirement for native libraries (`.so` files) to use 16KB memory page alignment. 
* **The Problem:** Isar v3 relies on an older Rust-based engine (MDBX) compiled with 4KB alignment. This throws an `ELF alignment check failed` error on modern emulators.
* **The Solution:** We explicitly rely on Android's built-in **"Page Size Compatible Mode"**. Android safely wraps 4KB libraries to run on 16KB hardware without crashing.
* **The Alternative (Isar v4):** Isar v4 drops Rust for SQLite (via FFI), making it 100% 16KB compliant. However, it requires a completely synchronous architecture (`writeTxnSync`, `putSync`) and drops the custom `Id` type for standard `int` auto-increments. We deferred this migration due to its breaking changes and developer-preview status.

### Offline-First Entity Modeling
Models require specific flags to handle dual-database synchronization:
* `cloudId`: A locally generated `Uuid().v4()` string. Used as the primary key in Firestore.
* `isSynced`: A boolean flag defaulting to `false`. The sync engine specifically queries for items where `isSynced == false`.

---

## 3. State Management: The BLoC Pattern

### The Lazy Bloc Trap
By default, Flutter's `BlocProvider` is lazy; it will not execute a Bloc's constructor until a UI widget explicitly reads it. 
* **The Bug:** Background engines (like a `SyncBloc`) will completely fail to start if they don't have an attached UI.
* **The Fix:** Inject `lazy: false` into the `BlocProvider` in `main.dart` to force immediate instantiation on app launch.

### Separation of Concerns
The app uses domain-driven design for its Blocs:
* `ExpenseBloc`: Strictly handles CRUD operations for the local Isar database and UI updates.
* `SyncBloc`: Strictly handles network detection, fetching pending items, and triggering Firebase uploads. Moved to a dedicated `sync_station` directory to allow scaling (syncing categories, settings, etc., independent of the expense UI).

---

## 4. The Enterprise Sync Engine (Network Resiliency)

### The Captive Portal Trap
Relying solely on `connectivity_plus` is dangerous. It only verifies hardware connection to a router (e.g., hotel Wi-Fi), not actual internet access.
* **The Fix:** Implemented a native DNS ping to verify real-world internet before attempting database operations.
* **Implementation:** `InternetAddress.lookup('google.com').timeout(Duration(seconds: 3))` ensures the app does not hang on broken networks.

### The Android Emulator Broadcast Bug
On Android emulators, the OS frequently fails to broadcast `Intent` changes when toggling network states (like Airplane mode). This causes `Connectivity().onConnectivityChanged.listen()` to remain silent.
* **The Fix (The Fallback Poller):** Engineered a hybrid listener/polling system. The `SyncBloc` starts a `Timer.periodic` every 15 seconds. If `pendingItems > 0`, it manually pings the internet and forces a sync, bypassing the broken OS intent system.

### Sync Pipeline Execution
1. Fetch all items where `isSynced == false` from local Isar.
2. Iterate and push to Firestore using `.set(data, SetOptions(merge: true))` (Upsert behavior).
3. If Firebase succeeds, update local item `isSynced = true`.
4. Trigger UI Bloc refresh.
5. All wrapped in `try/catch` to emit `SyncFailure` safely on network drops.

---

## 5. Firebase Cloud Firestore Integration

### Project vs. App Hierarchy
* **Firebase Project:** The central cloud container holding the database and rules.
* **Firebase Apps:** The platform-specific configurations (Android, iOS) that act as "doors" allowing client code to access the project. Initialized via `flutterfire configure`.

### The `(default)` Database Naming Quirk
When manually creating a Firestore database via Google Cloud Console instead of the Firebase UI, the database ID must explicitly be named `(default)` with parentheses. 
* **The Bug:** Naming it `default` without parentheses creates a secondary instance that the standard Flutter SDK cannot find, resulting in persistent `NOT_FOUND` Stream closed errors.

### Security Rules (Development Phase)
Firestore blocks all reads/writes by default. For offline-sync testing without authentication, rules must be explicitly set to open in the Firebase Console:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true; 
    }
  }
}