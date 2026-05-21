import 'package:flutter/material.dart';

import '../../services/demo_iptv_library_service.dart';
import '../shared/content_grid_page.dart';

class MoviesPage extends StatelessWidget {
  const MoviesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final library = DemoIptvLibraryService.build();

    return ContentGridPage(
      title: 'Filmes',
      subtitle: 'VODs separados dos canais e das séries',
      items: library.movieItems,
      icon: Icons.movie_creation_outlined,
      accentColor: const Color(0xFF00A3FF),
    );
  }
}
