import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // << เพิ่ม
import 'firebase_options.dart'; // << เพิ่ม

import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/health_data_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
<<<<<<< HEAD

=======
>>>>>>> upstream/packing
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

<<<<<<< HEAD
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HealthDataProvider()),
      ],
      child: const MyApp(),
    ),
  );
=======
  runApp(const HealthTeenApp());
>>>>>>> upstream/packing
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
            return const HomeScreen();
          }
        },
      ),
    );
  }
}
