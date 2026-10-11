import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/links.dart';
import '../../utils/app_snackbar.dart';
import '../../utils/google_auth_service.dart';
import '../../utils/validators.dart';
import '../../widgets/animated_button.dart';
import '../../widgets/animated_page_transition.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/google_button.dart';
import '../../widgets/or_divider.dart';
import '../../widgets/preply_logo.dart';
import '../entry_screen.dart';
import 'otp_verification_page.dart';
import 'register_page.dart';
import '../profile/services/push_notification_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    initSharedPref();
  }

  Future<void> initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> loginUser() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final reqBody = {
        "email": emailController.text.trim(),
        "password": passwordController.text,
      };

      final response = await http.post(
        Uri.parse(loginUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(reqBody),
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (response.statusCode == 200 && jsonResponse['userToken'] != null) {
        final String myToken = jsonResponse['userToken'];
        final bool isVerified = jsonResponse['verification'] == true;

        if (!isVerified) {
          // If verification is false -> redirect to OTP verification page
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Please verify your email to continue',
                style: TextStyle(color: Colors.black),
              ),
              backgroundColor: Colors.orange,
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => OtpVerificationPage(
                email: emailController.text.trim(),
                token: myToken,
              ),
            ),
          );
        } else {
          // If verification is true -> save token and open entry screen
          await prefs.setString('token', myToken);
          PushNotificationService.initialize(
            jwtToken: myToken,
            backendUrl: appBaseUrl,
          ).catchError((e) {
            debugPrint('Push notification init error: $e');
          });

          if (!mounted) return;

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => EntryScreen(token: myToken)),
          );
        }
      } else {
        final message = jsonResponse['message'] ?? 'Invalid email or password';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              message,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to connect to the server',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleGoogleSignIn() async {
    if (_isGoogleLoading) return;
    setState(() => _isGoogleLoading = true);

    try {
      final result = await GoogleAuthService.signInWithGoogle();

      if (!mounted) return;
      setState(() => _isGoogleLoading = false);

      if (result != null && result['userToken'] != null) {
        final String myToken = result['userToken'];
        final bool isVerified = result['verification'] == true;
        final String userEmail = result['email'] ?? emailController.text.trim();

        if (!isVerified) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Please verify your email with the OTP sent',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.orange,
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => OtpVerificationPage(
                email: userEmail,
                token: myToken,
              ),
            ),
          );
        } else {
          await prefs.setString('token', myToken);
          PushNotificationService.initialize(
            jwtToken: myToken,
            backendUrl: appBaseUrl,
          ).catchError((e) {
            debugPrint('Push notification init error: $e');
          });

          if (!mounted) return;

          showAppSnackBar(context, 'Signed in successfully! 🎉');

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => EntryScreen(token: myToken)),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isGoogleLoading = false);

      String errorMsg = e.toString().replaceAll('Exception: ', '');
      if (errorMsg.contains('10') || errorMsg.contains('sign_in_failed')) {
        errorMsg = 'Google Sign-in requires SHA-1 in Google Console.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Google Sign-in: $errorMsg',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PreplyLogo(),
          const SizedBox(height: 32),
          Text('Welcome Back 👋', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Login to continue your career journey with Preply.',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 28),
          Form(
            key: _formKey,
            child: Column(
              children: [
                AppTextField(
                  controller: emailController,
                  label: 'Email',
                  hint: 'you@example.com',
                  icon: Icons.email_rounded,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: Validators.email,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: passwordController,
                  label: 'Password',
                  hint: 'Enter your password',
                  icon: Icons.lock_rounded,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  validator: Validators.password,
                  onFieldSubmitted: (_) => loginUser(),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () =>
                  showAppSnackBar(context, 'Password reset coming soon'),
              child: const Text('Forgot Password?'),
            ),
          ),
          const SizedBox(height: 8),
          AnimatedButton(
            text: 'Login',
            isLoading: _isLoading,
            onPressed: loginUser,
          ),
          const SizedBox(height: 24),
          const OrDivider(),
          const SizedBox(height: 24),
          GoogleButton(
            text: _isGoogleLoading ? 'Connecting...' : 'Continue with Google',
            onPressed: _isGoogleLoading ? null : _handleGoogleSignIn,
          ),
          const SizedBox(height: 24),
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  "Don't have an account?",
                  style: theme.textTheme.bodyMedium,
                ),
                TextButton(
                  onPressed: () => AppTransitions.pushReplacement(
                    context,
                    const RegisterPage(),
                  ),
                  child: const Text('Create Account'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
