import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class IncomingCallScreen extends StatefulWidget {
  final String channelName;
  final bool isVideoCall;
  final String remoteName;
  final String? remoteAvatar;

  const IncomingCallScreen({
    super.key,
    required this.channelName,
    required this.isVideoCall,
    required this.remoteName,
    this.remoteAvatar,
  });

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onAccept() {
    _animationController.stop();
    // Navigate to the actual call screen and replace this one
    context.pushReplacement(
      '/call?channelName=${widget.channelName}&isVideoCall=${widget.isVideoCall}&remoteName=${widget.remoteName}',
      extra: {'remoteAvatar': widget.remoteAvatar},
    );
  }

  void _onDecline() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                // Glowing Avatar
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withValues(
                              alpha: 0.2 * _animationController.value,
                            ),
                            spreadRadius: 20 * _animationController.value,
                            blurRadius: 40 * _animationController.value,
                          ),
                        ],
                      ),
                      child: child,
                    );
                  },
                  child: CircleAvatar(
                    radius: 70,
                    backgroundColor: Colors.white12,
                    backgroundImage: widget.remoteAvatar != null
                        ? NetworkImage(widget.remoteAvatar!)
                        : null,
                    child: widget.remoteAvatar == null
                        ? Text(
                            widget.remoteName.isNotEmpty
                                ? widget.remoteName[0]
                                : '?',
                            style: const TextStyle(
                              fontSize: 48,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 32),
                // Caller Name
                Text(
                  widget.remoteName,
                  style: GoogleFonts.outfit(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                // Call Type
                Text(
                  widget.isVideoCall
                      ? "Incoming Video Call..."
                      : "Incoming Voice Call...",
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    color: Colors.white54,
                  ),
                ),
                const Spacer(flex: 3),
              ],
            ),

            // Action Buttons
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Decline
                  Column(
                    children: [
                      GestureDetector(
                        onTap: _onDecline,
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.call_end,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Decline",
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),

                  // Accept
                  Column(
                    children: [
                      GestureDetector(
                        onTap: _onAccept,
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            widget.isVideoCall ? Icons.videocam : Icons.call,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Accept",
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
