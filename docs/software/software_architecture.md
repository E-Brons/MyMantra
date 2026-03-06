# Software Architecture Document (SAD)
## MyMantra - Spiritual Practice Application

**Version:** 0.2
**Date:** March 2026
**Status:** Draft
**Application Name:** MyMantra

---

## 1. Introduction

### 1.1 Purpose
This document describes the software architecture of **MyMantra**, including architectural patterns, component structure, data flow, and technology stack decisions.

### 1.2 Scope
This document covers:
- High-level system architecture
- Component design and responsibilities
- Data architecture and persistence
- Cross-cutting concerns
- Technology choices and rationale
- Deployment architecture

### 1.3 Architectural Goals
1. **Offline-First**: Full functionality without network connectivity
2. **Cross-Platform**: Single codebase for iOS, Android, macOS, Web, Windows
3. **Performance**: Responsive UI with <50ms tap response
4. **Maintainability**: Clean separation of concerns, testable code
5. **Privacy**: Local-first data, user-controlled cloud storage
6. **Scalability**: Support 1000+ mantras, 10K+ sessions
7. **Data Ownership**: User's cloud storage (iCloud/Google Drive) for sync
8. **Multi-Device**: Seamless sync across user's devices

---

## 2. Architectural Patterns

### 2.1 Primary Pattern: Clean Architecture

```
┌─────────────────────────────────────────────────────────┐
│                     Presentation Layer                  │
│  ┌──────────────────────────────────────────────────┐  │
│  │  UI Widgets (Flutter)                            │  │
│  │  - Screens, Dialogs, Components                  │  │
│  └─────────────────┬────────────────────────────────┘  │
│                    │                                     │
│  ┌─────────────────▼────────────────────────────────┐  │
│  │  State Management (Riverpod)                     │  │
│  │  - Providers, Notifiers, State Classes           │  │
│  └─────────────────┬────────────────────────────────┘  │
└────────────────────┼─────────────────────────────────────┘
                     │
┌────────────────────▼─────────────────────────────────────┐
│                     Domain Layer                         │
│  ┌──────────────────────────────────────────────────┐   │
│  │  Use Cases / Interactors                         │   │
│  │  - CreateMantra, StartSession, CalculateStreak   │   │
│  └─────────────────┬────────────────────────────────┘   │
│                    │                                      │
│  ┌─────────────────▼────────────────────────────────┐   │
│  │  Domain Entities (Pure Dart)                     │   │
│  │  - Mantra, Session, Progress (business objects)  │   │
│  └─────────────────┬────────────────────────────────┘   │
│                    │                                      │
│  ┌─────────────────▼────────────────────────────────┐   │
│  │  Repository Interfaces (Abstract)                │   │
│  └─────────────────┬────────────────────────────────┘   │
└────────────────────┼──────────────────────────────────────┘
                     │
┌────────────────────▼─────────────────────────────────────┐
│                      Data Layer                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │  Repository Implementations                      │   │
│  │  - MantraRepositoryImpl, SessionRepositoryImpl   │   │
│  └─────────────────┬────────────────────────────────┘   │
│                    │                                      │
│  ┌─────────────────▼────────────────────────────────┐   │
│  │  Data Sources                                    │   │
│  │  - LocalDataSource (Isar)                        │   │
│  │  - CloudDataSource (Google Drive, iCloud)        │   │
│  │  - AudioDataSource (Voice Recordings)            │   │
│  └─────────────────┬────────────────────────────────┘   │
│                    │                                      │
│  ┌─────────────────▼────────────────────────────────┐   │
│  │  Data Models (Isar Collections)                  │   │
│  │  - MantraModel, SessionModel (with annotations)  │   │
│  └──────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────┘
```

### 2.2 State Management Pattern: Riverpod

**Choice Rationale**:
- Compile-time safety (vs Provider)
- No BuildContext dependency
- Excellent for offline-first (state caching)
- Testability without mocking

**Key Providers**:
```dart
// Domain
final mantrasProvider = FutureProvider<List<Mantra>>(...);
final sessionStateProvider = NotifierProvider<SessionNotifier, SessionState>(...);
final progressProvider = StreamProvider<Progress>(...);

// Infrastructure
// Phase 1.0 (current): SharedPreferences-backed StorageService
final storageServiceProvider = Provider<StorageService>(...);
// Phase 2.0+ (planned): replace with Isar
// final databaseProvider = Provider<IsarDatabase>(...);
final notificationServiceProvider = Provider<NotificationService>(...);
```

