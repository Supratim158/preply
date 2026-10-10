// File: lib/screens/onboarding/onboarding_page_1.dart
import 'package:flutter/material.dart';

import '../../widgets/animated_button.dart';
import '../../widgets/animated_page_transition.dart';
import '../../widgets/onboarding_layout.dart';
import 'onboarding_page_2.dart';
import 'onboarding_page_3.dart';

class OnboardingPage1 extends StatelessWidget {
  const OnboardingPage1({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingLayout(
      pageIndex: 0,
      mainIcon: Icons.psychology_alt_rounded,
      floatingIcons: const [
        Icons.description_rounded,
        Icons.insights_rounded,
        Icons.auto_awesome_rounded,
      ],
      title: 'Your AI Career Assistant',
      description: 'Analyze your resume, improve your skills and prepare '
          'for interviews.',
      // Skip jumps straight to page 3.
      onSkip: () => AppTransitions.push(
        context,
        const OnboardingPage3(previousIndex: 0),
      ),
      actions: AnimatedButton(
        text: 'Next',
        icon: Icons.arrow_forward_rounded,
        iconAtEnd: true,
        onPressed: () => AppTransitions.push(
          context,
          const OnboardingPage2(),
        ),
      ),
    );
  }
}
