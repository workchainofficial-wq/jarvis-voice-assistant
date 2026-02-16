import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/services/app_initializer.dart';
import 'core/providers/voice_provider.dart';
import 'core/providers/ai_provider.dart';
import 'core/providers/context_provider.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/chat_screen.dart';
import 'ui/screens/automation_screen.dart';
import 'ui/screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  
  // Initialize app services
  await AppInitializer.initialize();
  
  runApp(const JarvisApp());
}

class JarvisApp extends StatelessWidget {
  const JarvisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VoiceProvider()),
        ChangeNotifierProvider(create: (_) => AIProvider()),
        ChangeNotifierProvider(create: (_) => ContextProvider()),
      ],
      child: MaterialApp(
        title: 'JARVIS',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0A0E27),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF00D9FF),
            secondary: Color(0xFF7B2CBF),
            surface: Color(0xFF1A1F3A),
          ),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
        routes: {
          '/chat': (context) => const ChatScreen(),
          '/automation': (context) => const AutomationScreen(),
          '/settings': (context) => const SettingsScreen(),
        },
      ),
    );
  }
}