### 2.3 Dependency Injection

All dependencies injected via Riverpod providers:
```dart
final mantraRepositoryProvider = Provider<MantraRepository>(
  (ref) => MantraRepositoryImpl(
    localDataSource: ref.watch(localDataSourceProvider),
  ),
);
```

---

## 3. Component Architecture

### 3.1 Module Structure

> **Phase 1.0 (current):** simplified layout with a flat `core/` for models, providers, services, and utils; features do not yet have per-feature data/domain/presentation sub-trees.  See [folder_structure.md](folder_structure.md) for the live directory layout.
>
> **Phase 2.0+ (target):** full clean-architecture per-feature breakdown shown below.

```
lib/
├── main.dart                    # App entry point
└── src/
    ├── app/
    │   ├── app.dart             # MaterialApp configuration
    │   ├── router.dart          # go_router ShellRoute + bottom nav
    │   └── theme/               # app_colors.dart, app_theme.dart
    ├── core/
    │   ├── constants/           # App-wide constants
    │   ├── error/               # Failure classes
    │   ├── models/              # Shared domain models (Phase 1.0)
    │   ├── providers/           # Top-level Riverpod providers (Phase 1.0)
    │   ├── services/            # StorageService, HapticService, NotificationService
    │   └── utils/               # Date/timezone utilities, streak logic
    ├── features/
    │   ├── mantras/             # User mantra management
    │   │   ├── data/            # (Phase 2.0+ target)
    │   │   ├── domain/          # (Phase 2.0+ target)
    │   │   └── presentation/    # screens, widgets, providers
    │   ├── session/             # Repetition counter + timer
    │   ├── library/             # Built-in mantra library
    │   ├── progress/            # Streak and stats
    │   └── settings/            # User preferences
    └── shared/
        └── widgets/             # AppScaffold, cross-feature components
```

### 3.2 Feature Module Pattern

Each feature (mantras, session, reminders, etc.) follows:
- **Data Layer**: Models, data sources, repository implementations
- **Domain Layer**: Entities, repository interfaces, use cases
- **Presentation Layer**: Screens, widgets, state providers

**Benefits**:
- High cohesion within features
- Low coupling between features
- Easy to test in isolation
- Supports incremental development

---

## 4. Data Architecture

### 4.1 Database Architecture

#### Phase 1.0 (current) — SharedPreferences JSON

The MVP persists all data as serialized JSON through `StorageService` (`lib/src/core/services/storage_service.dart`) backed by SharedPreferences. This is sufficient for the typical data volumes of a single user's mantra collection and session history.

**Trade-offs:** no indexed queries, no real-time streams, full read/write on every operation. Acceptable for Phase 1.0; a migration path to Isar is planned for Phase 2.0 when per-mantra session history and search performance matter.

#### Phase 2.0+ (planned) — Isar (NoSQL embedded database)

**Technology**: Isar (NoSQL embedded database)

**Schema Design**:

```dart
// data/models/mantra_model.dart
@collection
class MantraModel {
  Id id = Isar.autoIncrement;
  
  @Index(type: IndexType.value)
  late String uuid;  // For external references
  
  late String title;
  late String text;
  late int targetRepetitions;
  late DateTime createdAt;
  late DateTime updatedAt;
  late bool isCustom;
  
  // Computed
  @Ignore()
  String get textPreview => text.substring(0, min(50, text.length));
}

// Relationships
@collection
class ReminderModel {
  Id id = Isar.autoIncrement;
  late String uuid;
  
  @Index()
  late String mantraUuid;  // Foreign key
  
  late String time;
  late List<int> daysOfWeek;
  late bool isEnabled;
  late String notificationSound;
}

@collection
class SessionModel {
  Id id = Isar.autoIncrement;
  late String uuid;
  
  @Index()
  late String mantraUuid;
  
  @Index()
  late DateTime timestamp;
  
  late int repetitionsCompleted;
  late int durationSeconds;
  late bool wasFromReminder;
}

@collection
class ProgressModel {
  Id id = 1;  // Singleton
  
  late int currentStreak;
  late int longestStreak;
  DateTime? lastSessionDate;
  late int totalSessions;
  late int totalRepetitions;
  late List<String> unlockedAchievements;
  late DateTime updatedAt;
}
```

