import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app.dart';
import 'providers/trip_provider.dart';
import 'providers/explore_provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/rental_provider.dart';
import 'providers/bookmark_provider.dart';
import 'providers/language_provider.dart';
import 'providers/home_scroll_provider.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Disable runtime fetching of fonts via HTTP
  GoogleFonts.config.allowRuntimeFetching = false;

  // Init notification service
  await NotificationService().init();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TripProvider()),
        ChangeNotifierProvider(create: (_) => ExploreProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => RentalProvider()),
        ChangeNotifierProvider(create: (_) => BookmarkProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => HomeScrollProvider()),
      ],
      child: const RouteeApp(),
    ),
  );
}
