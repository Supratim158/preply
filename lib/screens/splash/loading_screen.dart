import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:lottie/lottie.dart';

import '../entry_screen.dart';
import '../onboarding/onboarding_page_1.dart';

class LoadingScreen extends StatefulWidget {
  final String? token;

  const LoadingScreen({
    super.key,
    this.token,
  });

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _bgController;
  late final AnimationController _progressController;
  late final Animation<double> _progressAnimation;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    // Background ambient glow animation
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    // Fast, snappy loading bar (under 1 second: 850ms)
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );

    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOutCubic,
    );

    _progressController.addListener(() {
      setState(() {});
    });

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateToNext();
      }
    });

    _progressController.forward();
  }

  void _navigateToNext() {
    if (_navigated || !mounted) return;
    _navigated = true;

    final token = widget.token;
    final bool isLoggedIn =
        token != null && token.isNotEmpty && !JwtDecoder.isExpired(token);

    final Widget nextScreen =
        isLoggedIn ? EntryScreen(token: token) : const OnboardingPage1();

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, animation, secondaryAnimation) => nextScreen,
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.96, end: 1.0).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _bgController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final progress = _progressAnimation.value;
    final percent = (progress * 100).clamp(0, 100).toInt();

    return Scaffold(
      backgroundColor: const Color(0xFF070B18),
      body: Stack(
        children: [
          // Custom Animated Ambient Glow Background
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, _) {
              return CustomPaint(
                size: size,
                painter: _CosmicBackgroundPainter(
                  animationValue: _bgController.value,
                ),
              );
            },
          ),

          // Soft Blur Overlay for Glassmorphic depth
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: const SizedBox.expand(),
          ),

          // Main Center Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo Container with Glassmorphism & Neon Glow
                      Container(
                        width: 96,
                        height: 96,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.12),
                              Colors.white.withOpacity(0.03),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6366F1).withOpacity(0.45),
                              blurRadius: 32,
                              spreadRadius: 2,
                              offset: const Offset(0, 8),
                            ),
                            BoxShadow(
                              color: const Color(0xFF38BDF8).withOpacity(0.25),
                              blurRadius: 24,
                              spreadRadius: -4,
                              offset: const Offset(0, -4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.auto_awesome_rounded,
                              size: 46,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Brand Name with Gradient Shader
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            Colors.white,
                            Color(0xFFE0E7FF),
                            Color(0xFFA5B4FC),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ).createShader(bounds),
                        child: const Text(
                          'Preply',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 4),

                      // Subtitle
                      Text(
                        'Elevate Your Career',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.55),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2.2,
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Lottie Star Animation
                      SizedBox(
                        width: 140,
                        height: 140,
                        child: Lottie.asset(
                          'assets/animations/star.json',
                          fit: BoxFit.contain,
                          repeat: true,
                          animate: true,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.star_rounded,
                            size: 60,
                            color: Color(0xFFFFD166),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Progress Bar Container
                      Container(
                        width: 210,
                        height: 7,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.12),
                            width: 1,
                          ),
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: progress.clamp(0.0, 1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF4F46E5),
                                    Color(0xFF818CF8),
                                    Color(0xFF38BDF8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF6366F1)
                                        .withOpacity(0.8),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Percentage Indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$percent%',
                            style: const TextStyle(
                              color: Color(0xFF818CF8),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter generating an animated multi-orb cosmic background
class _CosmicBackgroundPainter extends CustomPainter {
  final double animationValue;

  _CosmicBackgroundPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    // Base deep cosmic gradient
    final bgRect = Offset.zero & size;
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF050814),
          Color(0xFF0A0F24),
          Color(0xFF04060E),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(bgRect);
    canvas.drawRect(bgRect, bgPaint);

    // Orb 1: Violet/Indigo top-left floating
    final orb1Center = Offset(
      size.width * (0.28 + 0.08 * math.sin(animationValue * 2 * math.pi)),
      size.height * (0.24 + 0.06 * math.cos(animationValue * 2 * math.pi)),
    );
    final orb1Paint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF6366F1).withOpacity(0.35 + 0.1 * animationValue),
          const Color(0xFF4338CA).withOpacity(0.18),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(
        Rect.fromCircle(center: orb1Center, radius: size.width * 0.55),
      );
    canvas.drawCircle(orb1Center, size.width * 0.55, orb1Paint);

    // Orb 2: Electric Cyan/Sky blue center-right
    final orb2Center = Offset(
      size.width * (0.76 - 0.09 * math.cos(animationValue * 2 * math.pi)),
      size.height * (0.62 + 0.07 * math.sin(animationValue * 2 * math.pi)),
    );
    final orb2Paint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF0EA5E9).withOpacity(0.32 + 0.08 * (1 - animationValue)),
          const Color(0xFF0284C7).withOpacity(0.14),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(
        Rect.fromCircle(center: orb2Center, radius: size.width * 0.58),
      );
    canvas.drawCircle(orb2Center, size.width * 0.58, orb2Paint);

    // Orb 3: Subtle Magenta pulse at bottom-center
    final orb3Center = Offset(
      size.width * (0.48 + 0.05 * math.sin(animationValue * 2 * math.pi)),
      size.height * (0.84 - 0.04 * math.cos(animationValue * 2 * math.pi)),
    );
    final orb3Paint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFD946EF).withOpacity(0.20 + 0.06 * animationValue),
          Colors.transparent,
        ],
        stops: const [0.0, 1.0],
      ).createShader(
        Rect.fromCircle(center: orb3Center, radius: size.width * 0.45),
      );
    canvas.drawCircle(orb3Center, size.width * 0.45, orb3Paint);
  }

  @override
  bool shouldRepaint(covariant _CosmicBackgroundPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
