import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/home/home_screen.dart';
import '../screens/explore/explore_screen.dart';
import '../screens/detail/detail_screen.dart';
import '../screens/trip/trip_screen.dart';
import '../screens/map/map_screen.dart';
import '../screens/transport/transport_screen.dart';
import '../screens/umkm/umkm_screen.dart';
import '../widgets/common/main_scaffold.dart';
import '../screens/splash/splash_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) => NoTransitionPage(
          child: SplashScreen(
            onFinished: () => context.go('/'),
          ),
        ),
      ),
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
            path: '/umkm',
            pageBuilder: (context, state) => const NoTransitionPage(child: UmkmScreen()),
          ),
        ],
      ),
      GoRoute(
        path: '/detail/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return DetailScreen(id: id);
        },
      ),
      GoRoute(
        path: '/transport',
        builder: (context, state) => const TransportScreen(),
      ),
    ],
  );
}