**Indexes**:
- `uuid` on all collections (for external references)
- `mantraUuid` on reminders and sessions (for joins)
- `timestamp` on sessions (for date queries)

**Query Examples**:
```dart
// Get mantra with reminders
final mantra = await isar.mantraModels.filter().uuidEqualTo(id).findFirst();
final reminders = await isar.reminderModels
  .filter()
  .mantraUuidEqualTo(mantra.uuid)
  .findAll();

// Get sessions for date range
final sessions = await isar.sessionModels
  .filter()
  .timestampBetween(startDate, endDate)
  .sortByTimestampDesc()
  .findAll();

// Full-text search on mantras
final results = await isar.mantraModels
  .filter()
  .titleContains(query, caseSensitive: false)
  .or()
  .textContains(query, caseSensitive: false)
  .findAll();
```

### 4.2 Data Mapping (Data ↔ Domain)

**Mappers** convert between data models (Isar) and domain entities (pure Dart):

```dart
// data/models/mantra_model.dart
extension MantraModelMapper on MantraModel {
  Mantra toDomain() {
    return Mantra(
      id: uuid,
      title: title,
      text: text,
      targetRepetitions: targetRepetitions,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isCustom: isCustom,
    );
  }
}

extension MantraEntityMapper on Mantra {
  MantraModel toModel() {
    return MantraModel()
      ..uuid = id
      ..title = title
      ..text = text
      ..targetRepetitions = targetRepetitions
      ..createdAt = createdAt
      ..updatedAt = updatedAt
      ..isCustom = isCustom;
  }
}
```

### 4.3 Repository Pattern

**Interface** (domain layer):
```dart
// domain/repositories/mantra_repository.dart
abstract class MantraRepository {
  Future<Either<Failure, List<Mantra>>> getAllMantras();
  Future<Either<Failure, Mantra>> getMantraById(String id);
  Future<Either<Failure, Mantra>> createMantra(Mantra mantra);
  Future<Either<Failure, Mantra>> updateMantra(Mantra mantra);
  Future<Either<Failure, void>> deleteMantra(String id);
  Stream<List<Mantra>> watchMantras();
}
```

**Implementation** (data layer):
```dart
// data/repositories/mantra_repository_impl.dart
class MantraRepositoryImpl implements MantraRepository {
  final LocalMantraDataSource localDataSource;
  
  MantraRepositoryImpl({required this.localDataSource});
  
  @override
  Future<Either<Failure, List<Mantra>>> getAllMantras() async {
    try {
      final models = await localDataSource.getAllMantras();
      final entities = models.map((m) => m.toDomain()).toList();
      return Right(entities);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }
  
  @override
  Stream<List<Mantra>> watchMantras() {
    return localDataSource.watchMantras()
      .map((models) => models.map((m) => m.toDomain()).toList());
  }
  
  // ... other methods
}
```

**Benefits**:
- Domain layer independent of database technology
- Easy to swap Isar → Drift or add remote data source
- Testable with mocks

---

## 5. Cross-Cutting Concerns

### 5.1 Notification Service

**Architecture**:
```dart
// shared/services/notification_service.dart
abstract class NotificationService {
  Future<void> initialize();
  Future<bool> requestPermission();
  Future<void> scheduleNotification({
    required String id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required Map<String, String> payload,
  });
  Future<void> cancelNotification(String id);
  Future<void> cancelAllNotifications();
  Stream<NotificationResponse> get onNotificationTap;
}

class FlutterLocalNotificationService implements NotificationService {
  final FlutterLocalNotificationsPlugin _plugin;
  
  // Platform-specific implementation
  @override
  Future<void> scheduleNotification(...) async {
    await _plugin.zonedSchedule(
      id.hashCode,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: ...,
      payload: jsonEncode(payload),
    );
  }
}
```

