import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/health_data_provider.dart';
import 'providers/community_provider.dart'; // ✅ Add this
import 'providers/chat_provider.dart';      // ✅ Add this
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HealthDataProvider()),
        ChangeNotifierProvider(create: (_) => CommunityProvider()), // ✅ Add this
        ChangeNotifierProvider(create: (_) => ChatProvider()),      // ✅ Add this
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Teen',
      debugShowCheckedModeBanner: false,
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (!auth.isAuthenticated) {
            return const LoginScreen();
          } else {
            return const MainScreen();
          }
        },
      ),
    );
  }
}