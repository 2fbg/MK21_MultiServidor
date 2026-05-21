import 'package:flutter/material.dart';

import '../../../models/server_profile.dart';

class HomeTopBar extends StatelessWidget {
  const HomeTopBar({
    super.key,
    this.selectedServerId = 'mk21',
    this.onServerChanged,
    this.onSearch,
    this.onSettings,
  });

  final String selectedServerId;
  final ValueChanged<String>? onServerChanged;
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
          DropdownButton<String>(
            value: selected.id,
            dropdownColor: const Color(0xFF101827),
            items: ServerProfiles.all.map((profile) {
              return DropdownMenuItem<String>(
                value: profile.id,
                child: Text(profile.name),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null && onServerChanged != null) {
                onServerChanged!(value);
              }
            },
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
