import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder/core/helper/secure_storage.dart';
import 'package:job_finder/core/routes/app_path.dart';

class OnboardingScreen extends HookWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          //Background Animated Blobs
          const _AnimatedBlob(
            color: Color(0xFF1E3A8A),
            top: -100,
            left: -100,
            size: 400,
          ),
          const _AnimatedBlob(
            color: Color(0xFF064E3B), // Deep Emerald
            bottom: -50,
            right: -50,
            size: 350,
          ),
          // Main Content
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(
                alpha: 0.6,
              ), // Dynamic overlay based on theme
            ),
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        return Stack(
                          children: [
                            Positioned(
                              top: 40,
                              left: width * 0.15,
                              child: const _FloatingBubble(
                                text: 'Job Finder App',
                                borderColor: Color(0xFF10B981),
                                duration: Duration(milliseconds: 2500),
                                offset: 12,
                                delay: Duration(milliseconds: 0),
                              ),
                            ),
                            Positioned(
                              top: 150,
                              right: width * 0.1,
                              child: const _FloatingBubble(
                                text: 'Job Tach',
                                borderColor: Color(0xFF3B82F6),
                                duration: Duration(milliseconds: 3000),
                                offset: -10,
                                delay: Duration(milliseconds: 200),
                              ),
                            ),
                            Positioned(
                              top: 220,
                              left: width * 0.1,
                              child: const _FloatingBubble(
                                text: 'HR & Recruitment App',
                                borderColor: Color(0xFFEF4444),
                                duration: Duration(milliseconds: 2800),
                                offset: 15,
                                delay: Duration(milliseconds: 400),
                              ),
                            ),
                            Positioned(
                              top: 340,
                              left: width * 0.05,
                              child: const _FloatingBubble(
                                text: 'Job Provider App',
                                borderColor: Color(0xFF10B981),
                                duration: Duration(milliseconds: 3200),
                                offset: -8,
                                delay: Duration(milliseconds: 600),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      children: [
                        Text(
                          'Application for easy\njob search and Job\nprovider',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: () async {
                              final storage = TokenStorageImpl(
                                const FlutterSecureStorage(),
                              );
                              await storage.writeHasSeenOnboarding();
                              if (context.mounted) {
                                context.go(AppPath.sendOtp);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Get Started',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedBlob extends HookWidget {
  final Color color;
  final double size;
  final double? top;
  final double? left;
  final double? right;
  final double? bottom;

  const _AnimatedBlob({
    required this.color,
    required this.size,
    this.top,
    this.left,
    this.right,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: const Duration(seconds: 10),
    );

    useEffect(() {
      controller.repeat(reverse: true);
      return null;
    }, [controller]);

    final animation = useAnimation(
      Tween<double>(
        begin: 0,
        end: 1,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut)),
    );

    return Positioned(
      top: top != null ? top! + (animation * 40) : null,
      left: left != null ? left! + (animation * 30) : null,
      right: right != null ? right! - (animation * 30) : null,
      bottom: bottom != null ? bottom! - (animation * 40) : null,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 100,
              spreadRadius: 50,
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingBubble extends HookWidget {
  final String text;
  final Color borderColor;
  final Duration duration;
  final double offset;
  final Duration delay;

  const _FloatingBubble({
    required this.text,
    required this.borderColor,
    required this.duration,
    required this.offset,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    // Floating Animation
    final floatController = useAnimationController(duration: duration);

    // Scaling (Breathing) Animation
    final scaleController = useAnimationController(
      duration: Duration(milliseconds: (duration.inMilliseconds * 0.8).toInt()),
    );

    // Entrance Animation (Pop in)
    final entranceController = useAnimationController(
      duration: const Duration(milliseconds: 800),
    );

    useEffect(() {
      floatController.repeat(reverse: true);
      scaleController.repeat(reverse: true);

      Future.delayed(delay, () {
        if (context.mounted) entranceController.forward();
      });
      return null;
    }, [floatController, scaleController]);

    final floatAnimation = useAnimation(
      Tween<double>(begin: 0, end: offset).animate(
        CurvedAnimation(parent: floatController, curve: Curves.easeInOutSine),
      ),
    );

    final scaleAnimation = useAnimation(
      Tween<double>(begin: 1.0, end: 1.05).animate(
        CurvedAnimation(parent: scaleController, curve: Curves.easeInOutSine),
      ),
    );

    final entranceScale = useAnimation(
      Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: entranceController, curve: Curves.elasticOut),
      ),
    );

    return Opacity(
      opacity: entranceController.value.clamp(0.0, 1.0),
      child: Transform.translate(
        offset: Offset(0, floatAnimation),
        child: Transform.scale(
          scale: entranceScale * scaleAnimation,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(100),
              boxShadow: [
                BoxShadow(
                  color: borderColor.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
              border: Border.all(
                color: borderColor.withValues(alpha: 0.8),
                width: 1.5,
              ),
            ),
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: borderColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
