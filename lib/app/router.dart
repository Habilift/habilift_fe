import 'package:go_router/go_router.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/onboarding/presentation/screens/welcome_screen.dart';
import '../../features/onboarding/presentation/screens/user_type_screen.dart';
import '../../features/onboarding/presentation/screens/mission_screen.dart';
import '../../features/auth/presentation/screens/auth_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/auth/presentation/screens/profile_setup_screen.dart';
import '../../features/home/presentation/screens/dashboard_screen.dart';
import '../../features/assessment/presentation/screens/assessment_intro_screen.dart';
import '../../features/assessment/presentation/screens/assessment_question_screen.dart';
import '../../features/assessment/presentation/screens/assessment_result_screen.dart';
import '../../features/video_session/presentation/screens/pre_session_check_screen.dart';
import '../../features/video_session/presentation/screens/active_session_screen.dart';
import '../../features/video_session/presentation/screens/post_session_screen.dart';
import '../../features/forum/presentation/screens/forum_home_screen.dart';
import '../../features/forum/presentation/screens/category_threads_screen.dart';
import '../../features/forum/presentation/screens/thread_detail_screen.dart';
import '../../features/forum/presentation/screens/create_post_screen.dart';

final goRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/mission',
      builder: (context, state) => const MissionScreen(),
    ),
    GoRoute(
      path: '/user-type',
      builder: (context, state) => const UserTypeScreen(),
    ),
    GoRoute(path: '/auth', builder: (context, state) => const AuthScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/otp', builder: (context, state) => const OtpScreen()),
    GoRoute(
      path: '/profile-setup',
      builder: (context, state) => const ProfileSetupScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/assessment',
      builder: (context, state) => const AssessmentIntroScreen(),
    ),
    GoRoute(
      path: '/assessment/question',
      builder: (context, state) => const AssessmentQuestionScreen(),
    ),
    GoRoute(
      path: '/assessment/result',
      builder: (context, state) => const AssessmentResultScreen(),
    ),
    GoRoute(
      path: '/session/pre-check/:sessionId',
      builder: (context, state) =>
          PreSessionCheckScreen(sessionId: state.pathParameters['sessionId']!),
    ),
    GoRoute(
      path: '/session/active/:sessionId',
      builder: (context, state) =>
          ActiveSessionScreen(sessionId: state.pathParameters['sessionId']!),
    ),
    GoRoute(
      path: '/session/post/:sessionId',
      builder: (context, state) =>
          PostSessionScreen(sessionId: state.pathParameters['sessionId']!),
    ),
    // Forum Routes
    GoRoute(
      path: '/forum',
      builder: (context, state) => const ForumHomeScreen(),
    ),
    GoRoute(
      path: '/forum/category/:id',
      builder: (context, state) =>
          CategoryThreadsScreen(categoryId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/forum/thread/:id',
      builder: (context, state) =>
          ThreadDetailScreen(threadId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/forum/create',
      builder: (context, state) {
        final categoryId = state.uri.queryParameters['categoryId'];
        return CreatePostScreen(categoryId: categoryId);
      },
    ),
  ],
);
