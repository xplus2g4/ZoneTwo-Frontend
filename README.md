<!-- # <img src="https://github.com/xplus2g4/ZoneTwo-Frontend/blob/staging/assets/logo.png?raw=true" width=50 height=50> ZoneTwo -->

# ![logo](/assets/logo_md.png)

A new Flutter project.

## Overview

### Introduction

ZoneTwo syncs your running cadence to the tempo of the song you're playing in
order to maintain a consistent, low-intesity pace and provide an enjoyable
running experience.

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

The project adheres to the [single responsibility principle](https://en.wikipedia.org/wiki/Single-responsibility_principle). Hence, the project follow a <ins>feature-based</ins> file organisation, where each folder focuses on a single self-contained feature.

Such organisation enables easier navigation and understanding of the codebase. Within each feature, developers can quickly locate all components (e.g., BLoC, views, widgets) associated.

Additionally, since each feature is self-contained, it minimizes the risk of breaking other parts of the application and allows independent and focused testing.

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

## Architecture

The project uses Business Logic Component (BLoC) architecture, which is commonly used in flutter. This architecture contain 3 layers: Presentation, Domain and Data Layers.

### Data Layer

The data layer, located in the `packages/repository` folders, is responsible for retrieving and manipulating data from various sources. This layer is divided into two main parts:

1. Repository
   - Handles local database operations.
   - Exposes an observable stream that publishes CRUD changes in the database.
2. Data Provider
   - Manages data fetching from third-party sources.
   - Calls APIs of backend services.

As the lowest level of the application, the data layer interacts directly with databases, performs network requests, and handles other asynchronous data operations.

### Domain Layer

The domain layer, located in the `bloc` and `entities` folder within the feature folders, is responsible for application state management, which is very similar to [redux](https://redux.js.org/tutorials/essentials/part-1-overview-concepts).

_Insert a data flow image here, use the redux one_

In this layer, the business logic component (BloC) listens to input (events) from the presentation layer, extracts the payload of the event, process the data, and responds the presentation layer with the new states produced.

The domain layer also provides entity definitions to facilitate the complex object data flow. Additionally, this layer can depend on one or more data layer repositories to retrieve data needed to build up the application state.

On a special note, BLoCs within the domain layer are indepdendent and do not listen the states of one another. This rule is enforced to avoid the creation of tightly coupled BLoCs which is difficult to maintain.

_Insert a diagram to illustrate bloc-to-bloc communication_

In the situation where a bloc needs to respond to another bloc, the communication will be done in either the presentation layer or the data layer.

### Presentation Layer

The presentation layer, located in the `views` and `widgets` folder of the feature folders, is responsible for rendering pages (views) and components (widgets) dynamically according to the current BLoC states.

This layer captures user input and triggers corresponding BLoC events, thereby updating the state and behavior of the application. Additionally, it listens to state changes emitted by BLoC and updates the UI accordingly, ensuring a clear separation between the UI and business logic.

Furthermore, the presentation layer manages the lifecycle of UI components, ensuring proper initialization, updates, and disposal. It handles transitions between different states and views, maintaining a consistent user experience.

By encapsulating these responsibilities, the presentation layer ensures a responsive and interactive user interface while maintaining a clean separation between UI and business logic.

## Testing

`flutter test integration_test --dart-define download_api_endpoint=http://10.0.2.2:7111 --dart-define google_maps_api=abc`

## DevOps & Project Management

- Linter
- VSCode
- Environmental Variables
- Github Actions
- Secrets
- Git Workflow

## Tech Stack

## Feature Design Details

## Technical & Design Decisions Q&A

> Why Flutter?

> Why BLoC?

> Streams vs Future?

> Why Dark Mode Only?

### References

- https://bloclibrary.dev/architecture/#business-logic-layer
- https://reactivex.io/intro.html
