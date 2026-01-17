# DPI Mobile App

Flutter mobile application for the Digital Public Infrastructure platform.

## Features

- **Multi-role Authentication**: Login and registration for all user types
- **Citizen Portal**: Access healthcare, agriculture, and city services
- **Healthcare**: View appointments and medical records
- **Agriculture**: Get farming updates and advisories
- **City Services**: Report and track complaints
- **Push Notifications**: Local notifications for appointments, updates, and complaint status
- **Offline Support**: Secure local storage for authentication tokens
- **Pull-to-Refresh**: Update data with a simple swipe gesture
- **Material Design**: Beautiful, modern UI following Material Design guidelines

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
│   ├── main.dart                 # App entry point
│   ├── services/
│   │   ├── auth_service.dart     # Authentication & API service
│   │   └── notification_service.dart # Push notifications
│   └── screens/
│       ├── login_screen.dart     # Login page
│       ├── register_screen.dart  # Registration page
│       ├── citizen_home.dart     # Citizen dashboard
│       ├── doctor_dashboard.dart # Doctor interface
│       ├── city_staff_dashboard.dart # City staff interface
│       └── agri_officer_dashboard.dart # Agri officer interface
├── android/                      # Android-specific files
├── ios/                          # iOS-specific files
└── pubspec.yaml                  # Dependencies
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
