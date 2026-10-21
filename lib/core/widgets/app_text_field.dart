import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';

/// Reusable text form field styled according to Leafora design guidelines.
/// Supports labels, hints, validation, input types, and password obscuring toggle.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.initialValue,
    this.label,
    this.hintText,
    this.validator,
    this.keyboardType,
    this.isPassword = false,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.onChanged,
    this.maxLines = 1,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  final TextEditingController? controller;
  final String? initialValue;
  final String? label;
  final String? hintText;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final bool isPassword;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final int maxLines;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  void _toggleObscure() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget? effectiveSuffixIcon = widget.suffixIcon;

    if (widget.isPassword) {
      effectiveSuffixIcon = IconButton(
        icon: Icon(
          _obscureText
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: AppColors.secondaryText,
          size: 20,
        ),
        onPressed: _toggleObscure,
        splashRadius: 20,
      );
    }

    final outlineBorder = OutlineInputBorder(
      borderRadius: AppSpacing.cardBorderRadius,
      borderSide: BorderSide(
        color: AppColors.secondaryText.withValues(alpha: 0.25),
        width: 1.0,
      ),
    );

    final focusedBorder = const OutlineInputBorder(
      borderRadius: AppSpacing.cardBorderRadius,
      borderSide: BorderSide(color: AppColors.primaryGreen, width: 1.5),
    );

    final errorBorder = OutlineInputBorder(
      borderRadius: AppSpacing.cardBorderRadius,
      borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.mainText,
            ),
          ),
          const SizedBox(height: AppSpacing.space8),
        ],
        TextFormField(
          controller: widget.controller,
          initialValue: widget.initialValue,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          obscureText: _obscureText,
          enabled: widget.enabled,
          onChanged: widget.onChanged,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          textInputAction: widget.textInputAction,
          onFieldSubmitted: widget.onFieldSubmitted,
          style: AppTextStyles.bodyLarge.copyWith(
            color: widget.enabled
                ? AppColors.mainText
                : AppColors.secondaryText.withValues(alpha: 0.5),
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.secondaryText.withValues(alpha: 0.7),
            ),
            filled: true,
            fillColor: widget.enabled
                ? Colors.white
                : AppColors.sageGreen.withValues(alpha: 0.2),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space16,
              vertical: AppSpacing.space12,
            ),
            prefixIcon: widget.prefixIcon,
            suffixIcon: effectiveSuffixIcon,
            border: outlineBorder,
            enabledBorder: outlineBorder,
            focusedBorder: focusedBorder,
            errorBorder: errorBorder,
            focusedErrorBorder: errorBorder.copyWith(
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
