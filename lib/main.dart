import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:preply/screens/entry_screen.dart';
import 'package:preply/screens/onboarding/onboarding_page_1.dart';
import 'package:preply/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  runApp(MyApp(token: token));
}

class MyApp extends StatelessWidget {
  final String? token;
  const MyApp({super.key, this.token});

  @override
  Widget build(BuildContext context) {
    // Check if token exists and is not expired
    final bool isLoggedIn =
        token != null && token!.isNotEmpty && !JwtDecoder.isExpired(token!);

    return MaterialApp(
      title: 'Preply',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: isLoggedIn
          ? EntryScreen(token: token)
          : const OnboardingPage1(),
    );
  }
}
