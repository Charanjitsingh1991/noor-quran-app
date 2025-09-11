# Feature Comparison: Web App vs. Flutter App

This document outlines the features identified in both the Next.js web application and the Flutter mobile application, highlighting similarities and discrepancies.

## 1. Project Structure Overview

### Web App (Next.js)
- Root directory contains `src/` for source code, `public/` for static assets, and configuration files like `next.config.ts`, `tailwind.config.ts`, `firebase.json`, etc.
- `src/app/` contains the main application routes and layout, including `(app)` for core features and `(auth)` for authentication flows.
- Key directories: `src/app/`, `src/components/`, `src/context/`, `src/hooks/`, `src/lib/`, `src/types/`.

### Flutter App (`noor_flutter/`)
- Located within the `noor-quran-app` repository under `noor_flutter/`.
- Standard Flutter project structure with `lib/` for Dart source code, `assets/` for static assets, and platform-specific directories (`android/`, `ios/`, `web/`, `linux/`, `macos/`, `windows/`).
- Key directories: `lib/models/`, `lib/providers/`, `lib/screens/`, `lib/services/`, `lib/widgets/`.

## 2. Core Features and Navigation

### Web App (Next.js) - Inferred Routes/Features from `src/app/`
- **Splash Page (`page.tsx`):** Initial loading screen, redirects based on authentication status.
- **Authentication (`(auth)/`):**
    - Login (`login/`)
    - Signup (`signup/`)
    - Forgot Password (`forgot-password/`)
    - OTP Verification (`otp-verification/`)
    - Reset Password OTP (`reset-password-otp/`)
- **Main Application (`(app)/`):**
    - Home (`home/`)
    - Bookmarks (`bookmarks/`)
    - Continue Reading (`continue-reading/`)
    - Prayer Times (`prayer-times/`)
    - Profile (`profile/`)
    - Surah Reader (`surah/`)

### Flutter App - Inferred Routes/Features from `lib/main.dart`
- **Splash Screen (`/`)
- **Authentication:**
    - Login Screen (`/login`)
    - Signup Screen (`/signup`)
    - Forgot Password Screen (`/forgot-password`)
    - OTP Verification Screen (`/otp-verification`)
- **Main Application:**
    - Home Screen (`/home`)
    - Surah Reader Screen (`/surah/:id`)
    - Continue Reading Screen (`/continue-reading`)
    - Prayer Times Screen (`/prayer-times`)
    - Bookmarks Screen (`/bookmarks`)
    - Profile Screen (`/profile`)
    - Admin Screen (`/admin`)
    - Themes Screen (`/themes`)
    - Onboarding Screen (`/onboarding`)

## 3. Technology Stack and Dependencies

### Web App (Next.js)
- **Framework:** Next.js (React)
- **Styling:** Tailwind CSS
- **Components:** Shadcn UI (inferred from `components.json` and usage of `Toaster`)
- **Icons:** Lucide React
- **Authentication:** Custom `useAuth` hook and `AuthContext` (likely Firebase-backed)
- **Fonts:** Google Fonts (Alegreya, PT Sans)

### Flutter App
- **Framework:** Flutter (Dart)
- **State Management:** Provider
- **Navigation:** GoRouter
- **Firebase:** `firebase_core`, `firebase_messaging`, `cloud_firestore`, `firebase_auth`
- **Authentication:** Google Sign-In (`google_sign_in`), Local Auth (`local_auth` for biometrics)
- **Permissions:** `permission_handler`
- **UI Components:** Google Fonts (`google_fonts`), Fluttertoast (`fluttertoast`), Cached Network Image (`cached_network_image`)
- **Location/Network:** Geolocator (`geolocator`), HTTP (`http`)
- **Utilities:** Shared Preferences (`shared_preferences`), Intl (`intl`), URL Launcher (`url_launcher`), Timezone (`timezone`)
- **Icons:** Cupertino Icons (`cupertino_icons`), Flutter Launcher Icons (`flutter_launcher_icons`)

## 4. Discrepancies and Missing Features (Initial Observations)

Based on the initial review of file structures and main entry points:

### Web App Features NOT found in Flutter App:
- **None identified so far.**

### Web App Features Confirmed in Flutter App:
- **Reset Password OTP:** Both web and Flutter apps have dedicated screens/routes for handling OTP-based password resets.

### Flutter App Features NOT found in Web App:
- **Admin Screen:** The Flutter app explicitly lists an `AdminScreen` route (`/admin`), which does not appear to have a direct counterpart in the web app's `src/app/` structure.
- **AI Features (Genkit/Google AI):** The web app includes `src/ai/` with `genkit.ts` indicating integration with Genkit and Google AI models (e.g., Gemini 2.0 Flash). This suggests potential AI-powered features (e.g., intelligent search, content generation, personalized recommendations) that are not present in the Flutter app.
- **Themes Screen:** The Flutter app has a `ThemesScreen` route (`/themes`) and `ThemeProvider` for managing themes, which is a distinct feature. While the web app uses `globals.css` and likely has theming, a dedicated screen for theme selection is not immediately apparent.
- **Onboarding Screen:** The Flutter app includes an `OnboardingScreen` route (`/onboarding`), which is a common feature for first-time user experiences. This is not visible in the web app's main routes.
- **Biometric Authentication:** The Flutter app uses `local_auth` for biometric authentication, which is a mobile-specific feature and would not be present in the web app.
- **Push Notifications:** The Flutter app includes `firebase_messaging` for notifications, though `flutter_local_notifications` is commented out. The web app does not explicitly show notification-related dependencies in the main files reviewed.
- **Location Services:** The Flutter app uses `geolocator` for location, likely for prayer times calculation. The web app's prayer times functionality would also require location, but the specific implementation details are not yet clear from the file structure alone.

## 5. Further Investigation Required

To provide a more comprehensive comparison, I need to:
- **Deep dive into the implementation of each feature** in both applications to understand their exact functionalities and identify subtle differences.
- **Examine the API interactions** for both apps to see if they consume the same backend services and data models.
- **Review the `otp-service/` directory** in the web app to understand its role and how OTP is handled, then compare it with the Flutter app's OTP flow.
- **Investigate the `src/ai/` directory** in the web app to understand its purpose and check for any AI-related features that might be missing in the Flutter app.

This initial comparison provides a high-level overview. I will now proceed with a more detailed analysis of specific features.



- **AI Features (Genkit/Google AI):** The web app includes `src/ai/` with `genkit.ts` indicating integration with Genkit and Google AI models (e.g., Gemini 2.0 Flash). This suggests potential AI-powered features (e.g., intelligent search, content generation, personalized recommendations) that are not present in the Flutter app.

