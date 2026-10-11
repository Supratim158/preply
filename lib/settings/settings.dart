
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback? onEditProfile;
  final VoidCallback? onPrivacy;
  final VoidCallback? onHelp;
  final VoidCallback? onLogout;
  final ValueChanged<bool>? onThemeChanged;
  final ValueChanged<bool>? onNotificationsChanged;

  const SettingsScreen({
    super.key,
    this.onEditProfile,
    this.onPrivacy,
    this.onHelp,
    this.onLogout,
    this.onThemeChanged,
    this.onNotificationsChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;
  bool darkModeEnabled = true;

  static const String _notifPrefKey = 'push_notifications_enabled';

  static const Color background = Color(0xFF10131F);
  static const Color surface = Color(0xFF1B2031);
  static const Color accent = Color(0xFF9B87F5);
  static const Color muted = Color(0xFFA5ABC1);

  @override
  void initState() {
    super.initState();
    _loadNotificationPreference();
  }

  Future<void> _loadNotificationPreference() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        notificationsEnabled = prefs.getBool(_notifPrefKey) ?? true;
      });
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    setState(() => notificationsEnabled = value);
    widget.onNotificationsChanged?.call(value);

    // Persist the preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notifPrefKey, value);

    // Actually enable/disable FCM auto-init
    await FirebaseMessaging.instance.setAutoInitEnabled(value);

    if (!value) {
      // Delete the token so backend stops sending to this device
      await FirebaseMessaging.instance.deleteToken();
    } else {
      // Re-fetch the token so backend can start sending again
      final token = await FirebaseMessaging.instance.getToken();
      debugPrint('FCM re-enabled, token: $token');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                _iconButton(
                  Icons.arrow_back_rounded,
                  () => Navigator.maybePop(context),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Settings',
                        style: TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Personalize your experience',
                        style: TextStyle(color: muted, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.settings_outlined,
                  color: accent,
                  size: 27,
                ),
              ],
            ),

            const SizedBox(height: 28),

            _sectionLabel('ACCOUNT'),

            _card([
              _navigationTile(
                icon: Icons.person_outline_rounded,
                title: 'Edit Profile',
                subtitle: 'Update your personal information',
                onTap: widget.onEditProfile,
              ),
              _divider(),
              _navigationTile(
                icon: Icons.lock_outline_rounded,
                title: 'Privacy & Security',
                subtitle: 'Password and account security',
                onTap: widget.onPrivacy,
              ),
            ]),

            const SizedBox(height: 26),

            _sectionLabel('PREFERENCES'),

            _card([
              _switchTile(
                icon: Icons.notifications_none_rounded,
                title: 'Push Notifications',
                subtitle: 'Reminders and interview alerts',
                value: notificationsEnabled,
                onChanged: _toggleNotifications,
              ),
              _divider(),
              _switchTile(
                icon: Icons.dark_mode_outlined,
                title: 'Dark Mode',
                subtitle: 'Customize your app appearance',
                value: darkModeEnabled,
                onChanged: (value) {
                  setState(() => darkModeEnabled = value);
                  widget.onThemeChanged?.call(value);
                },
              ),
            ]),

            const SizedBox(height: 26),

            _sectionLabel('SUPPORT'),

            _card([
              _navigationTile(
                icon: Icons.help_outline_rounded,
                title: 'Help & Support',
                subtitle: 'Get help with Preply',
                onTap: widget.onHelp,
              ),
              _divider(),
              _navigationTile(
                icon: Icons.info_outline_rounded,
                title: 'About Preply',
                subtitle: 'Version 1.0.0',
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'Preply',
                    applicationVersion: '1.0.0',
                    applicationLegalese:
                        'Your AI-powered career companion.',
                  );
                },
              ),
            ]),

            const SizedBox(height: 28),

            InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: _confirmLogout,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF291D2A),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFF49303B),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.logout_rounded, color: Color(0xFFF87171)),
                    SizedBox(width: 14),
                    Text(
                      'Log Out',
                      style: TextStyle(
                        color: Color(0xFFFCA5A5),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Spacer(),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFFF87171),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            const Center(
              child: Text(
                'PREPLY  •  Your career, your future',
                style: TextStyle(
                  color: Color(0xFF777F99),
                  fontSize: 11,
                  letterSpacing: 1.2,
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          color: muted,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _card(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF30364B)),
      ),
      child: Column(children: children),
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.only(left: 70),
      child: Divider(
        height: 1,
        thickness: 0.7,
        color: Color(0xFF30364B),
      ),
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: const Color(0xFF252A40),
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: SizedBox(
          height: 46,
          width: 46,
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }

  Widget _navigationTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 5,
      ),
      leading: _leadingIcon(icon),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          subtitle,
          style: const TextStyle(color: muted, fontSize: 12),
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: muted,
      ),
      onTap: onTap ??
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$title is not connected yet')),
            );
          },
    );
  }

  Widget _switchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 5,
      ),
      leading: _leadingIcon(icon),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          subtitle,
          style: const TextStyle(color: muted, fontSize: 12),
        ),
      ),
      trailing: Switch.adaptive(
        value: value,
        activeTrackColor: accent,
        onChanged: onChanged,
      ),
    );
  }

  Widget _leadingIcon(IconData icon) {
    return Container(
      height: 43,
      width: 43,
      decoration: BoxDecoration(
        color: const Color(0xFF302C4C),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(icon, color: const Color(0xFFC4B5FD), size: 22),
    );
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: surface,
        title: const Text(
          'Log Out?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to log out of your account?',
          style: TextStyle(color: muted),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: muted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Log Out',
              style: TextStyle(color: Color(0xFFF87171)),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true && mounted) {
      if (widget.onLogout != null) {
        widget.onLogout!();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Connect your logout API here.'),
          ),
        );
      }
    }
  }
}