**Integration with Reminders**:
```dart
// features/reminders/domain/usecases/schedule_reminder.dart
class ScheduleReminder {
  final NotificationService notificationService;
  
  Future<void> call(Reminder reminder) async {
    for (final day in reminder.daysOfWeek) {
      final nextOccurrence = _calculateNextOccurrence(
        time: reminder.time,
        dayOfWeek: day,
      );
      
      await notificationService.scheduleNotification(
        id: '${reminder.id}_$day',
        title: 'Time to practice',
        body: 'Your mantra awaits',
        scheduledTime: nextOccurrence,
        payload: {
          'type': 'reminder',
          'reminderId': reminder.id,
          'mantraId': reminder.mantraId,
        },
      );
    }
  }
}
```

### 5.2 Cloud Sync Service (Phase 2.0)

**Architecture Pattern**: Strategy Pattern for multi-provider support

```dart
// shared/services/cloud_sync_service.dart
abstract class CloudSyncService {
  Future<void> initialize();
  Future<bool> isAuthenticated();
  Future<void> authenticate();
  Future<void> signOut();
  Future<void> uploadBackup(Map<String, dynamic> data);
  Future<Map<String, dynamic>?> downloadBackup();
  Future<DateTime?> getLastSyncTime();
  Stream<SyncStatus> get syncStatusStream;
}

// Platform-specific implementations
class GoogleDriveSync implements CloudSyncService {
  final GoogleSignIn _googleSignIn;
  final DriveApi _driveApi;

  @override
  Future<void> uploadBackup(Map<String, dynamic> data) async {
    final jsonContent = jsonEncode(data);
    final mediaUpload = Media(
      Stream.value(utf8.encode(jsonContent)),
      jsonContent.length,
    );

    // Upload to app-specific folder
    final file = drive.File()
      ..name = 'mantra_backup.json'
      ..parents = [await _getAppFolderId()];

    await _driveApi.files.create(file, uploadMedia: mediaUpload);
  }

  @override
  Future<Map<String, dynamic>?> downloadBackup() async {
    final file = await _findBackupFile();
    if (file == null) return null;

    final media = await _driveApi.files.get(
      file.id!,
      downloadOptions: DownloadOptions.fullMedia,
    ) as Media;

    final jsonString = await utf8.decodeStream(media.stream);
    return jsonDecode(jsonString);
  }
}

class ICloudSync implements CloudSyncService {
  // Platform channel to native iOS CloudKit implementation
  static const platform = MethodChannel('com.mymantra/icloud');

  @override
  Future<void> uploadBackup(Map<String, dynamic> data) async {
    await platform.invokeMethod('uploadBackup', {
      'data': jsonEncode(data),
      'filename': 'mantra_backup.json',
    });
  }

  @override
  Future<Map<String, dynamic>?> downloadBackup() async {
    final jsonString = await platform.invokeMethod<String>('downloadBackup');
    if (jsonString == null) return null;
    return jsonDecode(jsonString);
  }
}
```

**Sync Strategy**:
```dart
// features/sync/domain/usecases/sync_data.dart
class SyncData {
  final CloudSyncService cloudService;
  final MantraRepository mantraRepository;
  final SessionRepository sessionRepository;
  final ProgressRepository progressRepository;

  Future<Either<Failure, void>> call() async {
    try {
      // 1. Collect local data
      final localData = await _gatherLocalData();

      // 2. Download cloud data
      final cloudData = await cloudService.downloadBackup();

      // 3. Merge with conflict resolution (last-write-wins)
      final mergedData = _mergeData(localData, cloudData);

      // 4. Update local database
      await _updateLocalDatabase(mergedData);

      // 5. Upload merged data to cloud
      await cloudService.uploadBackup(mergedData);

      return Right(null);
    } on CloudSyncException catch (e) {
      return Left(CloudSyncFailure(e.message));
    }
  }

  Map<String, dynamic> _mergeData(
    Map<String, dynamic> local,
    Map<String, dynamic>? cloud,
  ) {
    if (cloud == null) return local;

    // Last-write-wins based on updatedAt timestamps
    final mergedMantras = _mergeEntities(
      local['mantras'] as List,
      cloud['mantras'] as List,
    );

    // Sessions are append-only, merge all unique
    final mergedSessions = _appendUniqueSessions(
      local['sessions'] as List,
      cloud['sessions'] as List,
    );

    // Progress takes maximum values
    final mergedProgress = _mergeProgress(
      local['progress'] as Map,
      cloud['progress'] as Map,
    );

    return {
      'version': '1.0',
      'syncedAt': DateTime.now().toIso8601String(),
      'mantras': mergedMantras,
      'reminders': _mergeEntities(local['reminders'], cloud['reminders']),
      'sessions': mergedSessions,
      'progress': mergedProgress,
    };
  }
}
```

