// File: lib/widgets/onboarding_layout.dart
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'onboarding_illustration.dart';
import 'onboarding_indicator.dart';
import 'preply_logo.dart';

/// Shared layout for all three onboarding pages.
class OnboardingLayout extends StatelessWidget {
  const OnboardingLayout({
    super.key,
    required this.mainIcon,
    required this.floatingIcons,
    required this.title,
    required this.description,
    required this.pageIndex,
    required this.actions,
    this.previousIndex,
    this.onSkip,
  });

  final IconData mainIcon;
  final List<IconData> floatingIcons;
  final String title;
  final String description;
  final int pageIndex;
  final int? previousIndex;
  final VoidCallback? onSkip;
  final Widget actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.backgroundGradient(theme.brightness),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final illustrationSize = math
                  .min(constraints.maxWidth * 0.78, constraints.maxHeight * 0.42)
                  .clamp(180.0, 380.0)
                  .toDouble();

              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 48,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const PreplyLogo(),
                                    if (onSkip != null)
                                      TextButton(
                                        onPressed: onSkip,
                                        child: const Text('Skip'),
                                      ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              OnboardingIllustration(
                                mainIcon: mainIcon,
                                floatingIcons: floatingIcons,
                                size: illustrationSize,
                              ),
                              const Spacer(),
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: 1),
                                duration: const Duration(milliseconds: 600),
                                curve: Curves.easeOutCubic,
                                builder: (context, value, child) => Opacity(
                                  opacity: value,
                                  child: Transform.translate(
                                    offset: Offset(0, (1 - value) * 16),
                                    child: child,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      title,
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.headlineMedium,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      description,
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.bodyLarge,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 28),
                              OnboardingIndicator(
                                currentIndex: pageIndex,
                                fromIndex: previousIndex,
                              ),
                              const SizedBox(height: 28),
                              actions,
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
