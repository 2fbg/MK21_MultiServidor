import 'package:flutter/material.dart';

import '../shared/content_grid_page.dart';

class SeriesPage extends StatelessWidget {
  const SeriesPage({super.key, required this.result});

  final dynamic result;

  @override
  Widget build(BuildContext context) {
    final library = result.library;

    return ContentGridPage(
      title: 'Séries',
      subtitle: 'Episódios detectados na playlist atual',
      items: library.seriesItems,
      icon: Icons.video_library_outlined,
      accentColor: const Color(0xFF7C3AED),
    );
  }
}
