import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/health_data_provider.dart';
import 'providers/community_provider.dart';
import 'providers/chat_provider.dart';
import 'screens/main_screen.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (you'll need to run: flutterfire configure)
  // await Firebase.initializeApp();
  
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
        home: const MainScreen(),
      ),
    );
  }
}