**Background Sync**:
```dart
// Automatic sync every 15 minutes when app is active
class AutoSyncService {
  final SyncData syncUseCase;
  Timer? _syncTimer;

  void startAutoSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(
      Duration(minutes: 15),
      (_) async {
        if (await _hasNetworkConnection()) {
          await syncUseCase.call();
        }
      },
    );
  }

  void stopAutoSync() {
    _syncTimer?.cancel();
  }
}
```

**Data Format** (Cloud Backup JSON):
```json
{
  "version": "1.0",
  "syncedAt": "2025-11-24T10:30:00Z",
  "mantras": [
    {
      "id": "uuid-1",
      "title": "Om Mani Padme Hum",
      "text": "ॐ मणिपद्मे हूँ",
      "targetRepetitions": 108,
      "createdAt": "2025-11-01T08:00:00Z",
      "updatedAt": "2025-11-24T08:00:00Z",
      "isCustom": true,
      "voiceRecordingUrl": "recordings/uuid-1.aac"
    }
  ],
  "reminders": [...],
  "sessions": [...],
  "progress": {
    "currentStreak": 7,
    "longestStreak": 14,
    "totalSessions": 42,
    "totalRepetitions": 4536,
    "unlockedAchievements": ["ACH-001", "ACH-002", "ACH-003"]
  },
  "audioRecordings": {
    "uuid-1": "base64-encoded-audio-data"
  }
}
```

### 5.3 Audio Recording Service (Phase 2.0)

```dart
// shared/services/audio_service.dart
abstract class AudioService {
  Future<void> initialize();
  Future<bool> requestPermission();
  Future<String> startRecording();
  Future<void> stopRecording();
  Future<void> playAudio(String filePath);
  Future<void> pauseAudio();
  Future<void> stopAudio();
  Stream<Duration> get playbackPosition;
  Future<Duration?> getAudioDuration(String filePath);
}

class FlutterAudioService implements AudioService {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  @override
  Future<String> startRecording() async {
    final path = '${await getApplicationDocumentsDirectory()}/recordings/${Uuid().v4()}.aac';

    await _recorder.start(
      RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 64000, // 64kbps for good quality, small size
        sampleRate: 44100,
      ),
      path: path,
    );

    return path;
  }

  @override
  Future<void> playAudio(String filePath) async {
    await _player.play(DeviceFileSource(filePath));
  }

  @override
  Stream<Duration> get playbackPosition {
    return _player.positionStream.map((pos) => pos ?? Duration.zero);
  }
}
```

**Integration with Session** (Audio Playback Mode):
```dart
// features/session/presentation/providers/session_provider.dart
class SessionNotifier extends StateNotifier<SessionState> {
  final AudioService audioService;

  Future<void> startAudioSession(Mantra mantra) async {
    if (mantra.voiceRecordingPath != null) {
      // Play user's recording on loop
      await audioService.playAudio(mantra.voiceRecordingPath!);

      // Listen for playback completion, restart
      audioService.playbackPosition.listen((position) async {
        final duration = await audioService.getAudioDuration(mantra.voiceRecordingPath!);
        if (position >= duration!) {
          await audioService.playAudio(mantra.voiceRecordingPath!);
        }
      });
    }
  }
}
```

### 5.4 Haptic Feedback Service

```dart
// shared/services/haptic_service.dart
abstract class HapticService {
  Future<void> lightImpact();
  Future<void> mediumImpact();
  Future<void> heavyImpact();
  Future<void> selectionClick();
}

class FlutterHapticService implements HapticService {
  @override
  Future<void> mediumImpact() async {
    if (await HapticFeedback.vibrate()) {
      await HapticFeedback.mediumImpact();
    }
  }
}
```

### 5.5 Error Handling

