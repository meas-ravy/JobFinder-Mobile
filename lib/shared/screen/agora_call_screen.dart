import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:job_finder/core/services/agora_service.dart';
import 'package:permission_handler/permission_handler.dart';

class AgoraCallScreen extends StatefulWidget {
  final String conversationId;
  final String callerName;
  final String? callerAvatar;
  final String calleeId;
  final String calleeName;
  final String? calleeAvatar; // New: callee's photo
  final bool isVideoCall;
  final bool isIncoming; // true = receiver, false = caller

  const AgoraCallScreen({
    super.key,
    required this.conversationId,
    required this.callerName,
    required this.callerAvatar,
    required this.calleeId,
    required this.calleeName,
    this.calleeAvatar,
    required this.isVideoCall,
    this.isIncoming = false,
  });

  @override
  State<AgoraCallScreen> createState() => _AgoraCallScreenState();
}

class _AgoraCallScreenState extends State<AgoraCallScreen> {
  final _agoraService = AgoraService.instance;

  bool _isMuted = false;
  bool _isCameraOff = false;
  bool _isSpeakerOn = true;
  bool _isConnected = false; // true when remote user joins
  bool _isJoining = false; // true only during the initial engine connection
  bool _isClosing = false; // Guard against double-popping

  StreamSubscription<int>? _remoteJoinedSub;
  StreamSubscription<int>? _remoteLeftSub;
  StreamSubscription<CallState>? _callStateSub;

  // Stable video controllers — must be created ONCE and reused across builds
  VideoViewController? _localController;
  VideoViewController? _remoteController;

