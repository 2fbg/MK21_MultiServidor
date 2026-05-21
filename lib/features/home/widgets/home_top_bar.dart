import 'package:flutter/material.dart';

import '../../../models/server_profile.dart';

class HomeTopBar extends StatelessWidget {
  const HomeTopBar({
    super.key,
    required this.selectedServerId,
    required this.onServerChanged,
    this.onSearch,
    this.onSettings,
  });

  final String selectedServerId;
  final ValueChanged<String> onServerChanged;
  final VoidCallback? onSearch;
  final VoidCallback? onSettings;

  @override
  Widget build(BuildContext context) {
    final selected = ServerProfiles.firstById(selectedServerId);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 8),
      child: Row(
        children: [
          const Text(
            'MK21',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFFE50914),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'MultiServidor',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white.withOpacity(0.86),
            ),
          ),
          const Spacer(),
          IconButton.filledTonal(
            onPressed: onSearch,
            icon: const Icon(Icons.search),
          ),
          const SizedBox(width: 10),
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.075),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: selected.color.withOpacity(0.55)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selected.id,
                dropdownColor: const Color(0xFF101827),
                borderRadius: BorderRadius.circular(18),
                iconEnabledColor: Colors.white,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
                items: ServerProfiles.all.map((profile) {
                  return DropdownMenuItem<String>(
                    value: profile.id,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: profile.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(profile.name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    onServerChanged(value);
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton.filledTonal(
            onPressed: onSettings,
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
    );
  }
}
