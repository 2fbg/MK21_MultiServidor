import 'package:flutter/material.dart';

class HomeContentRow extends StatelessWidget {
  const HomeContentRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.items,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final List<String> items;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 12, 28, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFE50914)),
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
                  color: Colors.white.withOpacity(0.48),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 154,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                return _PosterCard(title: items[index], index: index);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PosterCard extends StatefulWidget {
  const _PosterCard({required this.title, required this.index});

  final String title;
  final int index;

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
      child: AnimatedScale(
        duration: const Duration(milliseconds: 150),
        scale: focused ? 1.06 : 1,
        child: Container(
          width: 220,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
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
                  size: 72,
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
                    fontSize: 17,
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
