import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/links.dart';
import '../../utils/app_snackbar.dart';
import '../../widgets/animated_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/preply_logo.dart';
import '../entry_screen.dart';
import 'login_page.dart';

class OtpVerificationPage extends StatefulWidget {
  final String email;
  final String? token;

  const OtpVerificationPage({
    super.key,
    required this.email,
    this.token,
  });

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final TextEditingController otpController = TextEditingController();
  bool _isLoading = false;
  bool _isResending = false;

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    final otpText = otpController.text.trim();
    if (otpText.isEmpty || otpText.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter the complete OTP code',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final reqBody = {
        "email": widget.email,
        "otp": otpText,
      };

      final response = await http.post(
        Uri.parse(verifyOtpUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(reqBody),
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (response.statusCode == 200 && jsonResponse['status'] == true) {
        final prefs = await SharedPreferences.getInstance();
        final String userToken = jsonResponse['userToken'] ?? widget.token ?? '';
        if (userToken.isNotEmpty) {
          await prefs.setString('token', userToken);
        }
        if (!mounted) return;

        showAppSnackBar(context, 'Account verified successfully! 🎉');

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => EntryScreen(token: userToken)),
          (route) => false,
        );
      } else {
        final message = jsonResponse['message'] ?? 'Invalid OTP code';
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
    } catch (e) {
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

  Future<void> _resendOtp() async {
    if (_isResending) return;
    setState(() => _isResending = true);

    try {
      final reqBody = {"email": widget.email};

      final response = await http.post(
        Uri.parse(resendOtpUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(reqBody),
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (!mounted) return;
      setState(() => _isResending = false);

      if (response.statusCode == 200 && jsonResponse['status'] == true) {
        showAppSnackBar(context, 'New OTP sent to ${widget.email}');
      } else {
        final message = jsonResponse['message'] ?? 'Failed to resend OTP';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message, style: const TextStyle(color: Colors.black)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isResending = false);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PreplyLogo(),
          const SizedBox(height: 32),
          Text('Verify Your Email ✉️', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'We have sent a 6-digit verification code to:\n${widget.email}',
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.4),
          ),
          const SizedBox(height: 28),
          AppTextField(
            controller: otpController,
            label: 'Verification Code',
            hint: 'Enter 6-digit OTP',
            icon: Icons.shield_outlined,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _verifyOtp(),
          ),
          const SizedBox(height: 24),
          AnimatedButton(
            text: 'Verify Account',
            isLoading: _isLoading,
            onPressed: _verifyOtp,
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: _isResending ? null : _resendOtp,
              child: Text(
                _isResending ? 'Resending OTP...' : 'Resend OTP Code',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
              child: const Text('Back to Login'),
            ),
          ),
        ],
      ),
    );
  }
}
