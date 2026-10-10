// File: lib/widgets/animated_button.dart
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Gradient button with a press-scale animation and optional loading state.
class AnimatedButton extends StatefulWidget {
  const AnimatedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.iconAtEnd = false,
    this.isLoading = false,
    this.height = 56,
    this.gradient = AppColors.brandGradient,
  });

  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool iconAtEnd;
  final bool isLoading;
  final double height;
  final Gradient gradient;

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.isLoading;

    final label = Text(
      widget.text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
    );
    final icon = widget.icon == null
        ? null
        : Icon(widget.icon, color: Colors.white, size: 20);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? (_) => _setPressed(true) : null,
      onTapUp: enabled ? (_) => _setPressed(false) : null,
      onTapCancel: enabled ? () => _setPressed(false) : null,
      onTap: enabled ? widget.onPressed : null,
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: widget.onPressed == null ? 0.5 : 1,
          duration: const Duration(milliseconds: 200),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: widget.height,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: widget.gradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary
                      .withOpacity(_pressed ? 0.15 : 0.35),
                  blurRadius: _pressed ? 8 : 18,
                  offset: Offset(0, _pressed ? 3 : 8),
                ),
              ],
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: widget.isLoading
                    ? const SizedBox(
                        key: ValueKey('loading'),
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        key: const ValueKey('label'),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (icon != null && !widget.iconAtEnd) ...[
                            icon,
                            const SizedBox(width: 8),
                          ],
                          Flexible(child: label),
                          if (icon != null && widget.iconAtEnd) ...[
                            const SizedBox(width: 8),
                            icon,
                          ],
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