**Failure Classes**:
```dart
// core/error/failures.dart
abstract class Failure {
  final String message;
  const Failure(this.message);
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class NotificationPermissionFailure extends Failure {
  const NotificationPermissionFailure(super.message);
}
```

**Either Type** (using dartz or fpdart):
```dart
// Use case example
class CreateMantra {
  final MantraRepository repository;
  
  Future<Either<Failure, Mantra>> call(CreateMantraParams params) async {
    // Validation
    if (params.title.isEmpty) {
      return Left(ValidationFailure('Title cannot be empty'));
    }
    
    // Create entity
    final mantra = Mantra(
      id: Uuid().v4(),
      title: params.title,
      text: params.text,
      targetRepetitions: params.targetRepetitions,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isCustom: true,
    );
    
    // Persist
    return await repository.createMantra(mantra);
  }
}
```

**UI Error Display**:
```dart
// presentation layer
result.fold(
  (failure) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(failure.message)),
  ),
  (mantra) => Navigator.pop(context),
);
```

### 5.4 Logging

```dart
// core/utils/logger.dart
class Logger {
  static void d(String message) => developer.log(message, level: 500);
  static void i(String message) => developer.log(message, level: 800);
  static void w(String message) => developer.log(message, level: 900);
  static void e(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(message, level: 1000, error: error, stackTrace: stackTrace);
  }
}
```

---

## 6. Use Case Examples

### 6.1 UC-1: Start Session Flow

```
User taps "Start Session" on mantra
         ↓
┌────────▼─────────────────────────────────────────────┐
│ Presentation: SessionScreen                          │
│   • Dispatch StartSession action                     │
└────────┬──────────────────────────────────────────────┘
         ↓
┌────────▼─────────────────────────────────────────────┐
│ State: SessionNotifier                               │
│   • Create SessionState (counter=0, timer started)   │
│   • Notify listeners                                 │
└────────┬──────────────────────────────────────────────┘
         ↓
┌────────▼─────────────────────────────────────────────┐
│ Presentation: SessionScreen rebuilds                 │
│   • Display full-screen UI                           │
│   • Register tap listener                            │
└──────────────────────────────────────────────────────┘

User taps screen
         ↓
┌────────▼─────────────────────────────────────────────┐
│ Presentation: onTap handler                          │
│   • Dispatch IncrementCounter action                 │
└────────┬──────────────────────────────────────────────┘
         ↓
┌────────▼─────────────────────────────────────────────┐
│ State: SessionNotifier                               │
│   • Increment counter                                │
│   • Trigger haptic feedback                          │
│   • Check if target reached                          │
│   • Notify listeners                                 │
└────────┬──────────────────────────────────────────────┘
         ↓
┌────────▼─────────────────────────────────────────────┐
│ Presentation: UI updates                             │
│   • Counter text changes                             │
│   • Progress bar fills                               │
│   • Haptic feedback felt                             │
└──────────────────────────────────────────────────────┘

User taps "Complete" OR target reached
         ↓
┌────────▼─────────────────────────────────────────────┐
│ State: SessionNotifier                               │
│   • Dispatch CompleteSession action                  │
└────────┬──────────────────────────────────────────────┘
         ↓
┌────────▼─────────────────────────────────────────────┐
│ Domain: CompleteSession use case                     │
│   1. Create Session entity                           │
│   2. Save via SessionRepository                      │
│   3. Update Progress via UpdateProgress use case     │
│   4. Check achievements via CheckAchievements        │
└────────┬──────────────────────────────────────────────┘
         ↓
┌────────▼─────────────────────────────────────────────┐
│ Data: SessionRepositoryImpl                          │
│   • Map entity → model                               │
│   • Insert into Isar                                 │
│   • Return success                                   │
└────────┬──────────────────────────────────────────────┘
         ↓
┌────────▼─────────────────────────────────────────────┐
│ Domain: UpdateProgress                               │
│   • Load current progress                            │
│   • Calculate new streak                             │
│   • Increment totals                                 │
│   • Save updated progress                            │
└────────┬──────────────────────────────────────────────┘
         ↓
┌────────▼─────────────────────────────────────────────┐
│ Domain: CheckAchievements                            │
│   • Evaluate all achievement conditions              │
│   • Return newly unlocked achievements               │
└────────┬──────────────────────────────────────────────┘
         ↓
┌────────▼─────────────────────────────────────────────┐
│ Presentation: Show success UI                        │
│   • Play celebration animation                       │
│   • Show achievement notifications                   │
│   • Navigate back to home                            │
└──────────────────────────────────────────────────────┘
```

