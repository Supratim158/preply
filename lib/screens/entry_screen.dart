import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:preply/screens/Interview/interview_screen.dart';
import 'package:preply/screens/home/homescreen.dart';
import 'package:preply/screens/profile/profile_screen.dart';
import 'package:preply/screens/reminders/reminder_screen.dart';
import 'package:preply/screens/resume/resume_cheker_screen.dart';
import 'package:preply/settings/settings.dart';

import '../../widgets/animated_bg.dart';
import '../constants/links.dart';
import '../services/in_app_notification_service.dart';
import 'home/components/notification_bottom_sheet.dart';
import 'profile/services/push_notification_service.dart';

class EntryScreen extends StatefulWidget {
  final dynamic token;
  final int initialIndex;

  const EntryScreen({
    super.key,
    required this.token,
    this.initialIndex = 0,
  });

  static _EntryScreenState? _activeState;

  static bool get hasActiveState =>
      _activeState != null && _activeState!.mounted;

  static void openTab(int index) {
    if (_activeState != null && _activeState!.mounted) {
      _activeState!._changeTab(index);
    }
  }

  @override
  State<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    EntryScreen._activeState = this;
    _currentIndex = widget.initialIndex;
    _initServices();
  }

  @override
  void dispose() {
    if (EntryScreen._activeState == this) {
      EntryScreen._activeState = null;
    }
    super.dispose();
  }

  void _initServices() {
    // Initialize in-app notification tracking
    InAppNotificationService.initialize();

    final tokenStr = widget.token?.toString();
    if (tokenStr != null && tokenStr.isNotEmpty) {
      PushNotificationService.initialize(
        jwtToken: tokenStr,
        backendUrl: appBaseUrl,
      ).catchError((e) {
        debugPrint('Push notification init error: $e');
      });
    }
  }

  void _changeTab(int index) {
    if (index < 0 || index >= 5) return;

    setState(() {
      _currentIndex = index;
    });
  }

  late final List<Widget> _screens = [
    Homescreen(
      onNavigateTab: _changeTab,
    ),
    const ResumeChekerScreen(),
    const InterviewScreen(),
    const ReminderScreen(),
    const ProfileScreen(),
  ];

  final List<String> _titles = const [
    'Preply',
    'Resume Checker',
    'Mock Interview',
    'Reminders',
    'Profile',
  ];

  // Two different action buttons for each page.
  List<Widget> _buildAppBarActions() {
    switch (_currentIndex) {
      case 0:
      // Home
        return [
          _notificationBellIcon(),
          _appBarIcon(
            icon: Icons.settings_outlined,
            tooltip: 'Settings',
            onTap: _openSettings,
          ),
        ];

      case 1:
      // Resume Checker
        return [
          _appBarIcon(
            icon: Icons.upload_file_rounded,
            tooltip: 'Upload Resume',
            onTap: _uploadResume,
          ),
          _appBarIcon(
            icon: Icons.history_rounded,
            tooltip: 'Resume History',
            onTap: _openResumeHistory,
          ),
        ];

      case 2:
      // Mock Interview
        return [
          _appBarIcon(
            icon: Icons.history_rounded,
            tooltip: 'Interview History',
            onTap: _openInterviewHistory,
          ),
          _appBarIcon(
            icon: Icons.tune_rounded,
            tooltip: 'Interview Settings',
            onTap: _openInterviewSettings,
          ),
        ];

      case 3:
      // Reminders
        return [
          _appBarIcon(
            icon: Icons.add_alarm_rounded,
            tooltip: 'Add Reminder',
            onTap: _addReminder,
          ),
          _appBarIcon(
            icon: Icons.filter_list_rounded,
            tooltip: 'Filter Reminders',
            onTap: _filterReminders,
          ),
        ];

      case 4:
      // Profile
        return [
          _appBarIcon(
            icon: Icons.edit_outlined,
            tooltip: 'Edit Profile',
            onTap: _editProfile,
          ),
          _appBarIcon(
            icon: Icons.settings_outlined,
            tooltip: 'Profile Settings',
            onTap: _openSettings,
          ),
        ];

      default:
        return [];
    }
  }

  Widget _appBarIcon({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onTap,
      icon: Icon(
        icon,
        color: Colors.white,
        size: 23,
      ),
    );
  }

  // ── Notification bell with live badge ──────────────────────────
  Widget _notificationBellIcon() {
    return ValueListenableBuilder<int>(
      valueListenable: InAppNotificationService.unreadCountNotifier,
      builder: (context, unreadCount, _) {
        return IconButton(
          tooltip: 'Notifications',
          onPressed: _openNotifications,
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(
                Icons.notifications_none_rounded,
                color: Colors.white,
                size: 23,
              ),
              if (unreadCount > 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF4D4F),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF001A42),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF4D4F).withOpacity(0.5),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 17,
                      minHeight: 17,
                    ),
                    child: Text(
                      unreadCount > 99 ? '99+' : '$unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // ── Open draggable notification sheet ──────────────────────────
  void _openNotifications() {
    NotificationBottomSheet.show(
      context,
      onOpenReminder: (_) {
        _changeTab(3); // Switch to Reminders tab
      },
    );
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  void _uploadResume() {
    _showMessage('Connect your resume upload feature here');
  }

  void _openResumeHistory() {
    _showMessage('Connect your resume history here');
  }

  void _openInterviewHistory() {
    _showMessage('Connect your interview history here');
  }

  void _openInterviewSettings() {
    _showMessage('Connect your interview settings here');
  }

  void _addReminder() {
    _showMessage('Connect your add reminder form here');
  }

  void _filterReminders() {
    _showMessage('Connect your reminder filters here');
  }

  void _editProfile() {
    _showMessage('Connect your profile editor here');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF172B50),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF001A42),
        extendBody: true,
        body: AnimatedBackground(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                snap: true,
                pinned: false,
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 0,

                title: _currentIndex == 0
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/logo.png',
                            height: 32,
                            width: 32,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Preply',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        _titles[_currentIndex],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                actions: _buildAppBarActions(),
              ),

              SliverFillRemaining(
                hasScrollBody: true,
                child: IndexedStack(
                  index: _currentIndex,
                  children: _screens,
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildGlassmorphicNavBar(),
      ),
    );
  }

  Widget _buildGlassmorphicNavBar() {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      margin: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        bottomPadding > 0 ? bottomPadding : 16,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 25,
            sigmaY: 25,
          ),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: Colors.white.withOpacity(0.08),
              border: Border.all(
                color: Colors.white.withOpacity(0.12),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 30,
                  spreadRadius: -5,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _navItem(
                  0,
                  Icons.home_rounded,
                  Icons.home_outlined,
                  'Home',
                ),
                _navItem(
                  1,
                  Icons.description_rounded,
                  Icons.description_outlined,
                  'Resume',
                ),
                _navItem(
                  2,
                  Icons.voice_chat_rounded,
                  Icons.voice_chat_outlined,
                  'Interview',
                ),
                _navItem(
                  3,
                  Icons.event_available_rounded,
                  Icons.calendar_month_rounded,
                  'Reminders',
                ),
                _navItem(
                  4,
                  Icons.person_rounded,
                  Icons.person_outline_rounded,
                  'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(
      int index,
      IconData activeIcon,
      IconData inactiveIcon,
      String label,
      ) {
    final bool isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () => _changeTab(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 6,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isActive ? activeIcon : inactiveIcon,
                key: ValueKey(isActive),
                color: isActive
                    ? Colors.white
                    : Colors.white.withOpacity(0.35),
                size: isActive ? 26 : 24,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 10,
                fontWeight:
                isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive
                    ? Colors.white
                    : Colors.white.withOpacity(0.35),
              ),
              child: Text(label),
            ),
            const SizedBox(height: 3),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              height: 4,
              width: isActive ? 4 : 0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: isActive
                    ? [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.6),
                    blurRadius: 6,
                  ),
                ]
                    : [],
              ),
            ),
          ],
        ),
      ),
    );
  }
}