import 'package:flutter/material.dart';

import '../features/home/home_page.dart';
import '../features/server_config/server_config_page.dart';
import '../services/server_config_service.dart';

class StartupGate extends StatelessWidget {
  const StartupGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: const ServerConfigService().load(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final config = snapshot.data;

        if (config == null) {
          return const ServerConfigPage();
        }

        return const HomePage();
      },
    );
  }
}
