import 'package:flutter/material.dart';
import '../services/voice_service.dart';

class VoiceProvider extends ChangeNotifier {
  final VoiceService _voiceService = VoiceService();
  
  bool _isListening = false;
  String _recognizedText = '';
  String _lastResponse = '';
  
  bool get isListening => _isListening;
  String get recognizedText => _recognizedText;
  String get lastResponse => _lastResponse;
  
  Future<void> initialize() async {
    await _voiceService.initialize();
    
    _voiceService.onFinalResult = (text) {
      _recognizedText = text;
      notifyListeners();
    };
  }
  
  Future<void> startListening() async {
    await _voiceService.startListening();
    _isListening = true;
    notifyListeners();
  }
  
  Future<void> stopListening() async {
    await _voiceService.stopListening();
    _isListening = false;
    notifyListeners();
  }
  
  Future<void> speak(String text) async {
    await _voiceService.speak(text);
    _lastResponse = text;
    notifyListeners();
  }
  
  void setRecognizedText(String text) {
    _recognizedText = text;
    notifyListeners();
  }
  
  void setLastResponse(String response) {
    _lastResponse = response;
    notifyListeners();
  }
}