  Duration _elapsed = Duration.zero;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _agoraService.watchCallStatus(widget.conversationId);
    _listenToEvents();
    _startCall();
  }

  void _listenToEvents() {
    _remoteJoinedSub = _agoraService.remoteUserJoinedStream.listen((uid) {
      if (mounted) {
        final engine = _agoraService.engine;
        setState(() {
          _isConnected = true;
          _isJoining = false;
          // Create remote controller exactly once when the remote user joins
          if (widget.isVideoCall && engine != null) {
            _remoteController = VideoViewController.remote(
              rtcEngine: engine,
              canvas: VideoCanvas(uid: uid),
              connection: RtcConnection(channelId: widget.conversationId),
            );
          }
        });
        _startTimer();
      }
    });

    _remoteLeftSub = _agoraService.remoteUserLeftStream.listen((_) {
      if (mounted) _endCall();
    });

    _callStateSub = _agoraService.callStateStream.listen((state) {
      if ((state == CallState.ended ||
              state == CallState.rejected ||
              state == CallState.missed) &&
          mounted) {
        debugPrint('📡 [AgoraCall] Call state changed to $state, closing...');
        _safePop();
      }
    });
  }

  Future<void> _startCall() async {
    if (!mounted) return;
    setState(() => _isJoining = true);
    try {
      // Request permissions FIRST — required on Android 6+ even with Manifest entries
      if (widget.isVideoCall) {
        final statuses = await [
          Permission.camera,
          Permission.microphone,
        ].request();
        if (statuses[Permission.camera] != PermissionStatus.granted ||
            statuses[Permission.microphone] != PermissionStatus.granted) {
          if (mounted) {
            setState(() => _isJoining = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Camera & microphone permission required'),
              ),
            );
            Navigator.of(context).pop();
          }
          return;
        }
      } else {
        await Permission.microphone.request();
      }

      await _agoraService.joinCall(
        conversationId: widget.conversationId,
        isVideoCall: widget.isVideoCall,
      );
      await _agoraService.setSpeakerOn(_isSpeakerOn);

      // Create local video controller once after successfully joining
      final engine = _agoraService.engine;
      if (widget.isVideoCall && engine != null && mounted) {
        setState(() {
          _localController = VideoViewController(
            rtcEngine: engine,
            canvas: const VideoCanvas(uid: 0),
          );
        });
      }

      if (mounted) setState(() => _isJoining = false);
    } catch (e) {
      if (mounted) {
        setState(() => _isJoining = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to join call: $e')));
        Navigator.of(context).pop();
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsed += const Duration(seconds: 1));
    });
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _safePop() {
    if (_isClosing || !mounted) return;
    _isClosing = true;
    _timer?.cancel();

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      // If we can't pop (e.g. root page from notification),
      // we might want to go to a default home page instead.
      debugPrint('⚠️ [AgoraCall] Cannot pop, redirecting to home...');
      // You can use context.go('/') if using GoRouter
    }
  }

  Future<void> _endCall() async {
    if (_isClosing) return;
    debugPrint('📞 [AgoraCall] End call button pressed');

    try {
      await _agoraService.endCall(widget.conversationId);
    } catch (e) {
      debugPrint('⚠️ [AgoraCall] End call error: $e');
    } finally {
      _safePop();
    }
  }

  Future<void> _toggleMute() async {
    setState(() => _isMuted = !_isMuted);
    await _agoraService.toggleMute(_isMuted);
  }

  Future<void> _toggleCamera() async {
    setState(() => _isCameraOff = !_isCameraOff);
    await _agoraService.toggleCamera(_isCameraOff);
  }

  Future<void> _toggleSpeaker() async {
    setState(() => _isSpeakerOn = !_isSpeakerOn);
    await _agoraService.setSpeakerOn(_isSpeakerOn);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _remoteJoinedSub?.cancel();
    _remoteLeftSub?.cancel();
    _callStateSub?.cancel();
    _localController?.dispose();
    _remoteController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Stack(
        children: [
          _buildBackground(),
          _buildCallerInfo(),

          // Local camera PiP — placed above callerInfo so it's fully visible
          if (widget.isVideoCall && !_isCameraOff && _localController != null)
            Positioned(
              top: 80,
              right: 16,
              width: 110,
              height: 160,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: AgoraVideoView(controller: _localController!),
              ),
            ),

          _buildControls(),

          if (_isJoining)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white70,
                            strokeWidth: 2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Connecting to call...',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
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

  Widget _buildBackground() {
    if (widget.isVideoCall) {
      // Show remote video full-screen when connected, gradient otherwise
      return _remoteController != null
          ? Positioned.fill(
              child: AgoraVideoView(controller: _remoteController!),
            )
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            );
    } else {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      );
    }
  }

  Widget _buildCallerInfo() {
    final avatarUrl = widget.isIncoming
        ? widget.callerAvatar
        : widget.calleeAvatar;
    final personName = widget.isIncoming
        ? widget.callerName
        : widget.calleeName;

    return Positioned(
      top: 80,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24, width: 3),
              ),
              child: CircleAvatar(
                radius: 48,
                backgroundImage: avatarUrl != null
                    ? NetworkImage(avatarUrl)
                    : null,
                backgroundColor: const Color(0xFF0F3460),
                child: avatarUrl == null
                    ? Text(
                        personName.isNotEmpty
                            ? personName[0].toUpperCase()
                            : '?',
                        style: GoogleFonts.outfit(
                          fontSize: 36,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            // Name
            Text(
              personName,
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            // Status
            Text(
              _isConnected
                  ? _formatDuration(_elapsed)
                  : widget.isIncoming
                  ? 'Incoming ${widget.isVideoCall ? 'Video' : 'Voice'} Call...'
                  : _isJoining
                  ? 'Connecting...'
                  : 'Calling...',
              style: GoogleFonts.outfit(fontSize: 16, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Positioned(
      bottom: 50,
      left: 0,
      right: 0,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _CircleButton(
                icon: _isMuted ? Icons.mic_off : Icons.mic,
                label: _isMuted ? 'Unmute' : 'Mute',
                onTap: _toggleMute,
                active: _isMuted,
              ),
              const SizedBox(width: 24),
              if (widget.isVideoCall)
                _CircleButton(
                  icon: _isCameraOff ? Icons.videocam_off : Icons.videocam,
                  label: _isCameraOff ? 'Cam On' : 'Cam Off',
                  onTap: _toggleCamera,
                  active: _isCameraOff,
                ),
              if (widget.isVideoCall) const SizedBox(width: 24),
              _CircleButton(
                icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_off,
                label: _isSpeakerOn ? 'Speaker' : 'Earpiece',
                onTap: _toggleSpeaker,
                active: !_isSpeakerOn,
              ),
              if (widget.isVideoCall) ...[
                const SizedBox(width: 24),
                _CircleButton(
                  icon: Icons.flip_camera_ios,
                  label: 'Flip',
                  onTap: () => _agoraService.switchCamera(),
                  active: false,
                ),
              ],
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── End Call / Reject button ──
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (widget.isIncoming && !_isConnected) {
                    _agoraService.rejectCall(widget.conversationId).then((_) {
                      if (mounted) Navigator.of(context).pop();
                    });
                  } else {
                    _endCall();
                  }
                },
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
        ],
      ),
    );
  }
}

// ── Reusable circular control button ──
class _CircleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  const _CircleButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: active
                  ? Colors.white.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.outfit(fontSize: 12, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
