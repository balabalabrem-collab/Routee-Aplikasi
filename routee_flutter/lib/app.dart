import 'package:flutter/material.dart';
import 'core/constants/app_theme.dart';
import 'router/app_router.dart';

class RouteeApp extends StatelessWidget {
  const RouteeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Routee — Surabaya Heritage Trip',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
    );
  }
}
