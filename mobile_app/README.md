# DPI Mobile App

Flutter mobile application for the Digital Public Infrastructure platform.

## Features

- **Multi-role Authentication**: Login and registration for Citizens, Doctors, City Staff, and Agri Officers.
- **Unified Citizen Portal**: One-stop access to Healthcare, Agriculture, and City Services.
- **Healthcare**: Book appointments, view medical records, and track health history.
- **Agriculture**: Access farming advisories, pest alerts, and market updates.
- **City Services**: Report civic issues with locations and track resolution progress.
- **Real-time Stats**: Admin-level visibility into system usage and service health.
- **Offline Support**: Secure token caching for seamless access.
- **Modern UI**: Clean, responsive interface built with Flutter.

## Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK
- Android Studio / Xcode (for mobile development)
- Running Django backend at `http://127.0.0.1:8000`

## Setup

1. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

2. **Configure API Endpoint**:
   - Edit `lib/services/auth_service.dart`
   - Update `baseUrl` if your backend is running on a different address
   - For Android emulator: use `http://10.0.2.2:8000/api`
   - For iOS simulator: use `http://127.0.0.1:8000/api`
   - For physical device: use your computer's IP address

3. **Run the App**:
   ```bash
   flutter run
   ```

4. **Setup Notifications** (Optional):
   - **Android**: Notifications work out of the box
   - **iOS**: Add notification permissions to `Info.plist`:
     ```xml
     <key>UIBackgroundModes</key>
     <array>
       <string>remote-notification</string>
     </array>
     ```

5. **Login with demo credentials**:

## Project Structure

```
mobile_app/
├── lib/
│   ├── main.dart                 # Application entry point
│   ├── services/
│   │   └── auth_service.dart     # Centralized API and Auth logic
│   └── screens/
│       ├── login_screen.dart     # Authentication portal
│       ├── register_screen.dart  # User onboarding
│       ├── citizen_home.dart     # Main dashboard for citizens
│       ├── doctor_dashboard.dart # Specialized doctor view
│       ├── city_staff_dashboard.dart # City staff management view
│       └── agri_officer_dashboard.dart # Agri officer advisory view
├── android/                      # Native Android configuration
├── ios/                          # Native iOS configuration
└── pubspec.yaml                  # Flutter dependencies
```

## Demo Credentials

- **Citizen**: `citizen1` / `password123`
- **Doctor**: `doctor1` / `password123`
- **City Staff**: `citystaff1` / `password123`
- **Agricultural Officer**: `agriofficer1` / `password123`

## API Integration

The app connects to the Django REST API endpoints:

- `/api/accounts/login/` - User authentication
- `/api/accounts/register/` - User registration
- `/api/healthcare/appointments/` - Healthcare appointments
- `/api/agriculture/updates/` - Agricultural updates
- `/api/city/complaints/` - City service complaints

## Building for Production

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## Troubleshooting

**Network Error**: Make sure the Django backend is running and accessible from your device/emulator.

**CORS Issues**: The Django backend should have CORS configured to allow requests from mobile apps.

**SSL Certificate**: For production, use HTTPS endpoints with valid SSL certificates.
