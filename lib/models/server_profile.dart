import 'package:flutter/material.dart';

class ServerProfile {
  const ServerProfile({
    required this.id,
    required this.name,
    required this.baseUrl,
    required this.color,
  });

  final String id;
  final String name;
  final String baseUrl;
  final Color color;

  String buildM3uUrl({required String username, required String password}) {
    final encodedUser = Uri.encodeQueryComponent(username.trim());
    final encodedPassword = Uri.encodeQueryComponent(password.trim());

    return '$baseUrl/get.php?username=$encodedUser&password=$encodedPassword&type=m3u_plus&output=mpegts';
  }
}

class ServerProfiles {
  static const all = [
    ServerProfile(
      id: 'mk21',
      name: 'MK21 TV',
      baseUrl: 'http://appsmk.org',
      color: Color(0xFF7C3AED),
    ),
    ServerProfile(
      id: 'vlog',
      name: 'VLOG',
      baseUrl: 'http://vlogmk.de',
      color: Color(0xFF10B981),
    ),
    ServerProfile(
      id: 'lubtv',
      name: 'LUB TV',
      baseUrl: 'http://triimundial.shop',
      color: Color(0xFFE5E7EB),
    ),
    ServerProfile(
      id: 'cinelon21',
      name: 'CINELON21',
      baseUrl: 'http://infinixparcerias.site',
      color: Color(0xFFE50914),
    ),
    ServerProfile(
      id: 'tannix',
      name: 'TANNIX',
      baseUrl: 'http://unituf.online',
      color: Color(0xFFF97316),
    ),
    ServerProfile(
      id: 'cb6000',
      name: 'CB6000',
      baseUrl: 'http://cb6.fun',
      color: Color(0xFF00A3FF),
    ),
  ];

  static ServerProfile firstById(String id) {
    return all.firstWhere(
      (profile) => profile.id == id,
      orElse: () => all.first,
    );
  }
}
