import 'package:flutter/material.dart';
import '../../../models/server_profile.dart';

class HomeTopBar extends StatelessWidget {
  const HomeTopBar({
    super.key,
    this.selectedServerId = 'mk21',
    this.onServerChanged,
    this.onRefresh,
  });

  final String selectedServerId;
  final ValueChanged<String>? onServerChanged;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final profiles = ServerProfiles.all;
    final selected = profiles.any((p) => p.id == selectedServerId)
        ? profiles.firstWhere((p) => p.id == selectedServerId)
        : profiles.first;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Row(
        children: [
          const Text(
            'MK21',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFFE50914),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'MultiServidor',
            style: TextStyle(fontSize: 16),
          ),
          const Spacer(),

          /// COMBO SERVIDOR
          DropdownButton<String>(
            value: selected.id,
            dropdownColor: const Color(0xFF121212),
            items: profiles.map((profile) {
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

          /// REFRESH LISTA
          IconButton(
            tooltip: 'Atualizar lista',
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}
