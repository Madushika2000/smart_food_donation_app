import 'package:flutter/material.dart';
// Real app entry: Splash -> Signup/Login -> Home.
// This is needed so the signed-up user's name flows into Home & Profile.
import 'screens/splash_screen.dart';
import 'utils/colors.dart';
import 'utils/current_user.dart';

Future<void> main() async {
  // Needed before using plugins (shared_preferences) inside main().
  WidgetsFlutterBinding.ensureInitialized();

  // Load any previously saved user so we show their name (not "Guest").
  await CurrentUser.load();

  runApp(const SmartFoodDonationApp());
}

class SmartFoodDonationApp extends StatelessWidget {
  const SmartFoodDonationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Food Donation',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryGreen,
          primary: AppColors.primaryGreen,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      // App starts at the Splash screen, then Login/Signup, then Home.
      // From Home the user opens Donate Food, My Donations, Requests & Profile.
      home: const SplashScreen(),
    );
  }
}
