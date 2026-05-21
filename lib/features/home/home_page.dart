import 'package:flutter/material.dart';

import '../../services/demo_iptv_library_service.dart';
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

    final live = library.liveItems.map((e) => e.name).toList();
    final movies = library.movieItems.map((e) => e.name).toList();
    final series = library.seriesItems.map((e) => e.name).toList();

    return Scaffold(
      body: Row(
        children: [
          HomeSideMenu(
            onLive: () => _open(context, const LivePage()),
            onMovies: () => _open(context, const MoviesPage()),
            onSeries: () => _open(context, const SeriesPage()),
            onCategories: () => _open(context, const CategoriesPage()),
          ),

          Expanded(
            child: ListView(
              children: [
                HomeTopBar(
                  selectedServerId: selectedServerId,
                  onServerChanged: (v) =>
                      setState(() => selectedServerId = v),
                ),

                HomeContentRow(
                  title: 'Ao Vivo',
                  subtitle: '${library.liveCount}',
                  items: live,
                  icon: Icons.live_tv,
                ),

                HomeContentRow(
                  title: 'Filmes',
                  subtitle: '${library.movieCount}',
                  items: movies,
                  icon: Icons.movie,
                ),

                HomeContentRow(
                  title: 'Séries',
                  subtitle: '${library.seriesCount}',
                  items: series,
                  icon: Icons.movie_filter,
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
}
``
