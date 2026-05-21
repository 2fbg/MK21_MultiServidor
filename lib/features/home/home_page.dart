import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../models/server_config.dart';
import '../../services/iptv_library_service.dart';
import '../../services/server_config_service.dart';
import '../categories/categories_page.dart';
import '../live/live_page.dart';
import '../movies/movies_page.dart';
import '../series/series_page.dart';
import '../server_config/server_config_page.dart';
import 'widgets/home_content_row.dart';
import 'widgets/home_side_menu.dart';
import 'widgets/home_top_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<_HomeLoadResult> _future;
  String selectedServerId = 'mk21';

  @override
  void initState() {
    super.initState();
    _future = _loadLibrary();
  }

  Future<_HomeLoadResult> _loadLibrary() async {
    final config = await const ServerConfigService().load();

    if (config == null || config.playlistUrl.trim().isEmpty) {
      throw Exception('Nenhuma playlist salva. Configure um servidor primeiro.');
    }

    final profileId = config.profileId?.trim();
    if (profileId != null && profileId.isNotEmpty) {
      selectedServerId = profileId;
    }

    final uri = Uri.tryParse(config.playlistUrl.trim());

    if (uri == null) {
      throw Exception('URL da playlist inválida.');
    }

    final response = await http
        .get(
          uri,
          headers: {
            'User-Agent': config.userAgent,
            'Accept': '*/*',
            'Connection': 'keep-alive',
          },
        )
        .timeout(const Duration(seconds: 35));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Falha ao baixar playlist. HTTP ${response.statusCode}.',
      );
    }

    final content = response.body;

    if (!content.trimLeft().startsWith('#EXTM3U')) {
      throw Exception(
        'O servidor respondeu, mas o conteúdo não parece ser uma lista M3U.',
      );
    }

    final library = const IptvLibraryService().buildFromM3u(content);

    return _HomeLoadResult(
      config: config,
      library: library,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _Background(),
          SafeArea(
            child: FutureBuilder<_HomeLoadResult>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const _LoadingView();
                }

                if (snapshot.hasError) {
                  return _ErrorView(
                    message: snapshot.error.toString(),
                    onRetry: _reload,
                    onConfigure: _openServerConfig,
                  );
                }

                final result = snapshot.data!;
                final library = result.library;

                /// ✅ ✅ ✅ CORREÇÃO AQUI
                final live = library.liveItems.take(40).toList();
                final movies = library.movieItems.take(40).toList();
                final series = library.seriesItems.take(40).toList();

                return Row(
                  children: [
                    HomeSideMenu(
                      onHome: _reload,
                      onLive: () => _open(context, const LivePage()),
                      onMovies: () => _open(context, const MoviesPage()),
                      onSeries: () => _open(context, const SeriesPage()),
                      onCategories: () => _open(context, const CategoriesPage()),
                      onSettings: _openServerConfig,
                    ),
                    Expanded(
                      child: CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(
                            child: HomeTopBar(
                              selectedServerId: selectedServerId,
                              onServerChanged: (value) {
                                setState(() {
                                  selectedServerId = value;
                                });

                                _msg(
                                  'Servidor selecionado. (troca automática será ativada no próximo patch)',
                                );
                              },
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: _StatusBar(
                              serverName: result.config.serverName,
                              library: library,
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: HomeContentRow(
                              title: 'Ao Vivo',
                              subtitle: '${library.liveCount}',
                              items: live,
                              icon: Icons.live_tv,
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: HomeContentRow(
                              title: 'Filmes',
                              subtitle: '${library.movieCount}',
                              items: movies,
                              icon: Icons.movie,
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: HomeContentRow(
                              title: 'Séries',
                              subtitle: '${library.seriesCount}',
                              items: series,
                              icon: Icons.video_library,
                            ),
                          ),
                          const SliverToBoxAdapter(
                            child: SizedBox(height: 32),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _reload() {
    setState(() {
      _future = _loadLibrary();
    });
  }

  Future<void> _openServerConfig() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const ServerConfigPage(),
      ),
    );

    if (!mounted) return;

    _reload();
  }

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => page),
    );
  }

  void _msg(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _HomeLoadResult {
  const _HomeLoadResult({
    required this.config,
    required this.library,
  });

  final ServerConfig config;
  final IptvLibrary library;
}

class _Background extends StatelessWidget {
  const _Background();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topRight,
          radius: 1.1,
          colors: [
            Color(0xFF182B4F),
            Color(0xFF090D17),
            Color(0xFF05070D),
          ],
        ),
      ),
      child: SizedBox.expand(),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 44,
        height: 44,
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
    required this.onConfigure,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onConfigure;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        HomeSideMenu(
          onHome: onRetry,
          onSettings: onConfigure,
        ),
        Expanded(
          child: Center(
            child: Container(
              width: 620,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.055),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: Colors.white.withOpacity(0.10)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFE50914),
                    size: 44,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Não foi possível carregar a playlist',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    message,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.72),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      FilledButton.icon(
                        onPressed: onRetry,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tentar novamente'),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: onConfigure,
                        icon: const Icon(Icons.settings),
                        label: const Text('Configurar servidor'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({
    required this.serverName,
    required this.library,
  });

  final String serverName;
  final IptvLibrary library;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 4, 28, 14),
      child: Text(
        '$serverName • ${library.liveCount} canais • '
        '${library.movieCount} filmes • ${library.seriesCount} séries',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.white.withOpacity(0.62),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
