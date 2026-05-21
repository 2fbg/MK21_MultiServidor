import 'package:flutter/material.dart';

import '../../services/demo_iptv_library_service.dart';
import '../../services/iptv_library_service.dart';
import 'widgets/home_action_card.dart';
import 'widgets/home_content_row.dart';
import 'widgets/home_side_menu.dart';
import 'widgets/home_top_bar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
                const HomeSideMenu(),
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      const SliverToBoxAdapter(child: HomeTopBar()),
                      SliverToBoxAdapter(child: _HeroBanner(library: library)),
                      SliverToBoxAdapter(
                        child: _QuickActions(library: library),
                      ),
                      SliverToBoxAdapter(
                        child: HomeContentRow(
                          title: 'Destaques ao vivo',
                          subtitle: '${library.liveCount} canais separados',
                          items: liveItems,
                          icon: Icons.live_tv,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: HomeContentRow(
                          title: 'Lançamentos $currentYear',
                          subtitle: 'Destaques do ano vigente',
                          items: yearHighlights.isEmpty
                              ? movieItems.take(6).toList()
                              : yearHighlights,
                          icon: Icons.auto_awesome,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: HomeContentRow(
                          title: 'Filmes',
                          subtitle: '${library.movieCount} VODs organizados',
                          items: movieItems,
                          icon: Icons.movie,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: HomeContentRow(
                          title: 'Séries',
                          subtitle:
                              '${library.seriesCount} episódios detectados',
                          items: seriesItems,
                          icon: Icons.video_library,
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 48)),
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

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.library});

  final IptvLibrary library;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 18, 28, 18),
      child: Container(
        height: 310,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            colors: [Color(0xFF111827), Color(0xFF14213D), Color(0xFF5A0710)],
          ),
          border: Border.all(color: Colors.white12),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 34,
              top: 34,
              bottom: 34,
              width: 620,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE50914),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'MK21 MULTISERVIDOR PRO',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Sua central IPTV premium',
                    style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Biblioteca carregada com ${library.totalCount} itens: '
                    '${library.liveCount} ao vivo, '
                    '${library.movieCount} filmes e '
                    '${library.seriesCount} séries.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.78),
                      height: 1.4,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      FilledButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Entrar agora'),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.settings),
                        label: const Text('Configurar servidor'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              right: 34,
              top: 42,
              child: Icon(
                Icons.connected_tv,
                size: 150,
                color: Colors.white.withOpacity(0.14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.library});

  final IptvLibrary library;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 4, 28, 18),
      child: Row(
        children: [
          Expanded(
            child: HomeActionCard(
              title: 'Ao Vivo',
              subtitle: '${library.liveCount} canais',
              icon: Icons.live_tv,
              color: const Color(0xFFE50914),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: HomeActionCard(
              title: 'Filmes',
              subtitle: '${library.movieCount} VODs',
              icon: Icons.movie_creation_outlined,
              color: const Color(0xFF00A3FF),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: HomeActionCard(
              title: 'Séries',
              subtitle: '${library.seriesCount} episódios',
              icon: Icons.video_library_outlined,
              color: const Color(0xFF7C3AED),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: HomeActionCard(
              title: 'Categorias',
              subtitle: '${library.categories.length} grupos',
              icon: Icons.category,
              color: const Color(0xFF10B981),
            ),
          ),
        ],
      ),
    );
  }
}
