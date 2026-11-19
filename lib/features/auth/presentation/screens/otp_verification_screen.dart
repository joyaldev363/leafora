import 'dart:async';
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
import '../widgets/otp_input_field.dart';

/// Screen managing 6-digit OTP code verification.
class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({
    super.key,
    required this.phone,
    this.fullName,
  });

  final String phone;
  final String? fullName;

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  String _enteredOtp = '';
  int _resendCooldown = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCooldownTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCooldownTimer() {
    setState(() => _resendCooldown = 60);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown > 0) {
        setState(() => _resendCooldown--);
      } else {
        timer.cancel();
      }
    });
  }

  String _formatMaskedPhone(String phone) {
    if (phone.length <= 6) return phone;
    final prefix = phone.substring(0, phone.length - 6);
    final suffix = phone.substring(phone.length - 2);
    return '$prefix****$suffix';
  }

  Future<void> _handleVerify() async {
    if (_enteredOtp.length != 6) return;

    final success = await ref.read(authNotifierProvider.notifier).verifyOtp(
          phone: widget.phone,
          token: _enteredOtp,
          fullName: widget.fullName,
        );

    if (success && mounted) {
      context.go(RouteNames.home);
    }
  }

  Future<void> _handleResend() async {
    if (_resendCooldown > 0) return;

    final success = await ref.read(authNotifierProvider.notifier).sendOtp(
          phone: widget.phone,
          fullName: widget.fullName,
        );

    if (success && mounted) {
      _startCooldownTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A fresh verification code has been dispatched.'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

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
                AuthHeader(
                  title: 'Verify your phone',
                  subtitle:
                      'Enter the 6-digit code sent to ${_formatMaskedPhone(widget.phone)}',
                  logoSize: 72.0,
                ),
                const SizedBox(height: AppSpacing.space32),

                OtpInputField(
                  length: 6,
                  enabled: !authState.isLoading,
                  onChanged: (val) => _enteredOtp = val,
                  onCompleted: (val) {
                    _enteredOtp = val;
                    _handleVerify();
                  },
                ),
                const SizedBox(height: AppSpacing.space16),

                if (authState.errorMessage != null) ...[
                  AuthErrorMessage(
                    message: authState.errorMessage!,
                    onDismiss: () =>
                        ref.read(authNotifierProvider.notifier).clearError(),
                  ),
                  const SizedBox(height: AppSpacing.space16),
                ],

                AuthPrimaryButton(
                  text: 'Verify & Continue',
                  isLoading: authState.isLoading,
                  isEnabled: _enteredOtp.length == 6,
                  onPressed: _handleVerify,
                ),
                const SizedBox(height: AppSpacing.space24),

                // Resend Timer Option
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Didn't receive the code?",
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space8),
                    if (_resendCooldown > 0)
                      Text(
                        'Resend in ${_resendCooldown}s',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: _handleResend,
                        child: Text(
                          'Resend OTP',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space16),

                // Change Phone Number Option
                TextButton(
                  onPressed: () => context.pop(),
                  child: Text(
                    'Change phone number',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
