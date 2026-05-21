import 'package:flutter/material.dart';

class HomeSideMenu extends StatelessWidget {
  const HomeSideMenu({
    super.key,
    this.onHome,
    this.onLive,
    this.onMovies,
    this.onSeries,
    this.onCategories,
    this.onSettings,
  });

  final VoidCallback? onHome;
  final VoidCallback? onLive;
  final VoidCallback? onMovies;
  final VoidCallback? onSeries;
  final VoidCallback? onCategories;
  final VoidCallback? onSettings;

  @override
  Widget build(BuildContext context) {
    final items = [
      _SideMenuEntry(icon: Icons.home_rounded, onTap: onHome),
      _SideMenuEntry(icon: Icons.live_tv, onTap: onLive),
      _SideMenuEntry(icon: Icons.movie, onTap: onMovies),
      _SideMenuEntry(icon: Icons.video_library, onTap: onSeries),
      _SideMenuEntry(icon: Icons.category, onTap: onCategories),
      _SideMenuEntry(icon: Icons.settings, onTap: onSettings),
    ];

    return SafeArea(
      child: Container(
        width: 78,
        margin: const EdgeInsets.fromLTRB(14, 12, 0, 12),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.045),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          children: [
            const Icon(Icons.apps, color: Color(0xFFE50914), size: 28),
            const SizedBox(height: 14),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    for (final item in items)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 9),
                        child: _SideMenuButton(
                          icon: item.icon,
                          onTap: item.onTap,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SideMenuEntry {
  const _SideMenuEntry({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;
}

class _SideMenuButton extends StatefulWidget {
  const _SideMenuButton({
    required this.icon,
    this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  State<_SideMenuButton> createState() => _SideMenuButtonState();
}

class _SideMenuButtonState extends State<_SideMenuButton> {
  bool focused = false;

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      onFocusChange: (value) => setState(() => focused = value),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: focused
                ? const Color(0xFFE50914)
                : Colors.white.withOpacity(0.045),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: focused ? Colors.white70 : Colors.white10,
            ),
          ),
          child: Icon(widget.icon, color: Colors.white, size: 25),
        ),
      ),
    );
  }
}
