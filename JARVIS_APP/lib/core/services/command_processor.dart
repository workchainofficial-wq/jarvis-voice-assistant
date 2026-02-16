import 'package:flutter/material.dart';
import 'ai_service.dart';
import 'action_executor.dart';
import 'voice_service.dart';
import '../models/command_result.dart';

class CommandProcessor {
  static final VoiceService _voiceService = VoiceService();
  
  /// Process voice command and execute action
  static Future<CommandResult> process(String input) async {
    debugPrint('🎯 Processing: $input');
    
    // Normalize input
    final normalized = input.toLowerCase().trim();
    
    // Get intent from AI
    final intent = AIService.classifyIntent(normalized);
    final intentType = intent['intent'] as String;
    
    // Route to appropriate handler
    CommandResult result;
    
    switch (intentType) {
      case 'call':
        result = await _handleCall(normalized, input);
        break;
      case 'message':
        result = await _handleMessage(normalized, input);
        break;
      case 'alarm':
        result = await _handleAlarm(normalized, input);
        break;
      case 'open_app':
        result = await _handleOpenApp(normalized, input);
        break;
      case 'settings':
        result = await _handleSettings(normalized, input);
        break;
      case 'weather':
        result = await _handleWeather(normalized, input);
        break;
      default:
        // AI chat response
        result = await _handleChat(input);
    }
    
    // Speak response if configured
    if (result.shouldSpeak) {
      await _voiceService.speak(result.response);
    }
    
    return result;
  }
  
  /// Handle phone call commands
  static Future<CommandResult> _handleCall(String normalized, String original) async {
    try {
      // Extract phone number or contact name
      final phonePattern = RegExp(r'\d{10,}');
      final phoneMatch = phonePattern.firstMatch(normalized);
      
      if (phoneMatch != null) {
        final number = phoneMatch.group(0)!;
        final success = await ActionExecutor.makeCall(number);
        
        if (success) {
          return CommandResult(
            success: true,
            action: 'call',
            response: '$number ko call kar raha hoon',
            shouldSpeak: true,
          );
        }
      }
      
      // If no number, ask AI to extract contact name
      final aiResponse = await AIService.processCommand(
        'Extract contact name from: $original. If found, return just the name. If not, return "UNKNOWN"'
      );
      
      if (aiResponse != 'UNKNOWN') {
        return CommandResult(
          success: false,
          action: 'call',
          response: '$aiResponse ko call karne ke liye contact access chahiye. Settings mein permission de do.',
          shouldSpeak: true,
          needsPermission: 'contacts',
        );
      }
      
      return CommandResult(
        success: false,
        action: 'call',
        response: 'Kisko call karna hai? Number ya naam batao',
        shouldSpeak: true,
      );
      
    } catch (e) {
      return CommandResult(
        success: false,
        action: 'call',
        response: 'Call karne mein problem aa gayi',
        shouldSpeak: true,
      );
    }
  }
  
  /// Handle message commands (SMS/WhatsApp)
  static Future<CommandResult> _handleMessage(String normalized, String original) async {
    try {
      // Determine platform
      final isWhatsApp = normalized.contains('whatsapp') || normalized.contains('wa');
      
      // Extract recipient and message using AI
      final aiResponse = await AIService.processCommand(
        'Extract from "$original": 1) Recipient (phone number or name), 2) Message content. Format: RECIPIENT|MESSAGE'
      );
      
      final parts = aiResponse.split('|');
      if (parts.length >= 2) {
        final recipient = parts[0].trim();
        final message = parts.sublist(1).join('|').trim();
        
        // Check if it's a phone number
        final phonePattern = RegExp(r'\d{10,}');
        if (phonePattern.hasMatch(recipient)) {
          final success = isWhatsApp
              ? await ActionExecutor.sendWhatsApp(recipient, message)
              : await ActionExecutor.sendSMS(recipient, message);
          
          if (success) {
            return CommandResult(
              success: true,
              action: 'message',
              response: '$recipient ko message bhej raha hoon: "$message"',
              shouldSpeak: true,
            );
          }
        }
        
        return CommandResult(
          success: false,
          action: 'message',
          response: 'Contact access nahi hai. $recipient ka number nahi mil paya.',
          shouldSpeak: true,
          needsPermission: 'contacts',
        );
      }
      
      return CommandResult(
        success: false,
        action: 'message',
        response: 'Kisko aur kya message bhejna hai? Clear batao',
        shouldSpeak: true,
      );
      
    } catch (e) {
      return CommandResult(
        success: false,
        action: 'message',
        response: 'Message bhejne mein problem aa gayi',
        shouldSpeak: true,
      );
    }
  }
  
