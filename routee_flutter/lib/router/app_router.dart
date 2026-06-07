import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/home/home_screen.dart';
import '../screens/explore/explore_screen.dart';
import '../screens/detail/detail_screen.dart';
import '../screens/trip/trip_screen.dart';
import '../screens/map/map_screen.dart';
import '../screens/transport/transport_screen.dart';
import '../screens/rental/rental_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/payment/payment_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/tracking/driver_tracking_screen.dart';
import '../widgets/common/main_scaffold.dart';
import '../widgets/common/auth_gate.dart';
import '../screens/splash/splash_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) => NoTransitionPage(
          child: SplashScreen(
            onFinished: () {
              final auth = context.read<AuthProvider>();
              if (auth.isLoggedIn) {
                context.go('/');
              } else {
                context.go('/login');
              }
            },
          ),
        ),
      ),

      // Auth routes (no bottom nav)
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Shell route (with bottom nav)
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const HomeScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 800),
            ),
          ),
          GoRoute(
            path: '/explore',
            pageBuilder: (context, state) {
              final cat = state.uri.queryParameters['category'];
              return NoTransitionPage(child: ExploreScreen(initialCategory: cat));
            },
          ),
          GoRoute(
            path: '/trip',
            pageBuilder: (context, state) => const NoTransitionPage(child: TripScreen()),
          ),
          GoRoute(
            path: '/map',
            pageBuilder: (context, state) {
              final modeParam = state.uri.queryParameters['mode'];
              final mode = modeParam == 'navigate' ? MapMode.navigate : MapMode.explore;
              return NoTransitionPage(child: MapScreen(mode: mode));
            },
          ),
          GoRoute(
            path: '/rental',
            pageBuilder: (context, state) => const NoTransitionPage(child: RentalScreen()),
          ),
        ],
      ),

      // Detail (no bottom nav)
      GoRoute(
        path: '/detail/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return DetailScreen(id: id);
        },
      ),

      // Profile (no bottom nav)
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),

      // Transport (open access - view only)
      GoRoute(
        path: '/transport',
        builder: (context, state) => const TransportScreen(),
      ),

      // Commercial routes (auth gated)
      GoRoute(
        path: '/payment',
        builder: (context, state) => const AuthGate(child: PaymentScreen()),
      ),
      GoRoute(
        path: '/chat/:driverId',
        builder: (context, state) {
          final driverId = state.pathParameters['driverId']!;
          return AuthGate(child: ChatScreen(driverId: driverId));
        },
      ),
      GoRoute(
        path: '/driver-tracking/:rentalId',
        builder: (context, state) {
          final rentalId = state.pathParameters['rentalId']!;
          return AuthGate(child: DriverTrackingScreen(rentalId: rentalId));
        },
      ),
    ],
  );
}
