import 'dart:async';
import 'package:flutter/material.dart';
import 'package:job_finder/core/services/agora_service.dart';

class AgoraCallScreen extends StatefulWidget {
  final String conversationId;
  final String remoteUserName;
  final String? remoteUserAvatar;
  final bool isVideoCall;
  final bool isCaller;

  const AgoraCallScreen({
    super.key,
    required this.conversationId,
    required this.remoteUserName,
    required this.isVideoCall,
    required this.isCaller,
    this.remoteUserAvatar,
  });

  @override
  State<AgoraCallScreen> createState() => _AgoraCallScreenState();
}

class _AgoraCallScreenState extends State<AgoraCallScreen>
    with TickerProviderStateMixin {
  final _agora = AgoraService.instance;

  bool _isMuted = false;
  bool _isCameraOff = false;
  bool _isSpeakerOn = true;
  bool _isJoining = true;
  int? _remoteUid;
  CallState _callState = CallState.ringing;

  StreamSubscription? _remoteJoinedSub;
  StreamSubscription? _remoteLeftSub;
  StreamSubscription? _callStateSub;

  Duration _callDuration = Duration.zero;
  Timer? _callTimer;

  // Pulsing avatar ring animation
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse animation for the avatar ring (only during ringing)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _setupListeners();
    _joinCall();
  }

  void _setupListeners() {
    _remoteJoinedSub = _agora.remoteUserJoinedStream.listen((uid) {
      setState(() => _remoteUid = uid);
    });

    _remoteLeftSub = _agora.remoteUserLeftStream.listen((_) {
      setState(() => _remoteUid = null);
      _endCall();
    });

    _callStateSub = _agora.callStateStream.listen((state) {
      setState(() => _callState = state);
      if (state == CallState.ongoing) {
        setState(() => _isJoining = false);
        _pulseController.stop(); // stop pulsing once connected
        _startCallTimer();
      } else if (state == CallState.ended || state == CallState.rejected) {
        _callTimer?.cancel();
        if (mounted) Navigator.of(context).pop();
      }
    });
  }

  Future<void> _joinCall() async {
    try {
      await _agora.joinCall(
        conversationId: widget.conversationId,
        isVideoCall: widget.isVideoCall,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isJoining = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Call failed: ${e.toString().replaceAll('Exception: ', '')}',
          ),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 3),
        ),
      );
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) Navigator.of(context).pop();
    }
  }

  void _startCallTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _callDuration = _callDuration + const Duration(seconds: 1);
        });
      }
    });
  }

  String get _durationText {
    final m = _callDuration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = _callDuration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _endCall() async {
    _callTimer?.cancel();
    await _agora.endCall(widget.conversationId);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _remoteJoinedSub?.cancel();
    _remoteLeftSub?.cancel();
    _callStateSub?.cancel();
    _callTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Background ─────────────────────────────────────────────
          if (widget.isVideoCall)
            _buildVideoBackground()
          else
            _buildVoiceBackground(),

          // ── Gradient Overlay ───────────────────────────────────────
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(widget.isVideoCall ? 0.55 : 0.3),
                    Colors.transparent,
                    Colors.black.withOpacity(0.85),
                  ],
                ),
              ),
            ),
          ),

          // ── VOICE CALL: Large Centered Avatar ──────────────────────
          if (!widget.isVideoCall) Center(child: _buildCenteredAvatar()),

          // ── VIDEO CALL: Small Top Info Bar ─────────────────────────
          if (widget.isVideoCall) _buildVideoTopBar(),

          // ── VOICE CALL: Name + Status (below center) ──────────────
          if (!widget.isVideoCall) _buildVoiceCallInfo(),

          // ── VIDEO: Local PIP ───────────────────────────────────────
          if (widget.isVideoCall && _remoteUid != null)
            Positioned(
              top: 100,
              right: 16,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 100,
                  height: 140,
                  child: _agora.getLocalView(),
                ),
              ),
            ),

          // ── Bottom: Call Controls ─────────────────────────────────
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Mute Button
                      _ControlButton(
                        icon: _isMuted ? Icons.mic_off : Icons.mic,
                        label: _isMuted ? 'Unmute' : 'Mute',
                        onTap: () async {
                          setState(() => _isMuted = !_isMuted);
                          await _agora.toggleMute(_isMuted);
                        },
                      ),
                      // Camera Button (only for Video calls)
                      if (widget.isVideoCall)
                        _ControlButton(
                          icon: _isCameraOff
                              ? Icons.videocam_off
                              : Icons.videocam,
                          label: _isCameraOff ? 'Camera On' : 'Camera Off',
                          onTap: () async {
                            setState(() => _isCameraOff = !_isCameraOff);
                            await _agora.toggleCamera(_isCameraOff);
                          },
                        ),
                      // Speaker Button
                      _ControlButton(
                        icon: _isSpeakerOn ? Icons.volume_up : Icons.earbuds,
                        label: _isSpeakerOn ? 'Speaker' : 'Earpiece',
                        onTap: () async {
                          setState(() => _isSpeakerOn = !_isSpeakerOn);
                          await _agora.setSpeakerOn(_isSpeakerOn);
                        },
                      ),
                      // Flip Camera (only for Video)
                      if (widget.isVideoCall)
                        _ControlButton(
                          icon: Icons.flip_camera_ios,
                          label: 'Flip',
                          onTap: () => _agora.switchCamera(),
                        ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // End Call Button
                  GestureDetector(
                    onTap: _endCall,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.call_end,
                        color: Colors.white,
                        size: 32,
                      ),
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

  // ── Large pulsing avatar (Voice Call) ─────────────────────────────────
  Widget _buildCenteredAvatar() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final isRinging = _callState == CallState.ringing || _isJoining;
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer pulse ring (only when ringing)
            if (isRinging)
              Transform.scale(
                scale: _pulseAnimation.value * 1.35,
                child: CircleAvatar(
                  radius: 70,
                  backgroundColor: Colors.white.withOpacity(0.08),
                ),
              ),
            // Middle pulse ring
            if (isRinging)
              Transform.scale(
                scale: _pulseAnimation.value * 1.15,
                child: CircleAvatar(
                  radius: 70,
                  backgroundColor: Colors.white.withOpacity(0.12),
                ),
              ),
            // Main avatar
            CircleAvatar(
              radius: 70,
              backgroundImage: widget.remoteUserAvatar != null
                  ? NetworkImage(widget.remoteUserAvatar!)
                  : null,
              backgroundColor: const Color(0xFF2A3A5C),
              child: widget.remoteUserAvatar == null
                  ? Text(
                      widget.remoteUserName.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 52,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          ],
        );
      },
    );
  }

  // ── Name + Status for Voice Call ──────────────────────────────────────
  Widget _buildVoiceCallInfo() {
    return Positioned(
      bottom: 200,
      left: 0,
      right: 0,
      child: Column(
        children: [
          Text(
            widget.remoteUserName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 10),
          if (_isJoining)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    color: Colors.white54,
                    strokeWidth: 2,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Connecting...',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            )
          else
            Text(
              _callState == CallState.ongoing
                  ? _durationText
                  : _callState == CallState.ringing
                  ? (widget.isCaller ? 'Ringing...' : 'Incoming call...')
                  : 'Connecting...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.65),
                fontSize: 15,
                letterSpacing: 0.5,
              ),
            ),
        ],
      ),
    );
  }

  // ── Small top bar for Video Call ──────────────────────────────────────
  Widget _buildVideoTopBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundImage: widget.remoteUserAvatar != null
                  ? NetworkImage(widget.remoteUserAvatar!)
                  : null,
              backgroundColor: Colors.grey.shade800,
              child: widget.remoteUserAvatar == null
                  ? Text(
                      widget.remoteUserName.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.remoteUserName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (_isJoining)
                  const Text(
                    'Connecting...',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  )
                else
                  Text(
                    _callState == CallState.ongoing
                        ? _durationText
                        : 'Ringing...',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoBackground() {
    if (_remoteUid != null) {
      // Remote user has joined — show their video feed
      return _agora.getRemoteView(_remoteUid!, widget.conversationId);
    }
    // Waiting for remote user — show blurred avatar placeholder (no spinner)
    return Container(
      color: const Color(0xFF0D1117),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 56,
              backgroundImage: widget.remoteUserAvatar != null
                  ? NetworkImage(widget.remoteUserAvatar!)
                  : null,
              backgroundColor: Colors.grey.shade800,
              child: widget.remoteUserAvatar == null
                  ? Text(
                      widget.remoteUserName.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              'Waiting for ${widget.remoteUserName}...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade900, Colors.indigo.shade900],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Incoming Call Overlay Dialog
// ─────────────────────────────────────────────────────────────

class IncomingCallDialog extends StatelessWidget {
  final CallInvitation invitation;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const IncomingCallDialog({
    super.key,
    required this.invitation,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey.shade700,
              backgroundImage: invitation.callerAvatar.isNotEmpty
                  ? NetworkImage(invitation.callerAvatar)
                  : null,
              child: invitation.callerAvatar.isEmpty
                  ? Text(
                      invitation.callerName.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              invitation.callerName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              invitation.isVideoCall
                  ? 'Incoming Video Call...'
                  : 'Incoming Voice Call...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Reject Button
                GestureDetector(
                  onTap: onReject,
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.call_end,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Decline',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                // Accept Button
                GestureDetector(
                  onTap: onAccept,
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          invitation.isVideoCall ? Icons.videocam : Icons.call,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Accept',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Reusable Call Control Button
// ─────────────────────────────────────────────────────────────
class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
