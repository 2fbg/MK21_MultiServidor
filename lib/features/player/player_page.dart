import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../models/playlist_item.dart';

class PlayerPage extends StatefulWidget {
  final PlaylistItem item;

  const PlayerPage({super.key, required this.item});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  VideoPlayerController? _controller;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.item.url),
      );

      await _controller!.initialize();
      await _controller!.play();

      if (mounted) {
        setState(() => _loading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
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
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _retry,
                            child: const Text('Tentar novamente'),
                          )
                        ],
                      )
                    : AspectRatio(
                        aspectRatio:
                            _controller!.value.aspectRatio == 0
                                ? 16 / 9
                                : _controller!.value.aspectRatio,
                        child: VideoPlayer(_controller!),
                      ),
          ),

          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