  /// Handle alarm/reminder commands
  static Future<CommandResult> _handleAlarm(String normalized, String original) async {
    try {
      // Extract time using AI
      final aiResponse = await AIService.processCommand(
        'Extract time from "$original". Return in format: HH:MM|LABEL. If no label, use "Alarm". Examples: "07:00|Wake up", "14:30|Meeting"'
      );
      
      final parts = aiResponse.split('|');
      if (parts.isNotEmpty) {
        final timeParts = parts[0].split(':');
        if (timeParts.length == 2) {
          final hour = int.tryParse(timeParts[0].trim());
          final minute = int.tryParse(timeParts[1].trim());
          
          if (hour != null && minute != null) {
            final label = parts.length > 1 ? parts[1].trim() : 'JARVIS Alarm';
            final success = await ActionExecutor.setAlarm(hour, minute, label: label);
            
            if (success) {
              return CommandResult(
                success: true,
                action: 'alarm',
                response: '$hour baje $minute minute pe alarm set ho gaya - $label',
                shouldSpeak: true,
              );
            }
          }
        }
      }
      
      return CommandResult(
        success: false,
        action: 'alarm',
        response: 'Time clear nahi samajh aaya. Jaise bolo: "7 baje alarm laga" ya "Shaam 6 baje reminder"',
        shouldSpeak: true,
      );
      
    } catch (e) {
      return CommandResult(
        success: false,
        action: 'alarm',
        response: 'Alarm set karne mein problem aa gayi',
        shouldSpeak: true,
      );
    }
  }
  
  /// Handle app opening commands
  static Future<CommandResult> _handleOpenApp(String normalized, String original) async {
    try {
      // Extract app name
      final words = normalized.split(' ');
      String? appName;
      
      for (int i = 0; i < words.length; i++) {
        if (words[i] == 'open' || words[i] == 'kholo' || words[i] == 'launch') {
          if (i + 1 < words.length) {
            appName = words[i + 1];
            break;
          }
        }
      }
      
      if (appName != null) {
        final packageName = ActionExecutor.getPackageName(appName);
        if (packageName != null) {
          final success = await ActionExecutor.openApp(packageName);
          if (success) {
            return CommandResult(
              success: true,
              action: 'open_app',
              response: '$appName khol raha hoon',
              shouldSpeak: true,
            );
          }
        }
      }
      
      return CommandResult(
        success: false,
        action: 'open_app',
        response: 'Konsa app kholna hai? WhatsApp, Instagram, YouTube, etc.',
        shouldSpeak: true,
      );
      
    } catch (e) {
      return CommandResult(
        success: false,
        action: 'open_app',
        response: 'App kholne mein problem aa gayi',
        shouldSpeak: true,
      );
    }
  }
  
  /// Handle settings commands
  static Future<CommandResult> _handleSettings(String normalized, String original) async {
    String? specific;
    
    if (normalized.contains('wifi') || normalized.contains('internet')) {
      specific = 'wifi';
    } else if (normalized.contains('bluetooth')) {
      specific = 'bluetooth';
    } else if (normalized.contains('volume') || normalized.contains('sound')) {
      specific = 'sound';
    } else if (normalized.contains('brightness') || normalized.contains('display')) {
      specific = 'display';
    } else if (normalized.contains('location') || normalized.contains('gps')) {
      specific = 'location';
    }
    
    final success = await ActionExecutor.openSettings(specific: specific);
    
    if (success) {
      return CommandResult(
        success: true,
        action: 'settings',
        response: specific != null ? '$specific settings khol raha hoon' : 'Settings khol raha hoon',
        shouldSpeak: true,
      );
    }
    
    return CommandResult(
      success: false,
      action: 'settings',
      response: 'Settings kholne mein problem aa gayi',
      shouldSpeak: true,
    );
  }
  
  /// Handle weather queries
  static Future<CommandResult> _handleWeather(String normalized, String original) async {
    // This would integrate with weather API
    // For now, return placeholder
    return CommandResult(
      success: true,
      action: 'weather',
      response: 'Weather feature coming soon! Abhi AI response de raha hoon.',
      shouldSpeak: true,
    );
  }
  
  /// Handle general chat (AI response)
  static Future<CommandResult> _handleChat(String input) async {
    try {
      final response = await AIService.processCommand(input);
      
      return CommandResult(
        success: true,
        action: 'chat',
        response: response,
        shouldSpeak: true,
      );
      
    } catch (e) {
      return CommandResult(
        success: false,
        action: 'chat',
        response: 'Samajh nahi aaya, thoda aur clear batao',
        shouldSpeak: true,
      );
    }
  }
}
