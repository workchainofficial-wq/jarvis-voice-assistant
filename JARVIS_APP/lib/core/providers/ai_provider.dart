import 'package:flutter/material.dart';
import '../services/ai_service.dart';
import '../models/conversation.dart';

class AIProvider extends ChangeNotifier {
  final List<Conversation> _conversations = [];
  bool _isProcessing = false;
  
  List<Conversation> get conversations => _conversations;
  bool get isProcessing => _isProcessing;
  
  Future<String> processCommand(String input) async {
    _isProcessing = true;
    notifyListeners();
    
    // Add user message
    _conversations.add(Conversation(
      id: DateTime.now().toString(),
      message: input,
      isUser: true,
      timestamp: DateTime.now(),
    ));
    
    // Get AI response
    final response = await AIService.processCommand(input, context: _conversations);
    
    // Add AI response
    _conversations.add(Conversation(
      id: DateTime.now().toString(),
      message: response,
      isUser: false,
      timestamp: DateTime.now(),
    ));
    
    _isProcessing = false;
    notifyListeners();
    
    return response;
  }
  
  void clearConversations() {
    _conversations.clear();
    notifyListeners();
  }
}
