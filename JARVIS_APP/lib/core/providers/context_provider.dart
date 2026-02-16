import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ContextProvider extends ChangeNotifier {
  Box? _contextBox;
  Map<String, dynamic> _userPreferences = {};
  
  Map<String, dynamic> get preferences => _userPreferences;
  
  Future<void> initialize() async {
    _contextBox = await Hive.openBox('context_memory');
    _loadPreferences();
  }
  
  void _loadPreferences() {
    _userPreferences = Map<String, dynamic>.from(_contextBox?.get('preferences') ?? {});
    notifyListeners();
  }
  
  Future<void> savePreference(String key, dynamic value) async {
    _userPreferences[key] = value;
    await _contextBox?.put('preferences', _userPreferences);
    notifyListeners();
  }
  
  dynamic getPreference(String key) {
    return _userPreferences[key];
  }
  
  Future<void> recordInteraction(String type, Map<String, dynamic> data) async {
    final interactions = _contextBox?.get('interactions', defaultValue: <Map>[]) as List;
    interactions.add({
      'type': type,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    });
    await _contextBox?.put('interactions', interactions);
  }
}