### 6.2 UC-2: Notification to Session Flow

```
OS triggers scheduled notification
         ↓
┌────────▼─────────────────────────────────────────────┐
│ NotificationService: onNotificationTap stream        │
│   • Extract payload (mantraId, reminderId)           │
└────────┬──────────────────────────────────────────────┘
         ↓
┌────────▼─────────────────────────────────────────────┐
│ App: Deep link handler                               │
│   • Parse route: /session/:mantraId?from=reminder    │
│   • Navigate to SessionScreen                        │
└────────┬──────────────────────────────────────────────┘
         ↓
┌────────▼─────────────────────────────────────────────┐
│ Presentation: SessionScreen                          │
│   • Load mantra details                              │
│   • Set wasFromReminder = true                       │
│   • Start session (same as UC-1)                     │
└──────────────────────────────────────────────────────┘
```

---

## 7. Technology Stack

### 7.1 Core Technologies

| Layer | Technology | Version | Rationale |
|-------|-----------|---------|-----------|
| Framework | Flutter | 3.16+ | Cross-platform, high performance, mature |
| Language | Dart | 3.2+ | Type-safe, null-safe, async/await |
| State Management | Riverpod | 2.5+ | Compile-time safety, testability, no context |
| Database | SharedPreferences JSON (Phase 1.0) / Isar 3.1+ (Phase 2.0+) | — | Zero-config JSON for MVP; Isar for indexed queries and scale |
| Routing | go_router | 14.0+ | Declarative routing, deep links |
| Notifications | flutter_local_notifications | 17.0+ | Cross-platform, reliable |

### 7.2 Supporting Packages

| Package | Purpose | Phase |
|---------|---------|-------|
| uuid | Generate unique IDs | 1.0 |
| intl | Internationalization (date formatting) | 1.0 |
| fpdart | Functional programming (Either, Option) | 1.0 |
| equatable | Value equality for entities | 1.0 |
| freezed | Immutable classes, unions | 1.0 |
| flutter_hooks | Reusable stateful logic | 1.0 |
| haptic_feedback | Vibration control | 1.0 |
| path_provider | File system access | 1.0 |
| timezone | Timezone handling for notifications | 1.0 |
| **google_sign_in** | Google OAuth authentication | **2.0** |
| **googleapis** | Google Drive API | **2.0** |
| **sign_in_with_apple** | Apple authentication | **2.0** |
| **record** | Audio recording | **2.0** |
| **audioplayers** | Audio playback | **2.0** |
| **connectivity_plus** | Network status checking | **2.0** |

### 7.3 Development Tools

| Tool | Purpose |
|------|---------|
| build_runner | Code generation (Isar, Freezed) |
| flutter_lints | Static analysis |
| mocktail | Mocking for tests |
| golden_toolkit | Screenshot testing |
| integration_test | E2E testing |

---

## 8. Performance Considerations

### 8.1 Database Optimization

**Strategies**:
1. **Lazy loading**: Load mantra text only when needed (detail view)
2. **Pagination**: Session history loaded in chunks (50 at a time)
3. **Indexes**: All foreign keys and frequently queried fields indexed
4. **Batch operations**: Bulk inserts for initial data

**Example**:
```dart
// Bad: Load all sessions at once
final allSessions = await isar.sessionModels.where().findAll();

// Good: Paginated loading
final page1 = await isar.sessionModels
  .where()
  .sortByTimestampDesc()
  .limit(50)
  .findAll();
```

### 8.2 UI Performance

**Strategies**:
1. **Const constructors**: Use `const` for static widgets
2. **RepaintBoundary**: Wrap expensive widgets to isolate repaints
3. **ListView.builder**: For long lists (mantras, sessions)
4. **Debouncing**: Search input debounced 300ms

