import 'package:flutter/material.dart';

class HomeSideMenu extends StatelessWidget {
  const HomeSideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    const items = [
      Icons.home_rounded,
      Icons.live_tv,
      Icons.movie,
      Icons.video_library,
      Icons.calendar_month,
      Icons.lock,
      Icons.settings,
    ];

    return Container(
      width: 88,
      margin: const EdgeInsets.fromLTRB(18, 18, 0, 18),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.045),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          const Icon(Icons.apps, color: Color(0xFFE50914), size: 30),
          const SizedBox(height: 24),
          for (final icon in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _SideMenuButton(icon: icon),
            ),
          const Spacer(),
          Icon(Icons.power_settings_new, color: Colors.white.withOpacity(0.55)),
        ],
      ),
    );
  }
}

class _SideMenuButton extends StatefulWidget {
  const _SideMenuButton({required this.icon});

  final IconData icon;

  @override
  State<_SideMenuButton> createState() => _SideMenuButtonState();
}

class _SideMenuButtonState extends State<_SideMenuButton> {
  bool focused = false;

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      onFocusChange: (value) => setState(() => focused = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: focused
              ? const Color(0xFFE50914)
              : Colors.white.withOpacity(0.045),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: focused ? Colors.white70 : Colors.white10),
        ),
        child: Icon(widget.icon, color: Colors.white),
      ),
    );
  }
}
