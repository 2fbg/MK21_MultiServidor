import 'package:flutter/material.dart';

class HomeContentRow extends StatelessWidget {
  const HomeContentRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.items,
    required this.icon,
    this.onItemTap,
  });

  final String title;
  final String subtitle;
  final List<String> items;
  final IconData icon;
  final ValueChanged<String>? onItemTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFE50914), size: 22),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.48),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 148,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final title = items[index];

                return _PosterCard(
                  title: title,
                  index: index,
                  onTap: () => onItemTap?.call(title),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PosterCard extends StatefulWidget {
  const _PosterCard({
    required this.title,
    required this.index,
    this.onTap,
  });

  final String title;
  final int index;
  final VoidCallback? onTap;

  @override
  State<_PosterCard> createState() => _PosterCardState();
}

class _PosterCardState extends State<_PosterCard> {
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
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 150),
          scale: focused ? 1.045 : 1,
          child: Container(
            width: 214,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(colors: colors),
              border: Border.all(
                color: focused ? Colors.white : Colors.white12,
                width: focused ? 2 : 1,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -8,
                  top: -6,
                  child: Icon(
                    Icons.play_circle_fill,
                    size: 68,
                    color: Colors.white.withOpacity(0.12),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    widget.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
``
