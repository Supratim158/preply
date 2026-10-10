// File: lib/screens/onboarding/onboarding_page_3.dart
import 'package:flutter/material.dart';

import '../../widgets/animated_button.dart';
import '../../widgets/animated_page_transition.dart';
import '../../widgets/onboarding_layout.dart';
import '../auth/login_page.dart';
import '../auth/register_page.dart';

class OnboardingPage3 extends StatelessWidget {
  const OnboardingPage3({super.key, this.previousIndex = 1});

  /// Page the user came from (used only to animate the indicator).
  final int previousIndex;

  @override
  Widget build(BuildContext context) {
    return OnboardingLayout(
      pageIndex: 2,
      previousIndex: previousIndex,
      mainIcon: Icons.rocket_launch_rounded,
      floatingIcons: const [
        Icons.work_rounded,
        Icons.trending_up_rounded,
        Icons.workspace_premium_rounded,
      ],
      title: 'Build Your Future',
      description: 'Your personalized AI career journey starts with Preply.',
      actions: Column(
        children: [
          AnimatedButton(
            text: 'Get Started',
            onPressed: () => AppTransitions.push(
              context,
              const RegisterPage(),
              type: PageTransitionType.fadeScale,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Already have an account?',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              TextButton(
                onPressed: () => AppTransitions.push(
                  context,
                  const LoginPage(),
                ),
                child: const Text('Login'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
