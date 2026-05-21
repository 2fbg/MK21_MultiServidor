import 'package:flutter/material.dart';

import '../../models/playlist_item.dart';

class ContentGridPage extends StatelessWidget {
  const ContentGridPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.items,
    required this.icon,
    required this.accentColor,
  });

  final String title;
  final String subtitle;
  final List<PlaylistItem> items;
  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
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
          child: Column(
            children: [
              _Header(
                title: title,
                subtitle: subtitle,
                icon: icon,
                accentColor: accentColor,
                count: items.length,
              ),
              Expanded(
                child: items.isEmpty
                    ? const _EmptyState()
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(28, 10, 28, 32),
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 260,
                              mainAxisExtent: 158,
                              mainAxisSpacing: 18,
                              crossAxisSpacing: 18,
                            ),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          return _ContentCard(
                            item: items[index],
                            index: index,
                            accentColor: accentColor,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.count,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final int count;

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
              color: accentColor.withOpacity(0.22),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: accentColor.withOpacity(0.65)),
            ),
            child: Icon(icon, color: accentColor, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.7,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.62),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withOpacity(0.10)),
            ),
            child: Text(
              '$count itens',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContentCard extends StatefulWidget {
  const _ContentCard({
    required this.item,
    required this.index,
    required this.accentColor,
  });

  final PlaylistItem item;
  final int index;
  final Color accentColor;

  @override
  State<_ContentCard> createState() => _ContentCardState();
}

class _ContentCardState extends State<_ContentCard> {
  bool focused = false;

  static const gradients = [
    [Color(0xFF16213E), Color(0xFF0F3460)],
    [Color(0xFF3A0CA3), Color(0xFF7209B7)],
    [Color(0xFF7F1D1D), Color(0xFFE50914)],
    [Color(0xFF064E3B), Color(0xFF10B981)],
    [Color(0xFF1E3A8A), Color(0xFF2563EB)],
    [Color(0xFF4A044E), Color(0xFFC026D3)],
  ];

  @override
  Widget build(BuildContext context) {
    final colors = gradients[widget.index % gradients.length];

    return FocusableActionDetector(
      onFocusChange: (value) => setState(() => focused = value),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 150),
        scale: focused ? 1.045 : 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
            border: Border.all(
              color: focused ? Colors.white : Colors.white.withOpacity(0.10),
              width: focused ? 2 : 1,
            ),
            boxShadow: [
              if (focused)
                BoxShadow(
                  color: widget.accentColor.withOpacity(0.28),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -6,
                top: -6,
                child: Icon(
                  Icons.play_circle_fill,
                  size: 70,
                  color: Colors.white.withOpacity(0.13),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if ((widget.item.groupTitle ?? '').isNotEmpty)
                    Text(
                      widget.item.groupTitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.62),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  const Spacer(),
                  Text(
                    widget.item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Nenhum item encontrado.',
        style: TextStyle(
          color: Colors.white.withOpacity(0.65),
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
