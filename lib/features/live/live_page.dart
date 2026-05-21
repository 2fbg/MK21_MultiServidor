import 'package:flutter/material.dart';

import '../../services/demo_iptv_library_service.dart';
import '../shared/content_grid_page.dart';

class LivePage extends StatelessWidget {
  const LivePage({super.key});

  @override
  Widget build(BuildContext context) {
    final library = DemoIptvLibraryService.build();

    return ContentGridPage(
      title: 'Ao Vivo',
      subtitle: 'Canais separados rigidamente da playlist M3U',
      items: library.liveItems,
      icon: Icons.live_tv,
      accentColor: const Color(0xFFE50914),
    );
  }
}
