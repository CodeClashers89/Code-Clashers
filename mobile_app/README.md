# DPI Citizen Terminal

Dedicated Flutter mobile application for citizens to access the Digital Public Infrastructure platform.

## Features

- **Personalized Dashboard**: Real-time view of service status and quick access to essential utilities.
- **Biometric Identity**: Secure face-recognition login with automated token refresh.
- **Healthcare Hub**: Effortless appointment booking and access to professional digital prescriptions.
- **Agricultural Advisory**: Direct access to crop yields, expert advice, and market data.
- **Civic Resolution**: Report city grievances with location tracking and monitor resolution status.

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
│       └── citizen_home.dart     # Main terminal for citizens
├── android/                      # Native Android configuration
├── ios/                          # Native iOS configuration
└── pubspec.yaml                  # Flutter dependencies
```

## Demo Credentials

- **Citizen**: `citizen1` / `password123`

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
