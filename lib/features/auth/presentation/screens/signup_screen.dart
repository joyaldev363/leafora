import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_error_message.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/phone_number_field.dart';

/// Screen allowing new users to register their name and phone number.
class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  String _countryCode = '+91';
  String? _localValidationError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    final name = _nameController.text.trim();
    final rawNumber = _phoneController.text.trim();

    if (name.length < 2) {
      setState(() {
        _localValidationError = 'Please enter your full name.';
      });
      return;
    }

    if (rawNumber.length != 10) {
      setState(() {
        _localValidationError = 'Please enter a valid 10-digit phone number.';
      });
      return;
    }

    setState(() => _localValidationError = null);

    final fullPhone = '$_countryCode$rawNumber';
    final success = await ref.read(authNotifierProvider.notifier).sendOtp(
          phone: fullPhone,
          fullName: name,
        );

    if (success && mounted) {
      context.push(
        RouteNames.otpVerification,
        extra: {
          'phone': fullPhone,
          'fullName': name,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final displayedError = _localValidationError ?? authState.errorMessage;

    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.darkGreen,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: AppSpacing.screenPaddingHorizontal,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AuthHeader(
                  title: 'Join Leafora',
                  subtitle:
                      'Create your mindful plant care account in seconds.',
                  logoSize: 72.0,
                ),
                const SizedBox(height: AppSpacing.space32),

                AppTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  hintText: 'e.g. Maya Sharma',
                  prefixIcon: const Icon(
                    Icons.person_outline_rounded,
                    color: AppColors.secondaryText,
                    size: 20,
                  ),
                  enabled: !authState.isLoading,
                ),
                const SizedBox(height: AppSpacing.space16),

                PhoneNumberField(
                  controller: _phoneController,
                  selectedCountryCode: _countryCode,
                  enabled: !authState.isLoading,
                  onCountryCodeChanged: (code) => _countryCode = code,
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
                  text: 'Create Account',
                  isLoading: authState.isLoading,
                  onPressed: _handleSignup,
                ),
                const SizedBox(height: AppSpacing.space24),

                // Link to Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account?',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space4),
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Text(
                        'Sign In',
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
