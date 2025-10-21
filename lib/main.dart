import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // << เพิ่ม
import 'firebase_options.dart'; // << เพิ่ม

import 'package:provider/provider.dart';
import 'providers/health_data_provider.dart';
import 'providers/community_provider.dart';
import 'providers/chat_provider.dart';
import 'screens/login_screen.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const HealthTeenApp());
}

class HealthTeenApp extends StatelessWidget {
  const HealthTeenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HealthDataProvider()),
        ChangeNotifierProvider(create: (_) => CommunityProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MaterialApp(
        title: 'Health Teen',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.background,
          fontFamily: 'Inter',
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        home: const LoginScreen(),
      ),
    );
  }
}
