import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal();
  
  late stt.SpeechToText _speech;
  late FlutterTts _tts;
  
  bool _isInitialized = false;
  bool _isListening = false;
  String _lastRecognizedText = '';
  
  // Voice recognition callbacks
  Function(String)? onPartialResult;
  Function(String)? onFinalResult;
  Function(String)? onError;
  
  bool get isListening => _isListening;
  String get lastText => _lastRecognizedText;
  
  /// Initialize speech and TTS engines
  Future<bool> initialize() async {
    if (_isInitialized) return true;
    
    try {
      // Check microphone permission
      final micStatus = await Permission.microphone.request();
      if (!micStatus.isGranted) {
        debugPrint('❌ Microphone permission denied');
        return false;
      }
      
      // Initialize Speech-to-Text
      _speech = stt.SpeechToText();
      bool available = await _speech.initialize(
        onError: (error) {
          debugPrint('❌ Speech error: ${error.errorMsg}');
          _isListening = false;
          onError?.call(error.errorMsg);
        },
        onStatus: (status) {
          debugPrint('🎤 Speech status: $status');
          _isListening = (status == 'listening');
        },
      );
      
      if (!available) {
        debugPrint('❌ Speech recognition not available');
        return false;
      }
      
      // Initialize Text-to-Speech
      _tts = FlutterTts();
      await _configureTTS();
      
      _isInitialized = true;
      debugPrint('✅ Voice service initialized');
      return true;
      
    } catch (e) {
      debugPrint('❌ Voice initialization error: $e');
      return false;
    }
  }
  
  Future<void> _configureTTS() async {
    // Configure TTS settings
    await _tts.setLanguage('en-IN'); // Indian English
    await _tts.setSpeechRate(0.5); // Normal speed
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    
    // Set voice (prefer female voice for JARVIS)
    final voices = await _tts.getVoices;
    if (voices != null && voices.isNotEmpty) {
      // Try to find a good Indian English voice
      final indianVoice = voices.firstWhere(
        (voice) => voice['locale'].toString().contains('en-IN'),
        orElse: () => voices.first,
      );
      await _tts.setVoice({'name': indianVoice['name'], 'locale': indianVoice['locale']});
    }
  }
  
  /// Start listening to user's voice
  Future<void> startListening({
    bool continuous = false,
    String? localeId,
  }) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return;
    }
    
    if (_isListening) {
      debugPrint('⚠️  Already listening');
      return;
    }
    
    _lastRecognizedText = '';
    
    await _speech.listen(
      onResult: (result) {
        _lastRecognizedText = result.recognizedWords;
        
        if (result.finalResult) {
          debugPrint('🎤 Final: $_lastRecognizedText');
          onFinalResult?.call(_lastRecognizedText);
        } else {
          debugPrint('🎤 Partial: $_lastRecognizedText');
          onPartialResult?.call(_lastRecognizedText);
        }
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      cancelOnError: false,
      listenMode: continuous 
        ? stt.ListenMode.confirmation 
        : stt.ListenMode.search,
      localeId: localeId ?? 'en_IN', // Supports Hindi-English mix
    );
    
    _isListening = true;
    debugPrint('🎤 Started listening...');
  }
  
  /// Stop listening
  Future<void> stopListening() async {
    if (!_isListening) return;
    
    await _speech.stop();
    _isListening = false;
    debugPrint('🎤 Stopped listening');
  }
  
  /// Speak text using TTS
  Future<void> speak(String text, {bool urgent = false}) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    try {
      // Stop current speech if urgent
      if (urgent) {
        await _tts.stop();
      }
      
      debugPrint('🔊 Speaking: $text');
      await _tts.speak(text);
      
    } catch (e) {
      debugPrint('❌ TTS error: $e');
    }
  }
  
  /// Stop speaking
  Future<void> stopSpeaking() async {
    await _tts.stop();
  }
  
  /// Check if speech recognition is available
  Future<bool> isAvailable() async {
    if (!_isInitialized) {
      return await initialize();
    }
    return _speech.isAvailable;
  }
  
  /// Get available locales for speech recognition
  Future<List<stt.LocaleName>> getLocales() async {
    if (!_isInitialized) await initialize();
    return await _speech.locales();
  }
  
  /// Continuous listening mode (for wake word detection)
  Future<void> startWakeWordDetection({
    required String wakeWord,
    required Function() onWakeWordDetected,
  }) async {
    if (!_isInitialized) await initialize();
    
    debugPrint('👂 Wake word detection started: $wakeWord');
    
    // Continuous listening with wake word detection
    onFinalResult = (text) {
      final normalized = text.toLowerCase().trim();
      final wakeWordNormalized = wakeWord.toLowerCase().trim();
      
      if (normalized.contains(wakeWordNormalized)) {
        debugPrint('🎯 Wake word detected!');
        onWakeWordDetected();
      } else {
        // Keep listening
        Future.delayed(const Duration(milliseconds: 500), () {
          startListening(continuous: true);
        });
      }
    };
    
    await startListening(continuous: true);
  }
  
  /// Stop wake word detection
  Future<void> stopWakeWordDetection() async {
    onFinalResult = null;
    await stopListening();
    debugPrint('👂 Wake word detection stopped');
  }
  
  /// Smart language detection and processing
  Future<Map<String, dynamic>> processVoiceInput(String input) async {
    // Detect language mix
    bool hasHindi = RegExp(r'[\u0900-\u097F]').hasMatch(input);
    bool hasEnglish = RegExp(r'[a-zA-Z]').hasMatch(input);
    
    String language = 'english';
    if (hasHindi && hasEnglish) {
      language = 'hinglish';
    } else if (hasHindi) {
      language = 'hindi';
    }
    
    return {
      'text': input,
      'language': language,
      'confidence': 0.85,
    };
  }
  
  /// Get TTS voices list
  Future<List<dynamic>> getAvailableVoices() async {
    if (!_isInitialized) await initialize();
    return await _tts.getVoices ?? [];
  }
  
  /// Set custom voice
  Future<void> setVoice(String voiceName, String locale) async {
    await _tts.setVoice({'name': voiceName, 'locale': locale});
  }
  
  /// Dispose resources
  void dispose() {
    _speech.cancel();
    _tts.stop();
    _isInitialized = false;
  }
}
