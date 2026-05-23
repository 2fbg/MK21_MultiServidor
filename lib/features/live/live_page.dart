import 'package:flutter/material.dart';

import '../home/home_page.dart';
import '../shared/content_grid_page.dart';

class LivePage extends StatelessWidget {
  const LivePage({super.key, required this.result});

  final dynamic result;

  @override
  Widget build(BuildContext context) {
    final library = result.library;

    return ContentGridPage(
      title: 'Ao Vivo',
      subtitle: 'Canais carregados da lista selecionada',
      items: library.liveItems,
      icon: Icons.live_tv,
      accentColor: const Color(0xFFE50914),
    );
  }
}
