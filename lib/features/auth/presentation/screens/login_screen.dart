import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_error_message.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/phone_number_field.dart';

/// Screen enabling users to sign in via Phone OTP.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late final TextEditingController _phoneController;
  String _countryCode = '+91';
  String? _localValidationError;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    final rawNumber = _phoneController.text.trim();
    if (rawNumber.length != 10) {
      setState(() {
        _localValidationError = 'Please enter a valid 10-digit phone number.';
      });
      return;
    }

    setState(() {
      _localValidationError = null;
    });

    final fullPhone = '$_countryCode$rawNumber';
    final success = await ref.read(authNotifierProvider.notifier).sendOtp(
          phone: fullPhone,
        );

    if (success && mounted) {
      context.push(
        RouteNames.otpVerification,
        extra: {'phone': fullPhone},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final displayedError = _localValidationError ?? authState.errorMessage;

    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: AppSpacing.screenPaddingHorizontal,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: AppSpacing.space24),
                const AuthHeader(
                  title: 'Welcome to Leafora',
                  subtitle:
                      'Your plants deserve the best care. Sign in to continue.',
                ),
                const SizedBox(height: AppSpacing.space32),

                PhoneNumberField(
                  controller: _phoneController,
                  selectedCountryCode: _countryCode,
                  enabled: !authState.isLoading,
                  onCountryCodeChanged: (code) => _countryCode = code,
                  onSubmitted: (_) => _handleContinue(),
                ),
                const SizedBox(height: AppSpacing.space16),

                if (displayedError != null) ...[
                  AuthErrorMessage(
                    message: displayedError,
                    onDismiss: () {
                      setState(() => _localValidationError = null);
                      ref.read(authNotifierProvider.notifier).clearError();
                    },
                  ),
                  const SizedBox(height: AppSpacing.space16),
                ],

                AuthPrimaryButton(
                  text: 'Continue',
                  isLoading: authState.isLoading,
                  onPressed: _handleContinue,
                ),
                const SizedBox(height: AppSpacing.space24),

                // Terms and Conditions text
                Text(
                  'By continuing, you agree to Leafora\'s Terms of Service and Privacy Policy.',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.secondaryText,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.space32),

                // Link to Sign Up
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space4),
                    GestureDetector(
                      onTap: () {
                        context.push(RouteNames.signup);
                      },
                      child: Text(
                        'Sign Up',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
