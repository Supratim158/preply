// File: lib/screens/onboarding/onboarding_page_2.dart
import 'package:flutter/material.dart';

import '../../widgets/animated_button.dart';
import '../../widgets/animated_page_transition.dart';
import '../../widgets/onboarding_layout.dart';
import 'onboarding_page_3.dart';

class OnboardingPage2 extends StatelessWidget {
  const OnboardingPage2({super.key});

  @override
  Widget build(BuildContext context) {
    void goToPage3() => AppTransitions.push(
          context,
          const OnboardingPage3(previousIndex: 1),
        );

    return OnboardingLayout(
      pageIndex: 1,
      previousIndex: 0,
      mainIcon: Icons.forum_rounded,
      floatingIcons: const [
        Icons.track_changes_rounded,
        Icons.school_rounded,
        Icons.bolt_rounded,
      ],
      title: 'Prepare Smarter',
      description: 'Practice personalized interviews and identify your '
          'skill gaps.',
      onSkip: goToPage3,
      actions: AnimatedButton(
        text: 'Next',
        icon: Icons.arrow_forward_rounded,
        iconAtEnd: true,
        onPressed: goToPage3,
      ),
    );
  }
}
