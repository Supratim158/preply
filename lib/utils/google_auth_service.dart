import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import '../constants/links.dart';

class GoogleAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  static Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) {
        // User canceled sign-in
        return null;
      }

      final GoogleSignInAuthentication auth = await account.authentication;

      final reqBody = {
        "idToken": auth.idToken,
        "email": account.email,
        "name": account.displayName ?? account.email.split('@')[0],
        "picture": account.photoUrl,
        "googleId": account.id,
      };

      final response = await http.post(
        Uri.parse(googleLoginUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(reqBody),
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonResponse['userToken'] != null) {
        return jsonResponse;
      } else {
        throw Exception(jsonResponse['message'] ?? 'Google authentication failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
  }
}
