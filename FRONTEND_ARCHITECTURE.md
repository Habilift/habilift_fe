# HabiLift Frontend Architecture

This document provides an overview of the frontend implementation for the HabiLift application. It is designed to help new developers quickly understand the project structure, key technologies, and architectural patterns used.

## 1. Tech Stack

- **Framework**: Flutter (SDK ^3.9.2)
- **State Management**: [flutter_riverpod](https://pub.dev/packages/flutter_riverpod)
- **Navigation**: [go_router](https://pub.dev/packages/go_router)
- **Networking**: [dio](https://pub.dev/packages/dio)
- **Local Storage**: [hive](https://pub.dev/packages/hive) & [shared_preferences](https://pub.dev/packages/shared_preferences)
- **UI/UX**:
    - [flutter_animate](https://pub.dev/packages/flutter_animate) (Animations)
    - [flutter_form_builder](https://pub.dev/packages/flutter_form_builder) (Form handling)
    - [google_fonts](https://pub.dev/packages/google_fonts) (Typography)
    - [flutter_iconly](https://pub.dev/packages/flutter_iconly) (Icons)

## 2. Project Structure

The project follows a **Feature-First** architecture, where code is organized by feature rather than by layer.

```
lib/
├── app/                 # Global app configuration
│   ├── theme/           # App-wide theme, colors, and typography
│   ├── router.dart      # GoRouter configuration
│   └── app.dart         # Root widget (HabiLiftApp)
├── core/                # Shared utilities and core functionality
│   ├── constants/       # App constants
│   ├── utils/           # Helper functions
│   └── widgets/         # Reusable UI components
├── features/            # Feature modules
│   ├── auth/            # Authentication (Login, Sign Up, OTP)
│   ├── home/            # Dashboard and home screen
│   ├── onboarding/      # Onboarding flow
│   ├── booking/         # Appointment booking
│   └── ...
└── main.dart            # Entry point
```

## 3. Key Concepts

### State Management (Riverpod)
The app uses **Riverpod** for state management.
- **ProviderScope**: Wraps the entire app in [main.dart](file:///c:/Users/DESCHANEL/Pictures/Habilift%20Frontend/habilift_frontend2/habilift_fe/lib/main.dart).
- **ConsumerWidget / ConsumerStatefulWidget**: Used in UI components to listen to providers.
- **Providers**: Should be defined within the relevant feature directories (e.g., `features/auth/presentation/providers`).

### Navigation (GoRouter)
Navigation is handled by **GoRouter**, configured in [lib/app/router.dart](file:///c:/Users/DESCHANEL/Pictures/Habilift%20Frontend/habilift_frontend2/habilift_fe/lib/app/router.dart).
- **Routes**: Defined as `GoRoute` objects.
- **Navigation**: Use `context.go('/path')` for replacing the stack or `context.push('/path')` for adding to the stack.

### Theming
The app uses a centralized theme defined in [lib/app/theme/app_theme.dart](file:///c:/Users/DESCHANEL/Pictures/Habilift%20Frontend/habilift_frontend2/habilift_fe/lib/app/theme/app_theme.dart).
- **Colors**: Defined in `AppColors` class.
- **Typography**: Defined in `AppTypography` class.
- **Usage**: Access theme properties via `Theme.of(context)`.

### Feature Architecture
Each feature typically follows a layered structure (though some may be simplified):
- **presentation/**: UI screens, widgets, and Riverpod providers.
- **domain/**: Entities and repository interfaces (if applicable).
- **data/**: Data sources, models, and repository implementations (if applicable).

## 4. Key Features Implementation

### Authentication (`features/auth`)
- Handles Login, Sign Up, OTP, and Profile Setup.
- Uses `FormBuilder` for input validation.
- UI components are animated using `flutter_animate`.

### Onboarding (`features/onboarding`)
- Consists of `WelcomeScreen`, `MissionScreen`, and `UserTypeScreen`.
- Guides the user through the initial app experience.

### Dashboard (`features/home`)
- The main landing page after login (`DashboardScreen`).
- Likely contains widgets for quick actions, stats, and navigation to other features.

## 5. Best Practices

- **Imports**: Use relative imports for files within the same feature, and package imports for shared/core modules.
- **Responsiveness**: Ensure UI adapts to different screen sizes.
- **Code Style**: Follow the linter rules defined in [analysis_options.yaml](file:///c:/Users/DESCHANEL/Pictures/Habilift%20Frontend/habilift_frontend2/habilift_fe/analysis_options.yaml).

## 6. How to Add a New Feature

1.  **Create Directory**: Create a new directory in `lib/features/` (e.g., `lib/features/my_feature`).
2.  **Add Layers**: Inside, create `presentation`, `domain`, and [data](file:///c:/Users/DESCHANEL/Pictures/Habilift%20Frontend/habilift_frontend2/habilift_fe/.metadata) directories.
3.  **Define Routes**: Add a new `GoRoute` in [lib/app/router.dart](file:///c:/Users/DESCHANEL/Pictures/Habilift%20Frontend/habilift_frontend2/habilift_fe/lib/app/router.dart).
4.  **Create Screen**: Create your screen widget in `presentation/screens/`.
5.  **Add Logic**: Use Riverpod providers for state management.
6.  **Register**: Ensure your feature is accessible via navigation or other entry points.
