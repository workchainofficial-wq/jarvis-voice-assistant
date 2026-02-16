import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:hive/hive.dart';
import '../models/conversation.dart';
import '../models/automation_rule.dart';
import 'background_service.dart';
import 'notification_service.dart';

class AppInitializer {
  static Future<void> initialize() async {
    // Request permissions
    await _requestPermissions();
    
    // Initialize Hive boxes
    await _initializeHive();
    
    // Initialize background services
    await BackgroundService.initialize();
    
    // Initialize notifications
    await NotificationService.initialize();
    
    debugPrint('✅ JARVIS initialized successfully');
  }
  
  static Future<void> _requestPermissions() async {
    final permissions = [
      Permission.microphone,
      Permission.speech,
      Permission.notification,
      Permission.location,
      Permission.camera,
      Permission.contacts,
      Permission.phone,
      Permission.sms,
    ];
    
    for (var permission in permissions) {
      final status = await permission.request();
      if (status.isDenied) {
        debugPrint('⚠️  Permission denied: $permission');
      }
    }
  }
  
  static Future<void> _initializeHive() async {
    // Register adapters
    Hive.registerAdapter(ConversationAdapter());
    Hive.registerAdapter(AutomationRuleAdapter());
    
    // Open boxes
    await Hive.openBox<Conversation>('conversations');
    await Hive.openBox<AutomationRule>('automations');
    await Hive.openBox('settings');
    await Hive.openBox('context_memory');
  }
}
