import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'dart:io';

class ActionExecutor {
  /// Make a phone call
  static Future<bool> makeCall(String phoneNumber) async {
    try {
      phoneNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
      final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
      
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
        debugPrint('📞 Calling: $phoneNumber');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Call error: $e');
      return false;
    }
  }
  
  /// Send SMS
  static Future<bool> sendSMS(String phoneNumber, String message) async {
    try {
      phoneNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
      final Uri smsUri = Uri(
        scheme: 'sms',
        path: phoneNumber,
        queryParameters: {'body': message},
      );
      
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
        debugPrint('💬 SMS to $phoneNumber: $message');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ SMS error: $e');
      return false;
    }
  }
  
  /// Send WhatsApp message
  static Future<bool> sendWhatsApp(String phoneNumber, String message) async {
    try {
      // Remove non-digit characters except +
      phoneNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
      
      // Remove + if exists for WhatsApp
      if (phoneNumber.startsWith('+')) {
        phoneNumber = phoneNumber.substring(1);
      }
      
      // WhatsApp URL scheme
      final Uri whatsappUri = Uri.parse(
        'whatsapp://send?phone=$phoneNumber&text=${Uri.encodeComponent(message)}'
      );
      
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri);
        debugPrint('💚 WhatsApp to $phoneNumber: $message');
        return true;
      }
      
