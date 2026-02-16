import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import '../models/conversation.dart';

class AIService {
  // Groq API (Free tier)
  static const String groqApiUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String groqModel = 'llama-3.1-70b-versatile'; // Fast & free
  
  // Fallback: Gemini (Free tier)
  static const String geminiApiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';
  
  static String? _groqApiKey;
  static String? _geminiApiKey;
  
  static Future<void> initialize() async {
    final settings = await Hive.openBox('settings');
    _groqApiKey = settings.get('groq_api_key');
    _geminiApiKey = settings.get('gemini_api_key');
  }
  
  /// Main AI processing - context-aware response
  static Future<String> processCommand(String userInput, {List<Conversation>? context}) async {
    try {
      // Build context-aware prompt
      String systemPrompt = _buildSystemPrompt();
      List<Map<String, String>> messages = _buildContextMessages(context);
      messages.add({'role': 'user', 'content': userInput});
      
      // Try Groq first (faster)
      if (_groqApiKey != null && _groqApiKey!.isNotEmpty) {
        final response = await _callGroq(systemPrompt, messages);
        if (response != null) return response;
      }
      
      // Fallback to Gemini
      if (_geminiApiKey != null && _geminiApiKey!.isNotEmpty) {
        final response = await _callGemini(systemPrompt + '\n' + userInput);
        if (response != null) return response;
      }
      
      // Offline fallback - rule-based processing
      return _offlineProcessing(userInput);
      
    } catch (e) {
      print('❌ AI Error: $e');
      return _offlineProcessing(userInput);
    }
  }
  
  static String _buildSystemPrompt() {
    return '''You are JARVIS, Sultan's personal AI voice assistant. 
You are smart, helpful, and understand Hinglish (Hindi-English mix).
You can control phone functions, send messages, set alarms, and help with tasks.
Be concise and actionable. When user gives a command, execute it or provide clear steps.
Understand context from previous conversations.
Don't be overly formal - be friendly like a smart friend.''';
  }
  
  static List<Map<String, String>> _buildContextMessages(List<Conversation>? context) {
    if (context == null || context.isEmpty) return [];
    
    // Take last 5 conversations for context
    return context.take(5).map((conv) => {
      'role': conv.isUser ? 'user' : 'assistant',
      'content': conv.message
    }).toList();
  }
  
  static Future<String?> _callGroq(String systemPrompt, List<Map<String, String>> messages) async {
    try {
      final response = await http.post(
        Uri.parse(groqApiUrl),
        headers: {
          'Authorization': 'Bearer $_groqApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': groqModel,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            ...messages,
          ],
          'temperature': 0.7,
          'max_tokens': 500,
        }),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      }
      
      print('⚠️  Groq error: ${response.statusCode}');
      return null;
      
    } catch (e) {
      print('⚠️  Groq exception: $e');
      return null;
    }
  }
  
  static Future<String?> _callGemini(String prompt) async {
    try {
      final url = '$geminiApiUrl?key=$_geminiApiKey';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [{
            'parts': [{'text': prompt}]
          }]
        }),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      }
      
      print('⚠️  Gemini error: ${response.statusCode}');
      return null;
      
    } catch (e) {
      print('⚠️  Gemini exception: $e');
      return null;
    }
  }
  
  /// Offline rule-based processing for basic commands
  static String _offlineProcessing(String input) {
    input = input.toLowerCase();
    
    // Time/Date
    if (input.contains('time') || input.contains('samay') || input.contains('kitne baje')) {
      final now = DateTime.now();
      return 'Abhi ${now.hour}:${now.minute.toString().padLeft(2, '0')} baj rahe hain';
    }
    
    // Alarm
    if (input.contains('alarm') || input.contains('reminder')) {
      return 'Alarm set karne ke liye mujhe specific time batao, jaise "7 baje alarm laga"';
    }
    
    // Call
    if (input.contains('call') || input.contains('phone kar')) {
      return 'Kisko call karna hai? Contact name batao';
    }
    
    // Message
    if (input.contains('message') || input.contains('whatsapp')) {
      return 'Kisko message bhejna hai aur kya bhejna hai?';
    }
    
    // Default
    return 'Samajh nahi aaya, thoda aur detail mein batao';
  }
  
  /// Intent classification for action routing
  static Map<String, dynamic> classifyIntent(String input) {
    input = input.toLowerCase();
    
    // Communication intents
    if (input.contains('call') || input.contains('phone kar')) {
      return {'intent': 'call', 'confidence': 0.9};
    }
    if (input.contains('message') || input.contains('whatsapp') || input.contains('sms')) {
      return {'intent': 'message', 'confidence': 0.9};
    }
    
    // Time intents
    if (input.contains('alarm') || input.contains('reminder')) {
      return {'intent': 'alarm', 'confidence': 0.85};
    }
    
    // Information intents
    if (input.contains('weather') || input.contains('mausam')) {
      return {'intent': 'weather', 'confidence': 0.8};
    }
    
    // App control
    if (input.contains('open') || input.contains('kholo') || input.contains('launch')) {
      return {'intent': 'open_app', 'confidence': 0.85};
    }
    
    // Settings
    if (input.contains('volume') || input.contains('brightness') || input.contains('wifi')) {
      return {'intent': 'settings', 'confidence': 0.8};
    }
    
    return {'intent': 'chat', 'confidence': 0.5};
  }
}
