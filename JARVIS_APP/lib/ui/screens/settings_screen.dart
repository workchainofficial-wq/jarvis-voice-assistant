import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _groqKeyController = TextEditingController();
  final _geminiKeyController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _loadApiKeys();
  }
  
  Future<void> _loadApiKeys() async {
    final settings = await Hive.openBox('settings');
    _groqKeyController.text = settings.get('groq_api_key', defaultValue: '');
    _geminiKeyController.text = settings.get('gemini_api_key', defaultValue: '');
  }
  
  Future<void> _saveApiKeys() async {
    final settings = await Hive.openBox('settings');
    await settings.put('groq_api_key', _groqKeyController.text.trim());
    await settings.put('gemini_api_key', _geminiKeyController.text.trim());
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API keys saved!')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'AI Configuration',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _groqKeyController,
            decoration: const InputDecoration(
              labelText: 'Groq API Key (Free)',
              hintText: 'Get from console.groq.com',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _geminiKeyController,
            decoration: const InputDecoration(
              labelText: 'Gemini API Key (Free)',
              hintText: 'Get from makersuite.google.com',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _saveApiKeys,
            child: const Text('Save API Keys'),
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          const Text(
            'Wake Word',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text('Wake word detection coming soon!'),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _groqKeyController.dispose();
    _geminiKeyController.dispose();
    super.dispose();
  }
}
