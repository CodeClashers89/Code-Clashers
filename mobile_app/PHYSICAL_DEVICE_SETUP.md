# Testing on Physical Android Device

This guide will help you test the DPI Mobile App on your physical Android device.

## Prerequisites

✅ Android device with USB debugging enabled
✅ USB cable to connect device to computer
✅ Android Studio installed
✅ Django backend running on your computer

## Step-by-Step Setup

### 1. Enable USB Debugging on Your Android Device

1. Go to **Settings** → **About Phone**
2. Tap **Build Number** 7 times to enable Developer Options
3. Go back to **Settings** → **Developer Options**
4. Enable **USB Debugging**

### 2. Find Your Computer's Local IP Address

**On Windows:**
```bash
ipconfig
```
Look for **IPv4 Address** under your active network adapter (WiFi or Ethernet).
Example: `192.168.1.100`

**On Mac/Linux:**
```bash
ifconfig
```
Look for **inet** address under your active network interface.

### 3. Update API Endpoint in Flutter App

Open `lib/services/auth_service.dart` and update the `baseUrl`:

```dart
final String baseUrl = 'http://YOUR_IP_ADDRESS:8000/api';
```

**Example:**
```dart
final String baseUrl = 'http://192.168.1.100:8000/api';
```

### 4. Configure Django Backend for Network Access

Update `dpi_platform/settings.py`:

```python
# Allow connections from your local network
ALLOWED_HOSTS = ['localhost', '127.0.0.1', 'YOUR_IP_ADDRESS']

# Example:
ALLOWED_HOSTS = ['localhost', '127.0.0.1', '192.168.1.100']
```

### 5. Restart Django Server

Stop the current server (Ctrl+C) and restart it to bind to all network interfaces:

```bash
python manage.py runserver 0.0.0.0:8000
```

This allows the server to accept connections from your local network.

### 6. Connect Your Android Device

1. Connect your Android device to your computer via USB
2. On your device, allow USB debugging when prompted
3. Verify connection in Android Studio:
   - Open Android Studio
   - Go to **Tools** → **Device Manager**
   - Your device should appear in the list

### 7. Run the Flutter App

In the `mobile_app` directory:

```bash
# Install dependencies (first time only)
flutter pub get

# Run on connected device
flutter run
```

Flutter will automatically detect your connected device and install the app.

## Troubleshooting

### Device Not Detected

**Solution:**
- Ensure USB debugging is enabled
- Try a different USB cable
- Install device drivers (if on Windows)
- Run `flutter devices` to see available devices

### Network Connection Failed

**Solution:**
- Verify both devices are on the same WiFi network
- Check firewall settings on your computer
- Ensure Django server is running with `0.0.0.0:8000`
- Test API endpoint in browser: `http://YOUR_IP:8000/api/core/services/`

### CORS Errors

**Solution:**
The Django backend already has CORS configured to allow all origins in development. If you still face issues, verify `django-cors-headers` is installed and configured in `settings.py`.

### App Crashes on Startup

**Solution:**
- Check Flutter console for error messages
- Ensure all dependencies are installed: `flutter pub get`
- Clear app data on device and reinstall
- Check API endpoint is correct in `auth_service.dart`

## Testing Checklist

Once the app is running on your device:

- [ ] Login with demo credentials (`citizen1` / `password123`)
- [ ] Navigate through all tabs (Dashboard, Healthcare, Agriculture, City Services)
- [ ] Pull to refresh on each tab
- [ ] Test notifications (if enabled)
- [ ] Logout and login again
- [ ] Try registration flow
- [ ] Test with different user roles

## Network Configuration Summary

```
┌─────────────────────────┐
│  Your Computer          │
│  IP: [YOUR_IP_ADDRESS] │
│  Django: 0.0.0.0:8000  │
└───────────┬─────────────┘
            │
            │ WiFi Network
            │
┌───────────┴─────────────┐
│  Android Device         │
│  Flutter App            │
│  API: [YOUR_IP]:8000/api│
└─────────────────────────┘
```

## Quick Reference

**Find IP Address:**
```bash
ipconfig  # Windows
ifconfig  # Mac/Linux
```

**Run Django Server:**
```bash
python manage.py runserver 0.0.0.0:8000
```

**Run Flutter App:**
```bash
cd mobile_app
flutter run
```

**Check Connected Devices:**
```bash
flutter devices
adb devices
```

## Demo Credentials

- **Citizen**: `citizen1` / `password123`
- **Doctor**: `doctor1` / `password123`
- **City Staff**: `citystaff1` / `password123`
- **Agri Officer**: `agriofficer1` / `password123`

---

**Need Help?** Check the Flutter console output for detailed error messages and stack traces.
