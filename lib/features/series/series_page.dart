import 'package:flutter/material.dart';

import '../../services/demo_iptv_library_service.dart';
import '../shared/content_grid_page.dart';

class SeriesPage extends StatelessWidget {
  const SeriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final library = DemoIptvLibraryService.build();

    return ContentGridPage(
      title: 'Séries',
      subtitle: 'Episódios detectados por padrão S01E01 e 1x01',
      items: library.seriesItems,
      icon: Icons.video_library_outlined,
      accentColor: const Color(0xFF7C3AED),
    );
  }
}
