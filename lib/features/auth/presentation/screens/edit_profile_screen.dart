import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_error_message.dart';
import '../widgets/auth_primary_button.dart';

/// Screen allowing the user to view and modify their profile details.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authNotifierProvider).user;
    _nameController = TextEditingController(text: user?.fullName ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) return;

    final success = await ref
        .read(authNotifierProvider.notifier)
        .updateProfile(newName);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully.'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: AppTextStyles.sectionTitle.copyWith(
            color: AppColors.darkGreen,
          ),
        ),
        centerTitle: true,
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
        child: SingleChildScrollView(
          padding: AppSpacing.screenPaddingHorizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.space24),
              Center(
                child: CircleAvatar(
                  radius: 44,
                  backgroundColor: AppColors.sageGreen,
                  child: const Icon(
                    Icons.person_rounded,
                    color: AppColors.primaryGreen,
                    size: 48,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.space32),

              AppTextField(
                controller: _nameController,
                label: 'Full Name',
                hintText: 'Enter your full name',
                prefixIcon: const Icon(
                  Icons.person_outline_rounded,
                  color: AppColors.secondaryText,
                  size: 20,
                ),
                enabled: !authState.isLoading,
              ),
              const SizedBox(height: AppSpacing.space16),

              AppTextField(
                controller: _phoneController,
                label: 'Verified Phone Number',
                enabled: false,
                prefixIcon: const Icon(
                  Icons.phone_outlined,
                  color: AppColors.secondaryText,
                  size: 20,
                ),
              ),
              const SizedBox(height: AppSpacing.space24),

              if (authState.errorMessage != null) ...[
                AuthErrorMessage(
                  message: authState.errorMessage!,
                  onDismiss: () =>
                      ref.read(authNotifierProvider.notifier).clearError(),
                ),
                const SizedBox(height: AppSpacing.space16),
              ],

              AuthPrimaryButton(
                text: 'Save Changes',
                isLoading: authState.isLoading,
                onPressed: _handleSave,
              ),
              const SizedBox(height: AppSpacing.space24),
            ],
          ),
        ),
      ),
    );
  }
}
