import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int maxLines;
  final bool enabled;
  final List<TextInputFormatter>? inputFormatters;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.validator,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.enabled = true,
    this.inputFormatters,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _isObscure;

  @override
  void initState() {
    super.initState();
    _isObscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Determine the suffix widget (icon or password toggle)
    Widget? effectiveSuffixIcon = widget.suffixIcon;

    if (widget.obscureText) {
      effectiveSuffixIcon = IconButton(
        icon: Icon(
          _isObscure
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        onPressed: () {
          setState(() {
            _isObscure = !_isObscure;
          });
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          obscureText: _isObscure,
          keyboardType: widget.keyboardType,
          maxLines: widget.maxLines,
          enabled: widget.enabled,
          inputFormatters: widget.inputFormatters,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hintText,
            prefixIcon: widget.prefixIcon,
            suffixIcon: effectiveSuffixIcon,
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.3,
            ),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4.0),
                topRight: Radius.circular(4.0),
              ),
              borderSide: BorderSide.none,
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: theme.colorScheme.outline),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2.0,
              ),
            ),
            errorBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: theme.colorScheme.error),
            ),
            focusedErrorBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: theme.colorScheme.error,
                width: 2.0,
              ),
            ),
            contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          ),
          onTapOutside: (event) {
            FocusScope.of(context).unfocus();
          },
        ),
      ],
    );
  }
}
