import 'package:flutter/material.dart';

import 'widgets/home_action_card.dart';
import 'widgets/home_content_row.dart';
import 'widgets/home_side_menu.dart';
import 'widgets/home_top_bar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const featuredItems = [
    'ESPN Brasil',
    'Premiere Clubes',
    'Telecine Premium',
    'HBO',
    'Discovery',
    'Globo HD',
    'SporTV',
    'Band News',
  ];

  static const continueItems = [
    'Filme interrompido',
    'Série T01:E03',
    'Canal visto recentemente',
    'Documentário',
    'Novela',
  ];

  static const movieItems = [
    'Lançamentos 2026',
    'Mais assistidos',
    'Ação',
    'Comédia',
    'Drama',
    'Infantil',
  ];

  static const seriesItems = [
    'Séries em alta',
    'Novas temporadas',
    'Continuar série',
    'Drama',
    'Suspense',
    'Família',
  ];

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Stack(
        children: [
          _BackgroundGlow(),
          SafeArea(
            child: Row(
              children: [
                HomeSideMenu(),
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(child: HomeTopBar()),
                      SliverToBoxAdapter(child: _HeroBanner()),
                      SliverToBoxAdapter(child: _QuickActions()),
                      SliverToBoxAdapter(
                        child: HomeContentRow(
                          title: 'Destaques ao vivo',
                          subtitle: 'Canais rápidos para TV Box',
                          items: featuredItems,
                          icon: Icons.live_tv,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: HomeContentRow(
                          title: 'Continuar assistindo',
                          subtitle: 'Retome de onde parou',
                          items: continueItems,
                          icon: Icons.play_circle,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: HomeContentRow(
                          title: 'Filmes',
                          subtitle: 'VOD separado dos canais ao vivo',
                          items: movieItems,
                          icon: Icons.movie,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: HomeContentRow(
                          title: 'Séries',
                          subtitle: 'Temporadas e episódios organizados',
                          items: seriesItems,
                          icon: Icons.video_library,
                        ),
                      ),
                      SliverToBoxAdapter(child: SizedBox(height: 48)),
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
  const _HeroBanner();

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
              width: 560,
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
                    'Ao Vivo, Filmes e Séries com separação rígida, favoritos, EPG, PIN parental e player profissional.',
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
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(28, 4, 28, 18),
      child: Row(
        children: [
          Expanded(
            child: HomeActionCard(
              title: 'Ao Vivo',
              subtitle: 'Canais e categorias',
              icon: Icons.live_tv,
              color: Color(0xFFE50914),
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: HomeActionCard(
              title: 'Filmes',
              subtitle: 'VOD organizado',
              icon: Icons.movie_creation_outlined,
              color: Color(0xFF00A3FF),
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: HomeActionCard(
              title: 'Séries',
              subtitle: 'Temporadas e episódios',
              icon: Icons.video_library_outlined,
              color: Color(0xFF7C3AED),
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: HomeActionCard(
              title: 'EPG',
              subtitle: 'Guia de programação',
              icon: Icons.calendar_month,
              color: Color(0xFF10B981),
            ),
          ),
        ],
      ),
    );
  }
}
