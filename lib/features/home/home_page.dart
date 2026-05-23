import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../models/playlist_item.dart';
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
  final _configService = const ServerConfigService();
  late Future<_HomeLoadResult> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadLibrary(forceRefresh: false);
  }

  Future<_HomeLoadResult> _loadLibrary({required bool forceRefresh}) async {
    final entry = await _configService.loadSelectedEntry();
    if (entry == null || entry.playlistUrl.trim().isEmpty) {
      throw Exception('Nenhuma lista salva. Configure um servidor primeiro.');
    }

    final cache = await _configService.loadPlaylistCache(entry.id);
    final shouldUseCacheFirst = !forceRefresh && cache != null && cache.content.trim().startsWith('#EXTM3U');

    if (shouldUseCacheFirst) {
      return _buildResult(
        entry: entry,
        content: cache.content,
        fromCache: true,
        cacheSavedAt: cache.savedAt,
      );
    }

    final uri = Uri.tryParse(entry.playlistUrl.trim());
    if (uri == null) {
      throw Exception('URL da playlist inválida.');
    }

    final response = await http.get(
      uri,
      headers: {
        'User-Agent': entry.userAgent,
        'Accept': '*/*',
        'Connection': 'keep-alive',
      },
    ).timeout(const Duration(seconds: 35));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      if (cache != null && cache.content.trim().startsWith('#EXTM3U')) {
        return _buildResult(
          entry: entry,
          content: cache.content,
          fromCache: true,
          cacheSavedAt: cache.savedAt,
        );
      }
      throw Exception('Falha ao baixar playlist. HTTP ${response.statusCode}.');
    }

    final content = response.body;
    if (!content.trimLeft().startsWith('#EXTM3U')) {
      throw Exception('O servidor respondeu, mas o conteúdo não parece ser uma lista M3U.');
    }

    final now = DateTime.now();
    await _configService.savePlaylistCache(
      PlaylistCacheData(
        content: content,
        savedAt: now,
        serverId: entry.id,
        serverName: entry.name,
      ),
    );

    return _buildResult(
      entry: entry,
      content: content,
      fromCache: false,
      cacheSavedAt: now,
    );
  }

  _HomeLoadResult _buildResult({
    required ServerEntry entry,
    required String content,
    required bool fromCache,
    required DateTime cacheSavedAt,
  }) {
    final library = const IptvLibraryService().buildFromM3u(content);
    return _HomeLoadResult(
      entry: entry,
      library: library,
      rawContent: content,
      fromCache: fromCache,
      cacheSavedAt: cacheSavedAt,
    );
  }

  void _reload({bool forceRefresh = true}) {
    setState(() {
      _future = _loadLibrary(forceRefresh: forceRefresh);
    });
  }

  Future<void> _openServerConfig() async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ServerConfigPage()));
    if (!mounted) return;
    _reload(forceRefresh: false);
  }

  Future<void> _changeServer(String id) async {
    await _configService.setSelectedServerId(id);
    if (!mounted) return;
    _reload(forceRefresh: false);
  }

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
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
                    onRetry: () => _reload(forceRefresh: true),
                    onConfigure: _openServerConfig,
                  );
                }

                final result = snapshot.data!;
                final library = result.library;
                final live = _slice(library.liveItems);
                final movies = _slice(library.currentYearHighlights(items: library.movieItems, limit: 40));
                final series = _slice(library.seriesItems.reversed.toList(), limit: 40);

                return Row(
                  children: [
                    HomeSideMenu(
                      onLive: () => _open(context, LivePage(result: result)),
                      onMovies: () => _open(context, MoviesPage(result: result)),
                      onSeries: () => _open(context, SeriesPage(result: result)),
                      onCategories: () => _open(context, CategoriesPage(result: result)),
                      onSettings: _openServerConfig,
                    ),
                    Expanded(
                      child: CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(
                            child: HomeTopBar(
                              selectedServerId: result.entry.id,
                              onServerChanged: _changeServer,
                              onRefresh: () => _reload(forceRefresh: true),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: _StatusBar(result: result),
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
                          const SliverToBoxAdapter(child: SizedBox(height: 32)),
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

  List<PlaylistItem> _slice(List<PlaylistItem> items, {int limit = 40}) {
    return items.take(limit).toList();
  }
}

class HomePageResultScope extends InheritedWidget {
  const HomePageResultScope({
    super.key,
    required this.result,
    required super.child,
  });

  final _HomeLoadResult result;

  static _HomeLoadResult of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<HomePageResultScope>();
    if (scope == null) {
      throw FlutterError('HomePageResultScope não encontrado no contexto.');
    }
    return scope.result;
  }

  @override
  bool updateShouldNotify(HomePageResultScope oldWidget) => oldWidget.result != result;
}

class _HomeLoadResult {
  const _HomeLoadResult({
    required this.entry,
    required this.library,
    required this.rawContent,
    required this.fromCache,
    required this.cacheSavedAt,
  });

  final ServerEntry entry;
  final IptvLibrary library;
  final String rawContent;
  final bool fromCache;
  final DateTime cacheSavedAt;
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
          colors: [Color(0xFF182B4F), Color(0xFF090D17), Color(0xFF05070D)],
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
      child: SizedBox(width: 44, height: 44, child: CircularProgressIndicator()),
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
        HomeSideMenu(onSettings: onConfigure),
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
                  const Icon(Icons.warning_amber_rounded, color: Color(0xFFE50914), size: 44),
                  const SizedBox(height: 16),
                  const Text(
                    'Não foi possível carregar a playlist',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    message,
                    style: TextStyle(color: Colors.white.withOpacity(0.72), height: 1.35),
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
  const _StatusBar({required this.result});

  final _HomeLoadResult result;

  @override
  Widget build(BuildContext context) {
    final library = result.library;
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 4, 28, 14),
      child: Text(
        '${result.entry.name} • ${library.liveCount} canais • ${library.movieCount} filmes • ${library.seriesCount} séries • ${result.fromCache ? 'cache local' : 'atualizado agora'}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.white.withOpacity(0.62), fontWeight: FontWeight.w700),
      ),
    );
  }
}
