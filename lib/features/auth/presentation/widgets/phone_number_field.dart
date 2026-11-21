import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

/// Phone number input widget with country code selector.
class PhoneNumberField extends StatefulWidget {
  const PhoneNumberField({
    super.key,
    required this.controller,
    this.selectedCountryCode = '+91',
    this.onCountryCodeChanged,
    this.enabled = true,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String selectedCountryCode;
  final ValueChanged<String>? onCountryCodeChanged;
  final bool enabled;
  final ValueChanged<String>? onSubmitted;

  @override
  State<PhoneNumberField> createState() => _PhoneNumberFieldState();
}

class _PhoneNumberFieldState extends State<PhoneNumberField> {
  late String _currentCode;

  final List<String> _supportedCodes = const ['+91', '+1', '+44', '+61', '+971'];

  @override
  void initState() {
    super.initState();
    _currentCode = widget.selectedCountryCode;
  }

  @override
  Widget build(BuildContext context) {
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Phone Number',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.mainText,
          ),
        ),
        const SizedBox(height: AppSpacing.space8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Country Code Dropdown
            Container(
              height: 52.0,
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppSpacing.cardBorderRadius,
                border: Border.all(
                  color: AppColors.secondaryText.withValues(alpha: 0.25),
                  width: 1.0,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _currentCode,
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.secondaryText,
                    size: 20,
                  ),
                  items: _supportedCodes.map((code) {
                    return DropdownMenuItem<String>(
                      value: code,
                      child: Text(
                        code,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkGreen,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: widget.enabled
                      ? (newCode) {
                          if (newCode != null) {
                            setState(() => _currentCode = newCode);
                            widget.onCountryCodeChanged?.call(newCode);
                          }
                        }
                      : null,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.space12),

            // Number Input Field
            Expanded(
              child: TextFormField(
                controller: widget.controller,
                enabled: widget.enabled,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: widget.onSubmitted,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.mainText,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter 10-digit number',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.secondaryText.withValues(alpha: 0.6),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.space16,
                    vertical: 14.0,
                  ),
                  border: outlineBorder,
                  enabledBorder: outlineBorder,
                  focusedBorder: focusedBorder,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