      // Fallback to WhatsApp web
      final Uri webUri = Uri.parse(
        'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}'
      );
      await launchUrl(webUri);
      return true;
      
    } catch (e) {
      debugPrint('❌ WhatsApp error: $e');
      return false;
    }
  }
  
  /// Set alarm using Android Intent
  static Future<bool> setAlarm(int hour, int minute, {String? label}) async {
    if (!Platform.isAndroid) return false;
    
    try {
      final AndroidIntent intent = AndroidIntent(
        action: 'android.intent.action.SET_ALARM',
        arguments: {
          'android.intent.extra.alarm.HOUR': hour,
          'android.intent.extra.alarm.MINUTES': minute,
          'android.intent.extra.alarm.MESSAGE': label ?? 'JARVIS Alarm',
          'android.intent.extra.alarm.SKIP_UI': true,
        },
      );
      
      await intent.launch();
      debugPrint('⏰ Alarm set for $hour:$minute - $label');
      return true;
      
    } catch (e) {
      debugPrint('❌ Alarm error: $e');
      return false;
    }
  }
  
  /// Set timer
  static Future<bool> setTimer(int seconds, {String? label}) async {
    if (!Platform.isAndroid) return false;
    
    try {
      final AndroidIntent intent = AndroidIntent(
        action: 'android.intent.action.SET_TIMER',
        arguments: {
          'android.intent.extra.alarm.LENGTH': seconds,
          'android.intent.extra.alarm.MESSAGE': label ?? 'JARVIS Timer',
          'android.intent.extra.alarm.SKIP_UI': false,
        },
      );
      
      await intent.launch();
      debugPrint('⏱️  Timer set for $seconds seconds');
      return true;
      
    } catch (e) {
      debugPrint('❌ Timer error: $e');
      return false;
    }
  }
  
  /// Open an app
  static Future<bool> openApp(String packageName) async {
    if (!Platform.isAndroid) return false;
    
    try {
      final AndroidIntent intent = AndroidIntent(
        action: 'android.intent.action.MAIN',
        package: packageName,
        flags: [Flag.FLAG_ACTIVITY_NEW_TASK],
      );
      
      await intent.launch();
      debugPrint('📱 Opened app: $packageName');
      return true;
      
    } catch (e) {
      debugPrint('❌ App open error: $e');
      return false;
    }
  }
  
  /// Open URL in browser
  static Future<bool> openUrl(String url) async {
    try {
      if (!url.startsWith('http')) {
        url = 'https://$url';
      }
      
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        debugPrint('🌐 Opened URL: $url');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ URL open error: $e');
      return false;
    }
  }
  
  /// Search on Google
  static Future<bool> googleSearch(String query) async {
    final url = 'https://www.google.com/search?q=${Uri.encodeComponent(query)}';
    return await openUrl(url);
  }
  
  /// Open camera
  static Future<bool> openCamera() async {
    if (!Platform.isAndroid) return false;
    
    try {
      final AndroidIntent intent = AndroidIntent(
        action: 'android.media.action.IMAGE_CAPTURE',
      );
      await intent.launch();
      debugPrint('📷 Camera opened');
      return true;
    } catch (e) {
      debugPrint('❌ Camera error: $e');
      return false;
    }
  }
  
  /// Open gallery
  static Future<bool> openGallery() async {
    if (!Platform.isAndroid) return false;
    
    try {
      final AndroidIntent intent = AndroidIntent(
        action: 'android.intent.action.VIEW',
        type: 'image/*',
      );
      await intent.launch();
      debugPrint('🖼️  Gallery opened');
      return true;
    } catch (e) {
      debugPrint('❌ Gallery error: $e');
      return false;
    }
  }
  
  /// Toggle WiFi (requires system permissions)
  static Future<bool> toggleWiFi(bool enable) async {
    if (!Platform.isAndroid) return false;
    
    try {
      final AndroidIntent intent = AndroidIntent(
        action: 'android.settings.WIFI_SETTINGS',
      );
      await intent.launch();
      debugPrint('📶 WiFi settings opened');
      return true;
    } catch (e) {
      debugPrint('❌ WiFi error: $e');
      return false;
    }
  }
  
  /// Open settings
  static Future<bool> openSettings({String? specific}) async {
    if (!Platform.isAndroid) return false;
    
    try {
      String action = 'android.settings.SETTINGS';
      
      if (specific != null) {
        switch (specific.toLowerCase()) {
          case 'wifi':
            action = 'android.settings.WIFI_SETTINGS';
            break;
          case 'bluetooth':
            action = 'android.settings.BLUETOOTH_SETTINGS';
            break;
          case 'location':
            action = 'android.settings.LOCATION_SOURCE_SETTINGS';
            break;
          case 'sound':
            action = 'android.settings.SOUND_SETTINGS';
            break;
          case 'display':
            action = 'android.settings.DISPLAY_SETTINGS';
            break;
        }
      }
      
      final AndroidIntent intent = AndroidIntent(action: action);
      await intent.launch();
      debugPrint('⚙️  Settings opened: $specific');
      return true;
      
    } catch (e) {
      debugPrint('❌ Settings error: $e');
      return false;
    }
  }
  
  /// Play music (open music app)
  static Future<bool> playMusic({String? query}) async {
    if (!Platform.isAndroid) return false;
    
    try {
      if (query != null) {
        // Try YouTube Music or Spotify with search
        final ytMusicUrl = 'https://music.youtube.com/search?q=${Uri.encodeComponent(query)}';
        return await openUrl(ytMusicUrl);
      }
      
      // Open default music app
      final AndroidIntent intent = AndroidIntent(
        action: 'android.intent.action.MUSIC_PLAYER',
      );
      await intent.launch();
      debugPrint('🎵 Music player opened');
      return true;
      
    } catch (e) {
      debugPrint('❌ Music error: $e');
      return false;
    }
  }
  
  /// Common app package names
  static const Map<String, String> commonApps = {
    'whatsapp': 'com.whatsapp',
    'telegram': 'org.telegram.messenger',
    'instagram': 'com.instagram.android',
    'facebook': 'com.facebook.katana',
    'youtube': 'com.google.android.youtube',
    'chrome': 'com.android.chrome',
    'gmail': 'com.google.android.gm',
    'maps': 'com.google.android.apps.maps',
    'camera': 'com.android.camera',
    'gallery': 'com.google.android.apps.photos',
    'music': 'com.google.android.music',
    'spotify': 'com.spotify.music',
  };
  
  /// Get package name from app name
  static String? getPackageName(String appName) {
    appName = appName.toLowerCase().trim();
    return commonApps[appName];
  }
}