**Counter optimization**:
```dart
// Isolate counter updates to minimize rebuilds
class CounterDisplay extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(sessionStateProvider.select((s) => s.count));
    
    return RepaintBoundary(
      child: Text(
        '$count',
        style: Theme.of(context).textTheme.displayLarge,
      ),
    );
  }
}
```

### 8.3 Memory Management

- **Stream disposal**: All stream subscriptions cancelled in dispose
- **Image caching**: Limited cache size for achievement icons
- **Database queries**: Use `findFirst()` instead of `findAll()` when single result expected

---

## 9. Security Architecture

### 9.1 Data Security

**At Rest**:
- Phase 1.0: SharedPreferences storage — encrypted by device OS (iOS: Data Protection, Android: Full Disk Encryption)
- Phase 2.0+: Isar database — same OS-level encryption, no custom layer (KISS principle)

**In Transit** (Phase 2):
- Cloud sync via HTTPS only
- OAuth2 tokens for authentication
- No API keys stored in code

### 9.2 Code Security

- **No hardcoded secrets**: All sensitive config in environment variables
- **Dependency scanning**: Regular updates for security patches
- **Code obfuscation**: Flutter build with `--obfuscate` flag for release

---

## 10. Deployment Architecture

### 10.1 Build Configurations

```yaml
# iOS (ios/Runner.xcodeproj)
Debug:
  - Simulator builds
  - Debugging enabled
  - No obfuscation
  
Release:
  - App Store distribution
  - Obfuscated
  - Optimized
  
# Android (android/app/build.gradle)
debug:
  - Debug signing
  - Debugging enabled
  
release:
  - Release keystore
  - Obfuscated with R8
  - Shrunk resources
```

### 10.2 CI/CD Pipeline (Future)

```
┌─────────────┐
│   Git Push  │
└──────┬──────┘
       │
┌──────▼──────────────────────────────────────┐
│ GitHub Actions / GitLab CI                  │
│  1. Run linter (flutter analyze)            │
│  2. Run tests (flutter test)                │
│  3. Build APK/IPA                            │
│  4. Run integration tests                   │
│  5. Deploy to TestFlight / Internal Testing │
└──────┬──────────────────────────────────────┘
       │
┌──────▼──────────────────────────────────────┐
│ Manual Review & Approval                    │
└──────┬──────────────────────────────────────┘
       │
┌──────▼──────────────────────────────────────┐
│ Deploy to App Store / Play Store            │
└─────────────────────────────────────────────┘
```

---

## 11. Testing Strategy

### 11.1 Test Pyramid

```
        ┌──────────────┐
        │   E2E Tests  │  10% (Critical user flows)
        └──────────────┘
       ┌────────────────┐
       │  Widget Tests  │  30% (UI components)
       └────────────────┘
      ┌──────────────────┐
      │   Unit Tests     │  60% (Business logic, use cases)
      └──────────────────┘
```

### 11.2 Test Examples

**Unit Test** (Use Case):
```dart
// test/features/mantras/domain/usecases/create_mantra_test.dart
void main() {
  late CreateMantra useCase;
  late MockMantraRepository mockRepository;
  
  setUp(() {
    mockRepository = MockMantraRepository();
    useCase = CreateMantra(repository: mockRepository);
  });
  
  test('should create mantra successfully', () async {
    // Arrange
    final params = CreateMantraParams(
      title: 'Om Mani Padme Hum',
      text: 'ॐ मणिपद्मे हूँ',
      targetRepetitions: 108,
    );
    
    when(() => mockRepository.createMantra(any()))
      .thenAnswer((_) async => Right(mantra));
    
    // Act
    final result = await useCase(params);
    
    // Assert
    expect(result, isA<Right>());
    verify(() => mockRepository.createMantra(any())).called(1);
  });
}
```

**Widget Test**:
```dart
// test/features/mantras/presentation/widgets/mantra_card_test.dart
void main() {
  testWidgets('MantraCard displays title and preview', (tester) async {
    // Arrange
    final mantra = Mantra(
      id: '1',
      title: 'Test Mantra',
      text: 'This is a test mantra text',
      targetRepetitions: 108,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isCustom: true,
    );
    
    // Act
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: MantraCard(mantra: mantra))),
    );
    
    // Assert
    expect(find.text('Test Mantra'), findsOneWidget);
    expect(find.text('