#!/bin/bash

# 🚀 JARVIS Setup Script - Complete Installation

echo "🎯 JARVIS Voice Assistant - Setup Starting..."

# Check Flutter
if ! command -v flutter &> /dev/null; then
    echo "📦 Flutter not found. Installing..."
    git clone https://github.com/flutter/flutter.git -b stable ~/flutter
    export PATH="$PATH:$HOME/flutter/bin"
    flutter doctor
fi

# Create Flutter project
echo "🏗️  Creating Flutter project..."
flutter create --org com.sultanai jarvis_assistant

cd jarvis_assistant

# Add dependencies
echo "📚 Adding dependencies to pubspec.yaml..."
cat >> pubspec.yaml << 'EOF'

dependencies:
  flutter:
    sdk: flutter
  
  # Speech Recognition
  speech_to_text: ^6.6.0
  permission_handler: ^11.1.0
  
  # Text to Speech
  flutter_tts: ^3.8.5
  
  # AI Integration
  http: ^1.1.2
  dio: ^5.4.0
  
  # Local Storage
  sqflite: ^2.3.0
  shared_preferences: ^2.2.2
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
  # Background Services
  workmanager: ^0.5.1
  flutter_background_service: ^5.0.5
  
  # Vision & Camera
  camera: ^0.10.5+7
  google_mlkit_text_recognition: ^0.11.0
  google_mlkit_image_labeling: ^0.10.0
  
  # Communication
  url_launcher: ^6.2.2
  android_intent_plus: ^4.0.3
  
  # Location
  geolocator: ^10.1.0
  geocoding: ^2.1.1
  
  # Notifications
  flutter_local_notifications: ^16.3.0
  
  # State Management
  provider: ^6.1.1
  get: ^4.6.6
  
  # Utils
  intl: ^0.18.1
  path_provider: ^2.1.1
  connectivity_plus: ^5.0.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_launcher_icons: ^0.13.1
  
flutter_launcher_icons:
  android: true
  ios: false
  image_path: "assets/icon/app_icon.png"
  adaptive_icon_background: "#000000"
  adaptive_icon_foreground: "assets/icon/app_icon_fg.png"
EOF

echo "📥 Installing dependencies..."
flutter pub get

echo "✅ Setup complete! Now creating project structure..."
