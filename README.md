# Zone Two

A new Flutter project.

## Overview

### Introduction

Fill it up later

### Features

- Music Downloading
- Music BPM estimation
- Dark Mode

### Technologies

- Flutter
- BLoC (Business Logic Component) Architecture
- SQLite

## Getting Started

### Prerequisites

- Flutter SDK 3.22.2
- Dart 3.4.3
- VSCode
- Android/iOS emulator

### Development

```bash
git clone https://github.com/xplus2g4/ZoneTwo-Frontend.git
cd ZoneTwo-Frontend
flutter pub get
flutter devices
flutter run
```

## Project Structure

The project follows a feature-based file organization. Each `lib/feature` folder includes the domain layer (BLoC, entities) and the presentation layer (views, widgets).

The data layer is located in the `package/repository` folder, which is also organized by responsibility.

### Directory Structure

```
lib/
├── [feature]/
│   ├── entities/
│   ├── bloc/
│   │   ├── feature_bloc.dart
│   │   ├── feature_event.dart
│   │   └── feature_state.dart
│   ├── views/
│   └── widges/
├── main.dart
packages/
└── [data]_repository/
    ├── models/
    └── [data]_repository.dart
```

### Explanation of Key Directories and Files

- `lib/[feature]/blocs/`: Contains BLoC classes, events, and states.
- `lib/[feature]/widgets/`: Contains reusable widgets.
- `lib/main.dart`: Entry point of the application.
- `packages/[data]_repository/`: Contains repository classes that handle data operations.
- `packages/[data]_repository/models/`: Contains data models.
