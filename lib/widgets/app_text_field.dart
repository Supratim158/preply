// File: lib/widgets/app_text_field.dart
import 'package:flutter/material.dart';

/// Consistent text field used across auth screens. The caller owns the
/// [controller] (and is responsible for disposing it).
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.isPassword = false,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final bool isPassword;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  final FocusNode _focusNode = FocusNode();
  late bool _obscure = widget.isPassword;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (_focused != _focusNode.hasFocus) {
      setState(() => _focused = _focusNode.hasFocus);
    }
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChange)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    OutlineInputBorder border(Color color, [double width = 1.2]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _focused
                ? cs.primary.withOpacity(0.18)
                : Colors.black.withOpacity(0.03),
            blurRadius: _focused ? 16 : 8,
            offset: Offset(0, _focused ? 6 : 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        obscureText: _obscure,
        keyboardType: widget.isPassword
            ? TextInputType.visiblePassword
            : widget.keyboardType,
        textInputAction: widget.textInputAction,
        textCapitalization: widget.textCapitalization,
        validator: widget.validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onFieldSubmitted: widget.onFieldSubmitted,
        style: TextStyle(
          color: cs.onSurface,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          hintStyle: TextStyle(color: cs.onSurfaceVariant.withOpacity(0.7)),
          filled: true,
          fillColor: cs.surface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          prefixIcon: Icon(
            widget.icon,
            color: _focused ? cs.primary : cs.onSurfaceVariant,
          ),
          suffixIcon: widget.isPassword
              ? IconButton(
                  tooltip: _obscure ? 'Show password' : 'Hide password',
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: cs.onSurfaceVariant,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                )
              : null,
          floatingLabelStyle: TextStyle(color: cs.primary),
          enabledBorder: border(cs.outline),
          focusedBorder: border(cs.primary, 1.8),
          errorBorder: border(cs.error),
          focusedErrorBorder: border(cs.error, 1.8),
        ),
      ),
    );
  }
}
