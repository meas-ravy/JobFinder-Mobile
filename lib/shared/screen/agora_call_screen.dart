import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:job_finder/core/services/agora_service.dart';

class AgoraCallScreen extends StatefulWidget {
  final String conversationId;
  final String callerName;
  final String? callerAvatar;
  final String calleeId;
  final String calleeName;
  final bool isVideoCall;
  final bool isIncoming; // true = receiver, false = caller

  const AgoraCallScreen({
    super.key,
    required this.conversationId,
    required this.callerName,
    required this.callerAvatar,
    required this.calleeId,
    required this.calleeName,
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
  bool _isConnected = false;
  bool _isLoading = false;

  int? _remoteUid;
  StreamSubscription<int>? _remoteJoinedSub;
  StreamSubscription<int>? _remoteLeftSub;
  StreamSubscription<CallState>? _callStateSub;

  Duration _elapsed = Duration.zero;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _listenToEvents();
    if (!widget.isIncoming) {
      _startCall();
    }
  }

  void _listenToEvents() {
    _remoteJoinedSub = _agoraService.remoteUserJoinedStream.listen((uid) {
      if (mounted) {
        setState(() {
          _remoteUid = uid;
          _isConnected = true;
          _isLoading = false;
        });
        _startTimer();
      }
    });

    _remoteLeftSub = _agoraService.remoteUserLeftStream.listen((_) {
      if (mounted) _endCall();
    });

    _callStateSub = _agoraService.callStateStream.listen((state) {
      if (state == CallState.ended && mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  Future<void> _startCall() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      await _agoraService.joinCall(
        conversationId: widget.conversationId,
        isVideoCall: widget.isVideoCall,
      );
      await _agoraService.setSpeakerOn(_isSpeakerOn);
    } catch (e) {
      if (mounted) {
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

  Future<void> _endCall() async {
    _timer?.cancel();
    await _agoraService.endCall(widget.conversationId);
    if (mounted) Navigator.of(context).pop();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Stack(
        children: [
          // ── Background: video streams or dark gradient ──
          _buildBackground(),

          // ── Top: caller info ──
          _buildCallerInfo(),

          // ── Bottom: controls ──
          _buildControls(),

          // ── Loading overlay ──
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    if (widget.isVideoCall) {
      return Stack(
        children: [
          // Remote video (full screen)
          if (_remoteUid != null)
            Positioned.fill(
              child: _agoraService.getRemoteView(
                _remoteUid!,
                widget.conversationId,
              ),
            )
          else
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

          // Local video (picture-in-picture)
          if (!_isCameraOff)
            Positioned(
              top: 80,
              right: 16,
              width: 100,
              height: 150,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _agoraService.getLocalView(),
              ),
            ),
        ],
      );
    } else {
      // Voice call background
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
    final avatarUrl = widget.isIncoming ? widget.callerAvatar : null;
    final personName = widget.isIncoming
        ? widget.callerName
        : widget.calleeName;

    return Positioned(
      top: 80,
      left: 0,
      right: 0,
      child: Column(
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
                      personName.isNotEmpty ? personName[0].toUpperCase() : '?',
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
                : _isLoading
                ? widget.isIncoming
                      ? 'Incoming ${widget.isVideoCall ? 'Video' : 'Voice'} Call...'
                      : 'Calling...'
                : 'Connecting...',
            style: GoogleFonts.outfit(fontSize: 16, color: Colors.white70),
          ),
        ],
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
          // ── Row 1: Mute / Camera / Speaker ──
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

          // ── Row 2: Accept (incoming) / End Call ──
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.isIncoming) ...[
                // Accept button
                GestureDetector(
                  onTap: () async {
                    await _agoraService.acceptCall(widget.conversationId);
                    await _startCall();
                  },
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.call,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(width: 60),
              ],
              // End / Reject button
              GestureDetector(
                onTap: widget.isIncoming && !_isConnected
                    ? () async {
                        await _agoraService.rejectCall(widget.conversationId);
                        if (mounted) Navigator.of(context).pop();
                      }
                    : _endCall,
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
