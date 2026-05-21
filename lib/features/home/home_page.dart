import 'package:flutter/material.dart';

import '../../services/demo_iptv_library_service.dart';
import '../../services/iptv_library_service.dart';
import '../categories/categories_page.dart';
import '../live/live_page.dart';
import '../movies/movies_page.dart';
import '../series/series_page.dart';
import 'widgets/home_content_row.dart';
import 'widgets/home_side_menu.dart';
import 'widgets/home_top_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedServerId = 'mk21';

  @override
  Widget build(BuildContext context) {
    final library = DemoIptvLibraryService.build();

    final liveItems = library.liveItems.map((item) => item.name).toList();
    final movieItems = library.movieItems.map((item) => item.name).toList();
    final seriesItems = library.seriesItems.map((item) => item.name).toList();

    final currentYear = DateTime.now().year;
    final yearHighlights = library
        .currentYearHighlights(items: library.movieItems, year: currentYear)
        .map((item) => item.name)
        .toList();

    return Scaffold(
      body: Stack(
        children: [
          const _BackgroundGlow(),
          SafeArea(
            child: Row(
              children: [
                HomeSideMenu(
                  onHome: () => _showMessage(context, 'Home'),
                  onLive: () => _openPage(context, const LivePage()),
                  onMovies: () => _openPage(context, const MoviesPage()),
                  onSeries: () => _openPage(context, const SeriesPage()),
                  onCategories: () => _openPage(context, const CategoriesPage()),
                  onSettings: () => _showMessage(
                    context,
                    'Configuração de servidor será aberta no próximo bloco',
                  ),
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

                            _showMessage(
                              context,
                              'Servidor selecionado no topo. No próximo bloco vamos salvar e recarregar a playlist.',
                            );
                          },
                          onSearch: () => _showMessage(
                            context,
                            'Busca será ativada junto com a playlist real.',
                          ),
                          onSettings: () => _showMessage(
                            context,
                            'Configuração de servidor será aberta no próximo bloco.',
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: _LibraryStatus(library: library),
                      ),
                      SliverToBoxAdapter(
                        child: HomeContentRow(
                          title: 'Ao vivo',
                          subtitle: '${library.liveCount} canais',
                          items: liveItems,
                          icon: Icons.live_tv,
                          onItemTap: (title) => _showPlayerPreview(
                            context,
                            title,
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: HomeContentRow(
                          title: 'Lançamentos $currentYear',
                          subtitle: 'Destaques do ano vigente',
                          items: yearHighlights.isEmpty
                              ? movieItems.take(8).toList()
                              : yearHighlights,
                          icon: Icons.auto_awesome,
                          onItemTap: (title) => _showPlayerPreview(
                            context,
                            title,
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: HomeContentRow(
                          title: 'Filmes',
                          subtitle: '${library.movieCount} VODs',
                          items: movieItems,
                          icon: Icons.movie,
                          onItemTap: (title) => _showPlayerPreview(
                            context,
                            title,
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: HomeContentRow(
                          title: 'Séries',
                          subtitle: '${library.seriesCount} episódios',
                          items: seriesItems,
                          icon: Icons.video_library,
                          onItemTap: (title) => _showPlayerPreview(
                            context,
                            title,
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 32)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openPage(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => page),
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showPlayerPreview(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Abrindo player para: $title'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _BackgroundGlow extends StatelessWidget {
  const _BackgroundGlow();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topRight,
          radius: 1.1,
          colors: [Color(0xFF182B4F), Color(0xFF090D17), Color(0xFF05070D)],
          stops: [0.0, 0.45, 1.0],
        ),
      ),
      child: SizedBox.expand(),
    );
  }
}

class _LibraryStatus extends StatelessWidget {
  const _LibraryStatus({required this.library});

  final IptvLibrary library;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.045),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            const Icon(Icons.storage, color: Color(0xFFE50914), size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Biblioteca demo carregada: ${library.liveCount} ao vivo, '
                '${library.movieCount} filmes, ${library.seriesCount} séries.',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.78),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Próximo: playlist real',
              style: TextStyle(
                color: Colors.white.withOpacity(0.45),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
