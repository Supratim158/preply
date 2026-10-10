// File: lib/widgets/onboarding_illustration.dart
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Icon-based illustration with gently floating chips. No image assets needed.
class OnboardingIllustration extends StatefulWidget {
  const OnboardingIllustration({
    super.key,
    required this.mainIcon,
    required this.floatingIcons,
    required this.size,
  });

  final IconData mainIcon;
  final List<IconData> floatingIcons; // up to 3
  final double size;

  @override
  State<OnboardingIllustration> createState() => _OnboardingIllustrationState();
}

class _OnboardingIllustrationState extends State<OnboardingIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat(reverse: true);

  static const _alignments = [
    Alignment(-0.92, -0.4),
    Alignment(0.95, 0.0),
    Alignment(-0.4, 0.92),
  ];
  static const _chipColors = [
    AppColors.primary,
    Color(0xFF0EA5E9),
    AppColors.accent,
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final size = widget.size;
    final chipSize = size * 0.2;

    return SizedBox(
      width: size,
      height: size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = Curves.easeInOut.transform(_controller.value) - 0.5;
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.2),
                      AppColors.primary.withOpacity(0.02),
                    ],
                  ),
                ),
              ),
              Transform.translate(
                offset: Offset(0, t * 10),
                child: Container(
                  width: size * 0.58,
                  height: size * 0.58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.brandGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 40,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.mainIcon,
                    color: Colors.white,
                    size: size * 0.28,
                  ),
                ),
              ),
              for (var i = 0; i < widget.floatingIcons.length && i < 3; i++)
                Align(
                  alignment: _alignments[i],
                  child: Transform.translate(
                    offset: Offset(0, i.isEven ? -t * 14 : t * 14),
                    child: Container(
                      width: chipSize,
                      height: chipSize,
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(chipSize * 0.32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.floatingIcons[i],
                        color: _chipColors[i],
                        size: chipSize * 0.5,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
