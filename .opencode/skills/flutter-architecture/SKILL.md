---
name: flutter-architecture
description: Enforces Clean Architecture principles and state management patterns in Flutter.
---

# Flutter Clean Architecture Guidelines

When adding or modifying feature modules:

1. **Directory Layout**:
   - `lib/features/<feature_name>/domain/` (Entities, Repository Interfaces, Use Cases)
   - `lib/features/<feature_name>/data/` (Models, Data Sources, Repository Implementations)
   - `lib/features/<feature_name>/presentation/` (Widgets, Screens, Controllers/Notifier)

2. **Data Layer Rules**:
   - Convert API JSON payloads into strongly-typed Freezed or JSON-serializable Dart classes.
   - Catch all data source errors and throw domain-specific `Failure` exceptions.

3. **Presentation Layer Rules**:
   - Keep UI components decoupled from backend logic using your state management solution (e.g., Riverpod or BLoC).