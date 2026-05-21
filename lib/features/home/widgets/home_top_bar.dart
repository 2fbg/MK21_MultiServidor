import 'package:flutter/material.dart';

class HomeTopBar extends StatelessWidget {
  const HomeTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 22, 28, 0),
      child: Row(
        children: [
          const Text(
            'MK21',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Color(0xFFE50914),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'MultiServidor',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white.withOpacity(0.88),
            ),
          ),
          const Spacer(),
          IconButton.filledTonal(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
          const SizedBox(width: 10),
          IconButton.filledTonal(
            onPressed: () {},
            icon: const Icon(Icons.favorite_border),
          ),
          const SizedBox(width: 10),
          IconButton.filledTonal(
            onPressed: () {},
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
    );
  }
}
