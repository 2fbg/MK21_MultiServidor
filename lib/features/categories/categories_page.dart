import 'package:flutter/material.dart';

import '../../models/content_type.dart';
import '../../models/playlist_category.dart';
import '../../services/demo_iptv_library_service.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final library = DemoIptvLibraryService.build();

    final liveCategories = library.categories
        .where((category) => category.type == ContentType.live)
        .toList();

    final movieCategories = library.categories
        .where((category) => category.type == ContentType.movie)
        .toList();

    final seriesCategories = library.categories
        .where((category) => category.type == ContentType.series)
        .toList();

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.15,
            colors: [Color(0xFF182B4F), Color(0xFF090D17), Color(0xFF05070D)],
            stops: [0.0, 0.45, 1.0],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: _Header()),
              SliverToBoxAdapter(
                child: _CategorySection(
                  title: 'Ao Vivo',
                  subtitle: '${liveCategories.length} grupos de canais',
                  icon: Icons.live_tv,
                  color: Color(0xFFE50914),
                  categories: liveCategories,
                ),
              ),
              SliverToBoxAdapter(
                child: _CategorySection(
                  title: 'Filmes',
                  subtitle: '${movieCategories.length} grupos de VOD',
                  icon: Icons.movie_creation_outlined,
                  color: Color(0xFF00A3FF),
                  categories: movieCategories,
                ),
              ),
              SliverToBoxAdapter(
                child: _CategorySection(
                  title: 'Séries',
                  subtitle: '${seriesCategories.length} grupos de episódios',
                  icon: Icons.video_library_outlined,
                  color: Color(0xFF7C3AED),
                  categories: seriesCategories,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 36)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 22, 28, 18),
      child: Row(
        children: [
          IconButton.filledTonal(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back),
          ),
          const SizedBox(width: 16),
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.22),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFF10B981).withOpacity(0.65),
              ),
            ),
            child: const Icon(
              Icons.category,
              color: Color(0xFF10B981),
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Categorias',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.7,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Grupos separados por Ao Vivo, Filmes e Séries',
                  style: TextStyle(fontSize: 14, color: Colors.white60),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.categories,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<PlaylistCategory> categories;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 12, 28, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.52),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categories.length,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 310,
              mainAxisExtent: 104,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
            ),
            itemBuilder: (context, index) {
              return _CategoryCard(category: categories[index], color: color);
            },
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatefulWidget {
  const _CategoryCard({required this.category, required this.color});

  final PlaylistCategory category;
  final Color color;

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool focused = false;

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      onFocusChange: (value) => setState(() => focused = value),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 150),
        scale: focused ? 1.035 : 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [widget.color.withOpacity(0.72), const Color(0xFF101522)],
            ),
            border: Border.all(
              color: focused ? Colors.white : Colors.white.withOpacity(0.10),
              width: focused ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.folder_rounded,
                color: Colors.white.withOpacity(0.9),
                size: 34,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  widget.category.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
