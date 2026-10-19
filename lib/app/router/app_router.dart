import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'route_names.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: RouteNames.initial,
  routes: <RouteBase>[
    GoRoute(
      path: RouteNames.initial,
      builder: (BuildContext context, GoRouterState state) {
        return const _PlaceholderScreen();
      },
    ),
  ],
);

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPaddingAll,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.sageGreen,
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                  ),
                  child: const Icon(
                    Icons.eco_rounded,
                    color: AppColors.primaryGreen,
                    size: 44,
                  ),
                ),
                const SizedBox(height: AppSpacing.space24),
                const Text(
                  'Leafora',
                  style: AppTextStyles.headingLarge,
                ),
                const SizedBox(height: AppSpacing.space8),
                const Text(
                  'Your mindful plant companion',
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
