import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:preply/screens/profile/components/profile_card.dart';
import 'package:preply/screens/profile/components/profile_dashboard_cards.dart';
import 'package:preply/screens/profile/services/cloudinary_service.dart';
import 'package:preply/screens/profile/services/profile_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/app_snackbar.dart';
import '../../utils/google_auth_service.dart';
import '../auth/login_page.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoggingOut = false;
  bool _isLoading = true;

  String _name = '';
  String _email = '';
  String? _profileImageUrl;
  List<Map<String, dynamic>> _education = [];
  List<Map<String, dynamic>> _experience = [];
  List<String> _skills = [];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = await ProfileService.getProfile();
      if (!mounted) return;
      setState(() {
        _applyUserData(user);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      showAppSnackBar(
        context,
        'Failed to load profile: ${e.toString().replaceAll('Exception: ', '')}',
      );
    }
  }

  void _applyUserData(Map<String, dynamic> user) {
    _name = (user['name'] ?? '').toString();
    _email = (user['email'] ?? '').toString();
    _profileImageUrl = user['profile']?.toString();

    if (user['education'] is List) {
      _education = (user['education'] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } else {
      _education = [];
    }

    if (user['experience'] is List) {
      _experience = (user['experience'] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } else {
      _experience = [];
    }

    final rawSkills = user['skills'];
    if (rawSkills is String && rawSkills.trim().isNotEmpty) {
      _skills = rawSkills
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    } else if (rawSkills is List) {
      _skills = rawSkills.map((s) => s.toString().trim()).toList();
    } else {
      _skills = [];
    }
  }

  Future<void> _handleSaveProfile(
    Map<String, dynamic> data,
    XFile? image,
  ) async {
    final payload = <String, dynamic>{
      'name': data['name'],
      'email': data['email'],
      'education': data['education'],
      'experience': data['experience'],
    };

    // Backend requires skills to be a string
    if (data['skills'] is List) {
      payload['skills'] = (data['skills'] as List).join(', ');
    } else if (data['skills'] is String) {
      payload['skills'] = data['skills'];
    }

    if (image != null) {
      final cloudinaryUrl = await CloudinaryService.uploadImage(image);
      payload['profile'] = cloudinaryUrl;
    } else if (_profileImageUrl != null && _profileImageUrl!.isNotEmpty) {
      payload['profile'] = _profileImageUrl;
    }

    final updatedUser = await ProfileService.updateProfile(payload);
    if (!mounted) return;

    setState(() {
      _applyUserData(updatedUser);
    });

    showAppSnackBar(context, 'Profile updated successfully ✨');
  }

  Future<void> _handleDeleteProfile() async {
    try {
      await ProfileService.deleteProfile();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await GoogleAuthService.signOut();

      if (!mounted) return;
      showAppSnackBar(context, 'Account deleted successfully');

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        'Failed to delete account: ${e.toString().replaceAll('Exception: ', '')}',
      );
    }
  }

  Future<void> _logout() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xff0A2550),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Log Out',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to log out of your Preply account?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoggingOut = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await GoogleAuthService.signOut();

      if (!mounted) return;

      showAppSnackBar(context, 'Logged out successfully 👋');

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoggingOut = false);
      showAppSnackBar(context, 'Error logging out: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: Colors.deepPurpleAccent,
      backgroundColor: const Color(0xff0A2550),
      onRefresh: _loadProfile,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 10.0,
                left: 17.0,
                right: 17.0,
                bottom: 100.0,
              ),
              child: Column(
                children: [
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.deepPurpleAccent,
                        ),
                      ),
                    )
                  else
                    ProfileCard(
                      name: _name,
                      email: _email,
                      profileImageUrl: _profileImageUrl,
                      education: _education,
                      experience: _experience,
                      skills: _skills,
                      onSave: _handleSaveProfile,
                      onDelete: _handleDeleteProfile,
                    ),
                  const SizedBox(height: 15),
                  const DashboardStatsCards(),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: _isLoggingOut ? null : _logout,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: Colors.redAccent, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        backgroundColor: Colors.redAccent.withOpacity(0.1),
                      ),
                      icon: _isLoggingOut
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.redAccent,
                              ),
                            )
                          : const Icon(Icons.logout_rounded,
                              color: Colors.redAccent),
                      label: Text(
                        _isLoggingOut ? 'Logging out...' : 'Log Out',
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
