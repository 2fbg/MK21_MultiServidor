import 'package:flutter/material.dart';

import '../shared/content_grid_page.dart';

class MoviesPage extends StatelessWidget {
  const MoviesPage({super.key, required this.result});

  final dynamic result;

  @override
  Widget build(BuildContext context) {
    final library = result.library;

    return ContentGridPage(
      title: 'Filmes',
      subtitle: 'VODs reais da playlist atual',
      items: library.movieItems,
      icon: Icons.movie_creation_outlined,
      accentColor: const Color(0xFF00A3FF),
    );
  }
}
