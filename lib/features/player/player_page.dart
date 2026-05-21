import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../models/playlist_item.dart';

class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key, required this.item});

  final PlaylistItem item;

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  late VideoPlayerController _controller;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      _controller = VideoPlayerController.network(widget.item.url);

      await _controller.initialize();
      await _controller.play();

      setState(() => _loading = false);
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _retry() {
    setState(() {
      _loading = true;
      _error = null;
    });
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: _loading
                ? const CircularProgressIndicator()
                : _error != null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Erro ao reproduzir',
                              style: TextStyle(color: Colors.white)),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: _retry,
                            child: const Text('Tentar novamente'),
                          )
                        ],
                      )
                    : AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      ),
          ),

          /// TOP BAR
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                Row(
                  children: const [
                    Icon(Icons.favorite_border, color: Colors.white),
                    SizedBox(width: 12),
                    Icon(Icons.lock_outline, color: Colors.white),
                    SizedBox(width: 12),
                    Icon(Icons.search, color: Colors.white),
                    SizedBox(width: 12),
                    Icon(Icons.fullscreen, color: Colors.white),
                  ],
                )
              ],
            ),
          ),

          /// BOTTOM INFO
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.item.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'LIVE',
                  style: TextStyle(color: Colors.green),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
``
