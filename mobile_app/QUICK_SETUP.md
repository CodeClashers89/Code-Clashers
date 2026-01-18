# 🚀 Quick Setup for Physical Android Device Testing

## Your Network Configuration

**Your Computer's WiFi IP:** `10.167.110.93`

> [!TIP]
> Run `ipconfig` (Windows) or `ifconfig` (Mac/Linux) to find your local IPv4 address.

## ✅ Steps to Test on Your Android Device

### 1. **Enable USB Debugging on Your Phone**
   - Go to Settings → About Phone
   - Tap "Build Number" 7 times
   - Go to Settings → Developer Options
   - Enable "USB Debugging"

### 2. **Connect Your Phone**
   - Connect your Android phone to your computer via USB cable
   - Allow USB debugging when prompted on your phone

### 3. **Restart Django Server** (IMPORTANT!)
   
   Stop the current server (Ctrl+C in the terminal) and restart with:
   ```bash
   python manage.py runserver 0.0.0.0:8000
   ```
   
   This allows your phone to connect to the server over WiFi.

### 4. **Make Sure Both Devices Are on Same WiFi**
   - Your computer: Connected to WiFi (IP: 120.120.122.113)
   - Your phone: Must be connected to the **SAME WiFi network**

### 5. **Run the Flutter App**
   
   Open a new terminal in the `mobile_app` directory:
   ```bash
   cd mobile_app
   flutter pub get
   flutter run
   ```
   
   Flutter will automatically detect your connected phone and install the app.

## ✅ Already Configured For You

- ✅ API endpoint updated to: `http://120.120.122.113:8000/api`
- ✅ Django ALLOWED_HOSTS updated to include your IP
- ✅ CORS configured to allow mobile app requests

## 🧪 Test the Connection

Once the app is running on your phone:

1. **Login** with: `citizen1` / `password123`
2. **Check all tabs** load data correctly
3. **Pull to refresh** on each tab
4. **Test navigation** between different sections

## 🔧 Troubleshooting

**If app shows "Network Error":**
- Verify Django server is running with `0.0.0.0:8000`
- Check both devices are on the same WiFi
- Test in browser: `http://10.167.110.93:8000/api/core/services/`

**If device not detected:**
- Try `flutter devices` to see if phone is listed
- Reconnect USB cable
- Restart Android Studio

**If app crashes:**
- Check Flutter console for errors
- Run `flutter clean` then `flutter pub get`

## 📱 Demo Credentials

- Citizen: `citizen1` / `password123`

---

**Ready to go!** Just restart the Django server with `0.0.0.0:8000` and run `flutter run` 🎉
