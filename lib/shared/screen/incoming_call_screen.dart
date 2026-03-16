import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:job_finder/core/services/agora_service.dart';
import 'package:job_finder/shared/screen/agora_call_screen.dart';

class IncomingCallScreen extends StatefulWidget {
  final CallInvitation invitation;

  const IncomingCallScreen({super.key, required this.invitation});

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen>
    with SingleTickerProviderStateMixin {
  static const int _timeoutSeconds = 30;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late Timer _autoRejectTimer;

  int _secondsLeft = _timeoutSeconds;
  StreamSubscription? _callStateSub;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    _startTimer();
    _listenToCallState();
  }

  void _listenToCallState() {
    _callStateSub = AgoraService.instance.callStateStream.listen((state) {
      if (state == CallState.ended ||
          state == CallState.rejected ||
          state == CallState.missed) {
        if (mounted) Navigator.pop(context);
      }
    });
  }

  void _setupAnimation() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeOut,
    );
  }

  void _startTimer() {
    _autoRejectTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      setState(() {
        _secondsLeft--;
      });

      if (_secondsLeft <= 0) {
        timer.cancel();
        _decline();
      }
    });
  }

  Future<void> _accept() async {
    debugPrint('📞 [IncomingCall] Accept button clicked');
    _autoRejectTimer.cancel();

    try {
      // Step 1: Tell Firebase we are joining (non-blocking if possible)
      // We don't await this forever to prevent UI hang
      debugPrint('📞 [IncomingCall] Updating call state to ongoing...');
      AgoraService.instance
          .acceptCall(widget.invitation.conversationId)
          .timeout(const Duration(seconds: 3))
          .catchError((e) {
            debugPrint('⚠️ [IncomingCall] Firebase signaling warning: $e');
            return null;
          });

      if (!mounted) return;

      // Step 2: Navigate immediately to the call screen
      debugPrint('🚀 [IncomingCall] Pushing AgoraCallScreen');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => AgoraCallScreen(
            conversationId: widget.invitation.conversationId,
            callerName: widget.invitation.callerName,
            callerAvatar: widget.invitation.callerAvatar,
            calleeId: widget.invitation.callerId,
            calleeName: widget.invitation.callerName,
            isVideoCall: widget.invitation.isVideoCall,
            isIncoming: true,
          ),
        ),
      );
    } catch (e) {
      debugPrint('❌ [IncomingCall] Error during accept: $e');
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _decline() async {
    debugPrint('📱 [IncomingCall] Decline button clicked');
    _autoRejectTimer.cancel();

    try {
      await AgoraService.instance
          .rejectCall(widget.invitation.conversationId)
          .timeout(const Duration(seconds: 2));
    } catch (e) {
      debugPrint('⚠️ [IncomingCall] Reject error (swallowed): $e');
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _autoRejectTimer.cancel();
    _callStateSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inv = widget.invitation;
    final isVideo = inv.isVideoCall;

    return Scaffold(
      body: Stack(
        children: [
          /// Background Avatar (Blurred)
          Positioned.fill(
            child: inv.callerAvatar != null && inv.callerAvatar!.isNotEmpty
                ? Image.network(inv.callerAvatar!, fit: BoxFit.cover)
                : Container(color: const Color(0xFF0F2027)),
          ),

          /// Blur + Animated Gradient Overlay
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.8),
                      Colors.black.withValues(alpha: 0.4),
                      Colors.black.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),

          /// Pulse rings
          IgnorePointer(
            child: Center(child: _PulseRings(animation: _pulseAnimation)),
          ),

          Positioned.fill(
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  /// Incoming badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.white.withValues(alpha: 0.1),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _AnimatedBlinkingDot(),
                        const SizedBox(width: 10),
                        Text(
                          isVideo
                              ? "INCOMING VIDEO CALL"
                              : "INCOMING VOICE CALL",
                          style: GoogleFonts.inter(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  /// Avatar + Countdown
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CountdownRing(
                        secondsLeft: _secondsLeft,
                        total: _timeoutSeconds,
                      ),
                      _AvatarSection(inv: inv),
                    ],
                  ),

                  const SizedBox(height: 30),

                  /// Caller name
                  Text(
                    inv.callerName,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// ringing text
                  Text(
                    "Job Finder Professional Call",
                    style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const Spacer(),

                  /// Action buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 60,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _CallButton(
                          icon: Icons.close_rounded,
                          color: Colors.redAccent,
                          label: "Decline",
                          onTap: _decline,
                        ),
                        _CallButton(
                          icon: isVideo
                              ? Icons.videocam_rounded
                              : Icons.call_rounded,
                          color: const Color(0xFF00FFB2),
                          label: "Accept",
                          onTap: _accept,
                          isPrimary: true,
                          iconColor: Colors.black87,
                        ),
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

class _AnimatedBlinkingDot extends StatefulWidget {
  @override
  _AnimatedBlinkingDotState createState() => _AnimatedBlinkingDotState();
}

class _AnimatedBlinkingDotState extends State<_AnimatedBlinkingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Colors.redAccent,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.redAccent, blurRadius: 4, spreadRadius: 1),
          ],
        ),
      ),
    );
  }
}

class CountdownRing extends StatelessWidget {
  final int secondsLeft;
  final int total;

  const CountdownRing({
    super.key,
    required this.secondsLeft,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final progress = secondsLeft / total;

    return SizedBox(
      width: 150, // More compact
      height: 150,
      child: CircularProgressIndicator(
        value: progress,
        strokeWidth: 2.5, // Thinner, more elegant
        backgroundColor: Colors.white.withOpacity(0.05),
        valueColor: const AlwaysStoppedAnimation(
          Color(0xFF00FFB2),
        ), // Neon Cyan-Green
      ),
    );
  }
}

class _AvatarSection extends StatelessWidget {
  final CallInvitation inv;

  const _AvatarSection({required this.inv});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140, // Perfectly balanced with the 150px ring
      height: 140,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00FFB2).withOpacity(0.15),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white10,
        ),
        clipBehavior: Clip.antiAlias,
        child: inv.callerAvatar != null && inv.callerAvatar!.isNotEmpty
            ? Image.network(
                inv.callerAvatar!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white24,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => _buildFallback(),
              )
            : _buildFallback(),
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2C5364), Color(0xFF0F2027)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          inv.callerName.isNotEmpty ? inv.callerName[0].toUpperCase() : '?',
          style: GoogleFonts.outfit(
            fontSize: 50,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _PulseRings extends StatelessWidget {
  final Animation<double> animation;

  const _PulseRings({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) {
        return Stack(
          alignment: Alignment.center,
          children: List.generate(3, (i) {
            final delay = i * 0.3;
            double progress = animation.value - delay;

            if (progress < 0) progress += 1;

            return Opacity(
              opacity: (1 - progress).clamp(0, 1) * 0.3,
              child: Container(
                width: 120 + progress * 250,
                height: 120 + progress * 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _CallButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;
  final Color iconColor;

  const _CallButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    final size = isPrimary ? 80.0 : 70.0;

    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 25,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 2,
              ),
            ),
            child: Icon(icon, color: iconColor, size: isPrimary ? 32 : 28),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
