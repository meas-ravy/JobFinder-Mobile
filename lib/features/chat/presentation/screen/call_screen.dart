import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/features/recruiter/presentation/provider/recruiter_provider.dart';
import 'package:job_finder/features/job_seeker/presentation/provider/chat_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:job_finder/core/helper/secure_storage.dart';

class CallScreen extends ConsumerStatefulWidget {
  final String channelName;
  final String? token;
  final String? appId;
  final String? uid;
  final bool isVideoCall;
  final String remoteName;
  final String? remoteAvatar;

  const CallScreen({
    super.key,
    required this.channelName,
    this.token,
    this.appId,
    this.uid,
    required this.isVideoCall,
    required this.remoteName,
    this.remoteAvatar,
  });

  @override
  ConsumerState<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends ConsumerState<CallScreen> {
  int? _remoteUid;
  bool _localUserJoined = false;
  late RtcEngine _engine;
  bool _isEngineInitialized = false;
  bool _muted = false;
  bool _videoEnabled = true;

  @override
  void initState() {
    super.initState();
    _videoEnabled = widget.isVideoCall;
    initAgora();
  }

  Future<void> initAgora() async {
    // Retrieve permissions
    await [Permission.microphone, Permission.camera].request();

    String? token = widget.token;
    String? appId = widget.appId;
    String? uid = widget.uid;

    // If token is missing (incoming call from notification), fetch it
    if (token == null || appId == null || uid == null) {
      final storage = TokenStorageImpl(const FlutterSecureStorage());
      final role = await storage.readRole();

      if (role == 'Recruiter') {
        await ref
            .read(recruiterControllerProvider.notifier)
            .getAgoraToken(widget.channelName);
        final state = ref.read(recruiterControllerProvider);
        token = state.agoraToken;
        appId = state.agoraAppId;
        uid = state.agoraUid;
      } else {
        await ref
            .read(jobSeekerChatControllerProvider.notifier)
            .getAgoraToken(widget.channelName);
        final state = ref.read(jobSeekerChatControllerProvider);
        token = state.agoraToken;
        appId = state.agoraAppId;
        uid = state.agoraUid;
      }
    }

    if (token == null || appId == null || uid == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to join call: Missing token or UID"),
          ),
        );
        Navigator.pop(context);
      }
      return;
    }

    // Create the engine
    _engine = createAgoraRtcEngine();
    await _engine.initialize(
      RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );
    _isEngineInitialized = true;

    if (widget.isVideoCall) {
      await _engine.enableVideo();
      await _engine.startPreview();
    } else {
      await _engine.enableAudio();
    }

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("local user ${connection.localUid} joined");
          setState(() {
            _localUserJoined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("remote user $remoteUid joined");
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline:
            (
              RtcConnection connection,
              int remoteUid,
              UserOfflineReasonType reason,
            ) {
              debugPrint("remote user $remoteUid left channel");
              setState(() {
                _remoteUid = null;
              });
              // Also end the call if the remote user leaves
              _onCallEnd(context);
            },
        onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
          debugPrint(
            '[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token',
          );
        },
      ),
    );

    await _engine.joinChannelWithUserAccount(
      token: token,
      channelId: widget.channelName,
      userAccount: uid,
      options: const ChannelMediaOptions(),
    );
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  Future<void> _dispose() async {
    if (_isEngineInitialized) {
      await _engine.leaveChannel();
      await _engine.release();
    }
  }

  void _onCallEnd(BuildContext context) {
    Navigator.pop(context);
  }

  void _onToggleMute() {
    setState(() {
      _muted = !_muted;
    });
    _engine.muteLocalAudioStream(_muted);
  }

  void _onToggleVideo() {
    if (!widget.isVideoCall) return;
    setState(() {
      _videoEnabled = !_videoEnabled;
    });
    _engine.muteLocalVideoStream(!_videoEnabled);
  }

  void _onSwitchCamera() {
    if (!widget.isVideoCall) return;
    _engine.switchCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Remote Video or Audio Avatar
            Center(child: _remoteVideo()),
            // Local Video
            if (_localUserJoined && _videoEnabled)
              Positioned(
                top: 20,
                right: 20,
                child: SizedBox(
                  width: 100,
                  height: 150,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: AgoraVideoView(
                      controller: VideoViewController(
                        rtcEngine: _engine,
                        canvas: const VideoCanvas(uid: 0),
                      ),
                    ),
                  ),
                ),
              ),
            // Top Bar with Name
            Positioned(
              top: 20,
              left: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.remoteName,
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _remoteUid == null ? "Calling..." : "In Call",
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            // Bottom Toolbar
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _toolbarButton(
                    icon: _muted ? Icons.mic_off : Icons.mic,
                    color: _muted ? Colors.red : Colors.white24,
                    iconColor: Colors.white,
                    onPressed: _onToggleMute,
                  ),
                  _toolbarButton(
                    icon: Icons.call_end,
                    color: Colors.red,
                    iconColor: Colors.white,
                    onPressed: () => _onCallEnd(context),
                    size: 64,
                  ),
                  if (widget.isVideoCall)
                    _toolbarButton(
                      icon: _videoEnabled ? Icons.videocam : Icons.videocam_off,
                      color: _videoEnabled ? Colors.white24 : Colors.red,
                      iconColor: Colors.white,
                      onPressed: _onToggleVideo,
                    ),
                  if (widget.isVideoCall && _videoEnabled)
                    _toolbarButton(
                      icon: Icons.switch_camera,
                      color: Colors.white24,
                      iconColor: Colors.white,
                      onPressed: _onSwitchCamera,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _remoteVideo() {
    if (_remoteUid != null && widget.isVideoCall) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: RtcConnection(channelId: widget.channelName),
        ),
      );
    } else {
      // Audio or pending call
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 80,
            backgroundImage: widget.remoteAvatar != null
                ? NetworkImage(widget.remoteAvatar!)
                : null,
            backgroundColor: Colors.white12,
            child: widget.remoteAvatar == null
                ? Text(
                    widget.remoteName.isNotEmpty ? widget.remoteName[0] : '?',
                    style: const TextStyle(fontSize: 48, color: Colors.white),
                  )
                : null,
          ),
          const SizedBox(height: 32),
          Text(
            _remoteUid != null
                ? "Connected"
                : "Waiting for ${widget.remoteName}...",
            style: GoogleFonts.outfit(color: Colors.white54, fontSize: 18),
          ),
        ],
      );
    }
  }

  Widget _toolbarButton({
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onPressed,
    double size = 56,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: size * 0.5),
      ),
    );
  }
}
