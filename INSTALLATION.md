# 🚀 JARVIS Voice Assistant - Complete Installation Guide

## Prerequisites

1. **Install Flutter**
   ```bash
   # Download Flutter SDK
   git clone https://github.com/flutter/flutter.git -b stable ~/flutter
   
   # Add to PATH (add to ~/.bashrc or ~/.zshrc)
   export PATH="$PATH:$HOME/flutter/bin"
   
   # Verify installation
   flutter doctor
   ```

2. **Install Android Studio**
   - Download from: https://developer.android.com/studio
   - Install Android SDK (API 33 or higher)
   - Install Android Command Line Tools
   - Accept licenses: `flutter doctor --android-licenses`

3. **Setup Android Device/Emulator**
   - **Physical Device:** Enable Developer Options + USB Debugging
   - **Emulator:** Create AVD in Android Studio

## Step-by-Step Installation

### 1. Navigate to Project Directory
```bash
cd voice-assistant-project/JARVIS_APP
```

### 2. Get Dependencies
```bash
flutter pub get
```

### 3. Generate Hive Adapters
```bash
flutter pub run build_runner build
```

### 4. Check Flutter Environment
```bash
flutter doctor -v
```
Fix any issues reported.

### 5. Connect Device
```bash
# List connected devices
flutter devices

# Should show your Android device or emulator
```

### 6. Run the App
```bash
# Debug mode (hot reload enabled)
flutter run

# Release mode (optimized, faster)
flutter run --release
```

## API Keys Setup (Required for AI Features)

### Option 1: Groq (Recommended - Fast & Free)
1. Go to: https://console.groq.com
2. Sign up (free)
3. Create API key
4. In app: Settings → Enter Groq API Key

### Option 2: Google Gemini (Fallback)
1. Go to: https://makersuite.google.com/app/apikey
2. Create API key
3. In app: Settings → Enter Gemini API Key

**Note:** At least one API key is required for intelligent responses. Without API keys, only basic offline commands will work.

## Building APK (For Distribution)

### Debug APK (Testing)
```bash
flutter build apk --debug
```
Output: `build/app/outputs/flutter-apk/app-debug.apk`

### Release APK (Production)
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

### Install APK on Device
```bash
# Via ADB
adb install build/app/outputs/flutter-apk/app-release.apk

# Or transfer APK to phone and install manually
```

## Permissions

First launch will request these permissions:
- ✅ Microphone (voice recognition)
- ✅ Phone (make calls)
- ✅ Contacts (contact access)
- ✅ SMS (send messages)
- ✅ Notifications (alerts)
- ✅ Location (location-based features)
- ✅ Camera (future vision features)

**Grant all permissions for full functionality.**

## Troubleshooting

### Issue: "Speech recognition not available"
**Solution:**
- Ensure microphone permission is granted
- Check device has Google Speech Services installed
- Try restarting app

### Issue: "Groq API error"
**Solution:**
- Verify API key is correct
- Check internet connection
- API might be rate-limited (wait a minute)

### Issue: "Flutter command not found"
**Solution:**
```bash
# Add to PATH
export PATH="$PATH:$HOME/flutter/bin"
source ~/.bashrc  # or ~/.zshrc
```

### Issue: "Android licenses not accepted"
**Solution:**
```bash
flutter doctor --android-licenses
# Accept all licenses
```

### Issue: App crashes on startup
**Solution:**
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

## Features Checklist

After installation, test these features:

- [ ] Tap mic button to speak
- [ ] Voice recognition working
- [ ] AI responses (requires API key)
- [ ] Quick actions (Call, Message, Alarm, Apps)
- [ ] Settings → Save API keys
- [ ] Make a test call
- [ ] Send a test message
- [ ] Set an alarm
- [ ] Open an app

## Voice Commands to Try

```
"Call 9876543210"
"WhatsApp pe Mom ko message kar - Aa raha hoon"
"Subah 7 baje alarm laga"
"YouTube kholo"
"Google pe search kar best restaurants"
"Time kya hua"
"Instagram open kar"
```

## Development Mode

### Hot Reload
- Press `r` in terminal while app is running
- Changes reflect instantly

### Debug Logs
```bash
# View logs
flutter logs

# Or in Android Studio: View → Tool Windows → Logcat
```

### Performance
```bash
flutter run --profile
```

## Next Steps

1. **Add Contacts Integration**
   - Implement contacts picker
   - Enable calling by name

2. **Wake Word Detection**
   - Add Porcupine or Snowboy
   - Always-listening mode

3. **Offline AI**
   - Download Ollama models
   - Full offline mode

4. **Vision Features**
   - Screenshot analysis
   - Object recognition
   - Text extraction

5. **Automation Builder**
   - Visual workflow creator
   - Location-based triggers
   - Time-based automation

## Support

**Issues?** Check:
- Flutter doctor output
- App logs (`flutter logs`)
- Permissions granted
- API keys valid

**Stack:**
- Flutter 3.x
- Android 5.0+ (API 21+)
- Dart 3.x

---

**Created by Sultan & SuperAI** 🚀
**License:** MIT (Free forever)

Enjoy your personal JARVIS! 🎯
