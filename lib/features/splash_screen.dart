import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:job_finder/core/constants/assets.dart';
import 'package:job_finder/core/helper/secure_storage.dart';
import 'package:job_finder/core/routes/app_path.dart';
import 'package:job_finder/shared/widget/svg_icon.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final AnimationController _pulseController;
  late final AnimationController _lottieController;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoSlideUp;
  late final Animation<double> _textFade;
  late final Animation<double> _textScale;
  late final Animation<double> _textSlideX;
  late final Animation<double> _textTracking;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _lottieController = AnimationController(vsync: this);
    _logoFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOutQuint),
    );
    _logoScale = Tween<double>(begin: 0.94, end: 1.02).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutQuint),
      ),
    );
    _logoSlideUp = Tween<double>(begin: 14, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutQuint),
      ),
    );
    _textFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.25, 0.9, curve: Curves.easeOutQuint),
    );
    _textScale = Tween<double>(begin: 0.98, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.9, curve: Curves.easeOutQuint),
      ),
    );
    _textSlideX = Tween<double>(begin: -16, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.9, curve: Curves.easeOutQuint),
      ),
    );
    _textTracking = Tween<double>(begin: -0.8, end: -0.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.9, curve: Curves.easeOutQuint),
      ),
    );
    _pulse = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );
    _controller.forward().whenComplete(() {
      if (mounted) {
        _pulseController.repeat(reverse: true);
      }
    });

    // After animations complete, check auth state and navigate
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Wait for splash animations to show (minimum 2 seconds)
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Check stored token and role
    final storage = TokenStorageImpl(const FlutterSecureStorage());
    final token = await storage.read();
    final role = await storage.readRole();

    if (!mounted) return;

    // Route based on auth state
    if (token == null || token.isEmpty) {
      // No token → go to login
      context.go(AppPath.sendOtp);
    } else if (role == null || role.isEmpty) {
      // Has token but no role → go to role selection
      context.go(AppPath.selectRole);
    } else {
      // Has token + role → go to appropriate home
      if (role == 'Job_finder') {
        context.go(AppPath.jobSeekerHome);
      } else if (role == 'Recruiter') {
        context.go(AppPath.recruiterHome);
      } else {
        // Unknown role → go to role selection
        context.go(AppPath.selectRole);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    _lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: Listenable.merge([_controller, _pulseController]),
                  child: AppSvgIcon(
                    assetName: AppIcon.appLogoTwo,
                    size: 62,
                    color: colorScheme.primary,
                  ),
                  builder: (context, child) {
                    final pulseScale = _pulseController.isAnimating
                        ? _pulse.value
                        : 1.0;
                    return Opacity(
                      opacity: _logoFade.value,
                      child: Transform.translate(
                        offset: Offset(0, _logoSlideUp.value),
                        child: Transform.scale(
                          scale: _logoScale.value * pulseScale,
                          child: child,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _textFade.value,
                      child: Transform.translate(
                        offset: Offset(_textSlideX.value, 0),
                        child: Transform.scale(
                          scale: _textScale.value,
                          child: Text(
                            'Jober',
                            style: GoogleFonts.poppins(
                              fontSize: 42,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                              letterSpacing: _textTracking.value,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: SizedBox(
                height: 100,
                width: 100,
                child: Lottie.asset(
                  'assets/image/loading.json',
                  controller: _lottieController,
                  onLoaded: (composition) {
                    _lottieController.duration = composition.duration;
                    Future.delayed(const Duration(milliseconds: 200), () {
                      if (mounted) {
                        _lottieController.repeat();
                      }
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
