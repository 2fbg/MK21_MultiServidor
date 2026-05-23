import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../../models/playlist_item.dart';

class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key, required this.item});

  final PlaylistItem item;

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  VideoPlayerController? _controller;
  bool _loading = true;
  String? _errorMessage;
  bool _overlayVisible = true;

  @override
  void initState() {
    super.initState();
    _enterFullscreen();
    _initializePlayer();
  }

  Future<void> _enterFullscreen() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  Future<void> _initializePlayer() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      await _controller?.dispose();
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.item.url),
        httpHeaders: const {
          'User-Agent': 'Mozilla/5.0',
          'Accept': '*/*',
          'Connection': 'keep-alive',
        },
      );

      _controller = controller;
      await controller.initialize();
      await controller.play();

      if (!mounted) return;
      setState(() => _loading = false);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = error.toString();
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _retry() async {
    await _initializePlayer();
  }

  void _toggleOverlay() {
    setState(() => _overlayVisible = !_overlayVisible);
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleOverlay,
        child: Stack(
          children: [
            Positioned.fill(child: Center(child: _buildPlayerBody(controller))),
            if (_overlayVisible)
              Positioned.fill(
                child: _PlayerOverlay(
                  itemName: widget.item.name,
                  errorMessage: _errorMessage,
                  isLive: widget.item.type.name == 'live',
                  onBack: () => Navigator.of(context).pop(),
                  onRetry: _retry,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerBody(VideoPlayerController? controller) {
    if (_loading) {
      return const CircularProgressIndicator(color: Colors.white);
    }
    if (_errorMessage != null) {
      return const SizedBox.shrink();
    }
    if (controller == null || !controller.value.isInitialized) {
      return const SizedBox.shrink();
    }

    final aspectRatio = controller.value.aspectRatio <= 0 ? 16 / 9 : controller.value.aspectRatio;
    return AspectRatio(aspectRatio: aspectRatio, child: VideoPlayer(controller));
  }
}

class _PlayerOverlay extends StatelessWidget {
  const _PlayerOverlay({
    required this.itemName,
    required this.errorMessage,
    required this.isLive,
    required this.onBack,
    required this.onRetry,
  });

  final String itemName;
  final String? errorMessage;
  final bool isLive;
  final VoidCallback onBack;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Row(
              children: [
                _CircleButton(icon: Icons.arrow_back, onTap: onBack),
                const Spacer(),
                _CircleButton(icon: Icons.refresh, onTap: onRetry),
              ],
            ),
          ),
          if (errorMessage != null)
            Center(
              child: Container(
                width: 520,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.78),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white.withOpacity(0.14)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, color: Color(0xFFE50914), size: 46),
                    const SizedBox(height: 14),
                    const Text(
                      'Erro ao reproduzir',
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      errorMessage!,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white.withOpacity(0.72), height: 1.3),
                    ),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            left: 20,
            bottom: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.52),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withOpacity(0.10)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color: isLive ? const Color(0xFFE50914) : const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      isLive ? 'LIVE' : 'PLAY',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      itemName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
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

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.55),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}
