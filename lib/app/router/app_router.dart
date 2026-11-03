import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/ai_doctor/presentation/screens/ai_doctor_screen.dart';
import '../../features/ai_doctor/presentation/screens/health_report_screen.dart';
import '../../features/ai_doctor/presentation/screens/plant_analysis_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_verification_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/discover/presentation/screens/article_details_screen.dart';
import '../../features/discover/presentation/screens/discover_screen.dart';
import '../../features/discover/presentation/screens/plant_guide_details_screen.dart';
import '../../features/discover/presentation/screens/saved_articles_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/my_plants/presentation/screens/add_plant_details_screen.dart';
import '../../features/my_plants/presentation/screens/add_plant_photo_screen.dart';
import '../../features/my_plants/presentation/screens/identify_plant_screen.dart';
import '../../features/my_plants/presentation/screens/my_plants_screen.dart';
import '../../features/my_plants/presentation/screens/plant_details_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/help_support_screen.dart';
import '../../features/profile/presentation/screens/notification_settings_screen.dart';
import '../../features/profile/presentation/screens/plant_care_preferences_screen.dart';
import '../../features/profile/presentation/screens/privacy_policy_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../shell/main_shell_screen.dart';
import 'route_names.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: RouteNames.initial,
  routes: <RouteBase>[
    // -------------------------------------------------------------------------
    // Standalone Full-Screen Routes (No persistent bottom navigation)
    // -------------------------------------------------------------------------
    GoRoute(
      path: RouteNames.initial,
      builder: (BuildContext context, GoRouterState state) {
        return const SplashScreen();
      },
    ),
    GoRoute(
      path: RouteNames.onboarding,
      builder: (BuildContext context, GoRouterState state) {
        return const OnboardingScreen();
      },
    ),
    GoRoute(
      path: RouteNames.login,
      builder: (BuildContext context, GoRouterState state) {
        return const LoginScreen();
      },
    ),
    GoRoute(
      path: RouteNames.otpVerification,
      builder: (BuildContext context, GoRouterState state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final phone = extra['phone'] as String? ?? '';
        final fullName = extra['fullName'] as String?;
        return OtpVerificationScreen(phone: phone, fullName: fullName);
      },
    ),
    GoRoute(
      path: RouteNames.signup,
      builder: (BuildContext context, GoRouterState state) {
        return const SignupScreen();
      },
    ),
    GoRoute(
      path: RouteNames.editProfile,
      builder: (BuildContext context, GoRouterState state) {
        return const EditProfileScreen();
      },
    ),

    // Plant Management Full-Screen Workflow Routes
    GoRoute(
      path: RouteNames.addPlantPhoto,
      builder: (BuildContext context, GoRouterState state) {
        return const AddPlantPhotoScreen();
      },
    ),
    GoRoute(
      path: RouteNames.addPlantIdentify,
      builder: (BuildContext context, GoRouterState state) {
        return const IdentifyPlantScreen();
      },
    ),
    GoRoute(
      path: RouteNames.addPlantDetails,
      builder: (BuildContext context, GoRouterState state) {
        return const AddPlantDetailsScreen();
      },
    ),
    GoRoute(
      path: RouteNames.plantDetails,
      builder: (BuildContext context, GoRouterState state) {
        final plantId = state.pathParameters['plantId'] ?? '';
        return PlantDetailsScreen(plantId: plantId);
      },
    ),

    // AI Doctor Module Full-Screen Routes
    GoRoute(
      path: RouteNames.aiDoctorAnalyze,
      builder: (BuildContext context, GoRouterState state) {
        return const PlantAnalysisScreen();
      },
    ),
    GoRoute(
      path: RouteNames.aiDoctorReport,
      builder: (BuildContext context, GoRouterState state) {
        return const HealthReportScreen();
      },
    ),

    // Discover Module Full-Screen Routes
    GoRoute(
      path: RouteNames.discoverArticle,
      builder: (BuildContext context, GoRouterState state) {
        final articleId = state.pathParameters['articleId'] ?? '';
        return ArticleDetailsScreen(articleId: articleId);
      },
    ),
    GoRoute(
      path: RouteNames.discoverPlantGuide,
      builder: (BuildContext context, GoRouterState state) {
        final plantId = state.pathParameters['plantId'] ?? '';
        return PlantGuideDetailsScreen(plantId: plantId);
      },
    ),
    GoRoute(
      path: RouteNames.discoverSaved,
      builder: (BuildContext context, GoRouterState state) {
        return const SavedArticlesScreen();
      },
    ),

    // Profile Module Full-Screen Routes
    GoRoute(
      path: RouteNames.profileEdit,
      builder: (BuildContext context, GoRouterState state) {
        return const EditProfileScreen();
      },
    ),
    GoRoute(
      path: RouteNames.profileNotifications,
      builder: (BuildContext context, GoRouterState state) {
        return const NotificationSettingsScreen();
      },
    ),
    GoRoute(
      path: RouteNames.profilePlantPreferences,
      builder: (BuildContext context, GoRouterState state) {
        return const PlantCarePreferencesScreen();
      },
    ),
    GoRoute(
      path: RouteNames.profileHelp,
      builder: (BuildContext context, GoRouterState state) {
        return const HelpSupportScreen();
      },
    ),
    GoRoute(
      path: RouteNames.profilePrivacy,
      builder: (BuildContext context, GoRouterState state) {
        return const PrivacyPolicyScreen();
      },
    ),

    // -------------------------------------------------------------------------
    // Persistent Shell Route (Main 5-Tab Bottom Navigation)
    // -------------------------------------------------------------------------
    StatefulShellRoute.indexedStack(
      builder:
          (
            BuildContext context,
            GoRouterState state,
            StatefulNavigationShell navigationShell,
          ) {
            return MainShellScreen(navigationShell: navigationShell);
          },
      branches: <StatefulShellBranch>[
        // Tab 1: Home
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: RouteNames.home,
              builder: (BuildContext context, GoRouterState state) {
                return const HomeScreen();
              },
            ),
          ],
        ),

        // Tab 2: My Plants
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: RouteNames.myPlants,
              builder: (BuildContext context, GoRouterState state) {
                return const MyPlantsScreen();
              },
            ),
          ],
        ),

        // Tab 3: AI Doctor
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: RouteNames.aiDoctor,
              builder: (BuildContext context, GoRouterState state) {
                return const AiDoctorScreen();
              },
            ),
          ],
        ),

        // Tab 4: Discover
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: RouteNames.discover,
              builder: (BuildContext context, GoRouterState state) {
                return const DiscoverScreen();
              },
            ),
          ],
        ),

        // Tab 5: Profile
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: RouteNames.profile,
              builder: (BuildContext context, GoRouterState state) {
                return const ProfileScreen();
              },
            ),
          ],
        ),
      ],
    ),
  ],
);
