import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onFinished;
  const SplashScreen({super.key, required this.onFinished});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _rippleController;
  late AnimationController _routeController;
  late AnimationController _fadeOutController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textSlide;
  late Animation<double> _textOpacity;
  late Animation<double> _taglineOpacity;
  late Animation<double> _dotsOpacity;
  late Animation<double> _fadeOut;
  late Animation<double> _rippleScale;
  late Animation<double> _rippleOpacity;
  late Animation<double> _routeProgress;

  @override
  void initState() {
    super.initState();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: const Interval(0.0, 0.4, curve: Curves.easeIn)),
    );

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _rippleScale = Tween<double>(begin: 0.5, end: 2.5).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );
    _rippleOpacity = Tween<double>(begin: 0.4, end: 0.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _textSlide = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: const Interval(0.0, 0.7, curve: Curves.easeIn)),
    );
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: const Interval(0.3, 1.0, curve: Curves.easeIn)),
    );
    _dotsOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: const Interval(0.5, 1.0, curve: Curves.easeIn)),
    );

    _routeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _routeProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _routeController, curve: Curves.easeInOutQuad),
    );

    _fadeOutController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeOutController, curve: Curves.easeInCubic),
    );

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    _rippleController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    _textController.forward();
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    _routeController.forward();
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;
    _fadeOutController.forward();
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) widget.onFinished();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _logoController.dispose();
    _textController.dispose();
    _rippleController.dispose();
    _routeController.dispose();
    _fadeOutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeOutController,
      builder: (context, child) => Opacity(
        opacity: _fadeOut.value,
        child: child,
      ),
      child: Scaffold(
        body: AnimatedBuilder(
          animation: _bgController,
          builder: (context, _) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: const [
                    Color(0xFF3B2314),
                    Color(0xFF5A3A1E),
                    Color(0xFF6D4C2A),
                    Color(0xFF4A3219),
                  ],
                  stops: [
                    0.0,
                    0.3 + 0.1 * sin(_bgController.value * 2 * pi),
                    0.6 + 0.1 * cos(_bgController.value * 2 * pi),
                    1.0,
                  ],
                ),
              ),
              child: Stack(
                children: [
                  ..._buildParticles(),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo area with ripple
                        SizedBox(
                          width: 180,
                          height: 180,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Ripple
                              AnimatedBuilder(
                                animation: _rippleController,
                                builder: (context, _) => Transform.scale(
                                  scale: _rippleScale.value,
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.accent.withOpacity(_rippleOpacity.value),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Logo
                              AnimatedBuilder(
                                animation: _logoController,
                                builder: (context, child) => Opacity(
                                  opacity: _logoOpacity.value,
                                  child: Transform.scale(
                                    scale: _logoScale.value,
                                    child: child,
                                  ),
                                ),
                                child: SizedBox(
                                  width: 120,
                                  height: 120,
                                  child: Image.asset(
                                    'assets/images/logo v2.png',
                                    fit: BoxFit.contain,
                                    filterQuality: FilterQuality.high,
                                    errorBuilder: (c, e, s) => Container(
                                      decoration: const BoxDecoration(
                                        color: AppColors.primaryDark,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          'R',
                                          style: GoogleFonts.poppins(
                                            color: AppColors.accent,
                                            fontSize: 56,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Text
                        AnimatedBuilder(
                          animation: _textController,
                          builder: (context, _) => Transform.translate(
                            offset: Offset(0, _textSlide.value),
                            child: Column(
                              children: [
                                Opacity(
                                  opacity: _textOpacity.value,
                                  child: Text(
                                    'ROUTEE',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 36,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 8,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Opacity(
                                  opacity: _taglineOpacity.value,
                                  child: Text(
                                    'Surabaya Heritage Trip Planner',
                                    style: GoogleFonts.poppins(
                                      color: AppColors.accent.withOpacity(0.9),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Opacity(
                                  opacity: _taglineOpacity.value,
                                  child: Text(
                                    'One Day, One Ride, Full Experience',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white.withOpacity(0.6),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w400,
                                      fontStyle: FontStyle.italic,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 32),
                                // Unique route drawing animation
                                AnimatedBuilder(
                                  animation: _routeController,
                                  builder: (context, _) => Opacity(
                                    opacity: _routeController.value,
                                    child: SizedBox(
                                      width: 280,
                                      height: 60,
                                      child: CustomPaint(
                                        painter: RoutePainter(progress: _routeProgress.value),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Opacity(
                                  opacity: _dotsOpacity.value,
                                  child: const _LoadingDots(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildParticles() {
    final random = Random(42);
    return List.generate(12, (i) {
      final left = random.nextDouble() * 400;
      final top = random.nextDouble() * 800;
      final size = 3.0 + random.nextDouble() * 5;
      final delay = random.nextDouble();

      return AnimatedBuilder(
        animation: _bgController,
        builder: (context, _) {
          final progress = (_bgController.value + delay) % 1.0;
          final opacity = sin(progress * pi) * 0.3;
          final yOffset = sin(progress * 2 * pi) * 15;

          return Positioned(
            left: left,
            top: top + yOffset,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withOpacity(opacity.clamp(0.0, 1.0)),
              ),
            ),
          );
        },
      );
    });
  }
}

class RoutePainter extends CustomPainter {
  final double progress;
  RoutePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accent.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final activePaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(20, size.height / 2);
    path.cubicTo(
      size.width * 0.3, size.height * 0.15,
      size.width * 0.6, size.height * 0.85,
      size.width - 20, size.height / 2,
    );

    // Draw background path
    canvas.drawPath(path, paint);

    // Draw active path based on progress
    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      final extractPath = metric.extractPath(0.0, metric.length * progress);
      canvas.drawPath(extractPath, activePaint);
      
      // Draw a small indicator at the current progress point
      if (progress > 0 && progress < 1.0) {
        final tangent = metric.getTangentForOffset(metric.length * progress);
        if (tangent != null) {
          final dotPaint = Paint()
            ..color = Colors.white
            ..style = PaintingStyle.fill;
          final glowPaint = Paint()
            ..color = AppColors.accent.withOpacity(0.5)
            ..style = PaintingStyle.fill;
          canvas.drawCircle(tangent.position, 8, glowPaint);
          canvas.drawCircle(tangent.position, 4, dotPaint);
        }
      }
    }

    // Draw the 3 stop points
    final labels = ['🚂 Start', '🏛 Heritage', '🍜 Kuliner'];
    
    for (final metric in pathMetrics) {
      final p0 = metric.getTangentForOffset(0.0)!.position;
      final p1 = metric.getTangentForOffset(metric.length * 0.5)!.position;
      final p2 = metric.getTangentForOffset(metric.length)!.position;
      
      final actualPoints = [p0, p1, p2];
      
      for (int i = 0; i < 3; i++) {
        final pt = actualPoints[i];
        final pointProgress = i * 0.5;
        final isReached = progress >= pointProgress;
        
        final circlePaint = Paint()
          ..color = isReached ? AppColors.accent : AppColors.primaryLight.withOpacity(0.3)
          ..style = PaintingStyle.fill;
          
        canvas.drawCircle(pt, 5, circlePaint);
        if (isReached) {
          canvas.drawCircle(
            pt,
            9,
            Paint()
              ..color = AppColors.accent.withOpacity(0.25)
              ..style = PaintingStyle.fill,
          );
        }
        
        // Draw text label below/above
        final textPainter = TextPainter(
          text: TextSpan(
            text: labels[i],
            style: GoogleFonts.poppins(
              color: isReached ? Colors.white : Colors.white54,
              fontSize: 9,
              fontWeight: isReached ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(pt.dx - textPainter.width / 2, pt.dy + 12));
      }
    }
  }

  @override
  bool shouldRepaint(covariant RoutePainter oldDelegate) => oldDelegate.progress != progress;
}

class _LoadingDots extends StatefulWidget {
  const _LoadingDots();

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final offset = i * 0.2;
          final progress = (_controller.value + 1 - offset) % 1.0;
          final scale = 0.5 + 0.5 * sin(progress * pi);
          final opacity = 0.3 + 0.7 * sin(progress * pi);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Transform.scale(
              scale: scale,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent.withOpacity(opacity.clamp(0.0, 1.0)),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
