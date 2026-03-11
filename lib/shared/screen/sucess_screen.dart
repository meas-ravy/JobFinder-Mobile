import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder/core/theme/app_color.dart';
import 'package:job_finder/core/constants/assets.dart';
import 'package:job_finder/shared/widget/svg_icon.dart';

class AuthSuccessScreen extends StatefulWidget {
  /// The route to navigate to after the success animation completes.
  final String nextRoute;

  /// Optional user name to personalise the message.
  final String? userName;

  const AuthSuccessScreen({super.key, required this.nextRoute, this.userName});

  @override
  State<AuthSuccessScreen> createState() => _AuthSuccessScreenState();
}

class _AuthSuccessScreenState extends State<AuthSuccessScreen>
    with TickerProviderStateMixin {
  late final AnimationController _checkController;
  late final AnimationController _glowController;
  late final AnimationController _contentController;

  late final Animation<double> _checkScale;
  late final Animation<double> _checkOpacity;
  late final Animation<double> _glowScale;
  late final Animation<double> _glowOpacity;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;

  Timer? _redirectTimer;

  @override
  void initState() {
    super.initState();

    // Controller for the checkmark pop-in
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Controller for the pulsing glow ring
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    // Controller for text/content slide-up
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _checkScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.elasticOut),
    );
    _checkOpacity = CurvedAnimation(
      parent: _checkController,
      curve: const Interval(0.0, 0.4),
    );

    _glowScale = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOutSine),
    );
    _glowOpacity = Tween<double>(begin: 0.35, end: 0.08).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOutSine),
    );

    _contentFade = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOut,
    );
    _contentSlide =
        Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _contentController,
            curve: Curves.easeOutCubic,
          ),
        );

    // Sequence the animations
    _runAnimations();
  }

  Future<void> _runAnimations() async {
    await Future.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;

    _checkController.forward();
    _glowController.repeat(reverse: true);

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    _contentController.forward();

    // Auto-redirect after 2.2 seconds total
    _redirectTimer = Timer(const Duration(milliseconds: 2200), () {
      if (mounted) {
        context.go(widget.nextRoute);
      }
    });
  }

  @override
  void dispose() {
    _redirectTimer?.cancel();
    _checkController.dispose();
    _glowController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final firstName = widget.userName?.split(' ').first;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Animated check icon with glow ──
                AnimatedBuilder(
                  animation: Listenable.merge([
                    _checkController,
                    _glowController,
                  ]),
                  builder: (context, _) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer glow ring
                        Transform.scale(
                          scale: _glowScale.value,
                          child: Opacity(
                            opacity: _glowOpacity.value,
                            child: Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColor.snackBarSuccess,
                              ),
                            ),
                          ),
                        ),
                        // Inner tinted circle
                        Container(
                          width: 124,
                          height: 124,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColor.snackBarSuccess.withValues(
                              alpha: 0.14,
                            ),
                            border: Border.all(
                              color: AppColor.snackBarSuccess.withValues(
                                alpha: 0.35,
                              ),
                              width: 1.5,
                            ),
                          ),
                        ),
                        // Check icon pop-in
                        Opacity(
                          opacity: _checkOpacity.value,
                          child: Transform.scale(
                            scale: _checkScale.value,
                            child: Container(
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColor.snackBarSuccess,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColor.snackBarSuccess.withValues(
                                      alpha: 0.45,
                                    ),
                                    blurRadius: 28,
                                    spreadRadius: 4,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 48,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 40),

                // ── Animated text content ──
                FadeTransition(
                  opacity: _contentFade,
                  child: SlideTransition(
                    position: _contentSlide,
                    child: Column(
                      children: [
                        // App logo + brand name
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AppSvgIcon(
                              assetName: AppIcon.appLogoTwo,
                              size: 22,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Jober',
                              style: textTheme.titleMedium?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Main title
                        Text(
                          firstName != null && firstName.isNotEmpty
                              ? 'Welcome, $firstName! 🎉'
                              : 'You\'re all set! 🎉',
                          textAlign: TextAlign.center,
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Subtitle
                        Text(
                          'Login successful.\nTaking you to your dashboard…',
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withValues(
                              alpha: 0.55,
                            ),
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 36),

                        // Progress indicator
                        SizedBox(
                          width: 120,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: LinearProgressIndicator(
                              backgroundColor: colorScheme.onSurface.withValues(
                                alpha: 0.08,
                              ),
                              color: AppColor.snackBarSuccess,
                              minHeight: 3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
