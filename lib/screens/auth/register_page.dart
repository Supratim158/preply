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
import 'login_page.dart';
import 'otp_verification_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> registerUser() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final reqBody = {
        "name": nameController.text.trim(),
        "email": emailController.text.trim(),
        "password": passwordController.text,
      };

      final response = await http.post(
        Uri.parse(registerUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(reqBody),
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (!mounted) return;
      setState(() => _isLoading = false);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          jsonResponse['status'] == true) {
        showAppSnackBar(
          context,
          jsonResponse['message'] ?? 'Account created! Please login to continue.',
        );

        // Redirect to Login page as requested
        AppTransitions.pushReplacement(
          context,
          const LoginPage(),
        );
      } else {
        final message = jsonResponse['message'] ?? 'Registration failed';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              message,
              style: const TextStyle(color: Colors.black, fontSize: 16),
            ),
            backgroundColor: Colors.red,
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
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', myToken);
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PreplyLogo(),
          const SizedBox(height: 32),
          Text('Create Your Account 🚀', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Start your personalized career journey with Preply.',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 28),
          Form(
            key: _formKey,
            child: Column(
              children: [
                AppTextField(
                  controller: nameController,
                  label: 'Full Name',
                  hint: 'Your full name',
                  icon: Icons.person_rounded,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  validator: Validators.name,
                ),
                const SizedBox(height: 16),
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
                  hint: 'At least 6 characters',
                  icon: Icons.lock_rounded,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  validator: Validators.password,
                  onFieldSubmitted: (_) => registerUser(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          AnimatedButton(
            text: 'Create Account',
            isLoading: _isLoading,
            onPressed: registerUser,
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
                  'Already have an account?',
                  style: theme.textTheme.bodyMedium,
                ),
                TextButton(
                  onPressed: () => AppTransitions.pushReplacement(
                    context,
                    const LoginPage(),
                  ),
                  child: const Text('Login'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
