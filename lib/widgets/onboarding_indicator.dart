// File: lib/widgets/onboarding_indicator.dart
import 'package:flutter/material.dart';

/// Dot indicator. When [fromIndex] differs from [currentIndex] the active dot
/// animates from the previous position on first build (pages are separate
/// routes, so this is what makes the change visible).
class OnboardingIndicator extends StatefulWidget {
  const OnboardingIndicator({
    super.key,
    required this.currentIndex,
    this.fromIndex,
    this.count = 3,
  });

  final int currentIndex;
  final int? fromIndex;
  final int count;

  @override
  State<OnboardingIndicator> createState() => _OnboardingIndicatorState();
}

class _OnboardingIndicatorState extends State<OnboardingIndicator> {
  late int _active = widget.fromIndex ?? widget.currentIndex;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _active = widget.currentIndex);
    });
  }

  @override
  void didUpdateWidget(covariant OnboardingIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _active = widget.currentIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.count, (i) {
        final isActive = i == _active;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: isActive ? 28 : 8,
          decoration: BoxDecoration(
            color: isActive ? primary : primary.withOpacity(0.25),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
