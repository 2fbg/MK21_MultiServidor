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

    final liveItems = library.liveItems.map((e) => e.name).toList();
    final movieItems = library.movieItems.map((e) => e.name).toList();
    final seriesItems = library.seriesItems.map((e) => e.name).toList();

    final currentYear = DateTime.now().year;
    final highlights = library
        .currentYearHighlights(
          items: library.movieItems,
          year: currentYear,
        )
        .map((e) => e.name)
        .toList();

    return Scaffold(
      body: Stack(
        children: [
          const _Background(),
          SafeArea(
            child: Row(
              children: [
                HomeSideMenu(
                  onHome: () {},
                  onLive: () => _open(context, const LivePage()),
                  onMovies: () => _open(context, const MoviesPage()),
                  onSeries: () => _open(context, const SeriesPage()),
                  onCategories: () =>
                      _open(context, const CategoriesPage()),
                  onSettings: () => _msg(context, 'Configuração em breve'),
                ),

                /// ✅ CONTEÚDO PRINCIPAL
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: HomeTopBar(
                          selectedServerId: selectedServerId,
                          onServerChanged: (value) {
                            setState(() => selectedServerId = value);

                            _msg(
                              context,
                              'Servidor alterado (ainda não recarrega M3U)',
                            );
                          },
                          onSearch: () =>
                              _msg(context, 'Busca em construção'),
                          onSettings: () =>
                              _msg(context, 'Abrir config servidor'),
                        ),
                      ),

                      /// ✅ STATUS LIMPO
                      SliverToBoxAdapter(
                        child: _StatusBar(library: library),
                      ),

                      /// ✅ AO VIVO
                      SliverToBoxAdapter(
                        child: HomeContentRow(
                          title: 'Ao vivo',
                          subtitle: '${library.liveCount} canais',
                          items: liveItems,
                          icon: Icons.live_tv,
                          onItemTap: (t) =>
                              _msg(context, 'Abrir player: $t'),
                        ),
                      ),

                      /// ✅ LANÇAMENTOS
                      SliverToBoxAdapter(
                        child: HomeContentRow(
                          title: 'Lançamentos $currentYear',
                          subtitle: 'Filmes recentes',
                          items: highlights.isEmpty
                              ? movieItems.take(8).toList()
                              : highlights,
                          icon: Icons.auto_awesome,
                          onItemTap: (t) =>
                              _msg(context, 'Abrir player: $t'),
                        ),
                      ),

                      /// ✅ FILMES
                      SliverToBoxAdapter(
                        child: HomeContentRow(
                          title: 'Filmes',
                          subtitle: '${library.movieCount}',
                          items: movieItems,
                          icon: Icons.movie,
                          onItemTap: (t) =>
                              _msg(context, 'Abrir player: $t'),
                        ),
                      ),

                      /// ✅ SÉRIES
                      SliverToBoxAdapter(
                        child: HomeContentRow(
                          title: 'Séries',
                          subtitle: '${library.seriesCount}',
                          items: seriesItems,
                          icon: Icons.video_library,
                          onItemTap: (t) =>
                              _msg(context, 'Abrir player: $t'),
                        ),
                      ),

                      const SliverToBoxAdapter(
                        child: SizedBox(height: 30),
                      ),
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

  void _open(BuildContext c, Widget page) {
    Navigator.of(c).push(MaterialPageRoute(builder: (_) => page));
  }

  void _msg(BuildContext c, String m) {
    ScaffoldMessenger.of(c).showSnackBar(
      SnackBar(content: Text(m)),
    );
  }
}

/// ✅ FUNDO
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

/// ✅ STATUS LIMPO
class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.library});

  final IptvLibrary library;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 6, 24, 10),
      child: Text(
        '${library.liveCount} canais • ${library.movieCount} filmes • ${library.seriesCount} séries',
        style: TextStyle(
          color: Colors.white.withOpacity(0.6),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
``
