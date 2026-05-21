import 'package:shared_preferences/shared_preferences.dart';

import '../models/server_config.dart';

class ServerConfigService {
  const ServerConfigService();

  static const _serverNameKey = 'server_config.serverName';
  static const _playlistUrlKey = 'server_config.playlistUrl';
  static const _isManualUrlKey = 'server_config.isManualUrl';
  static const _profileIdKey = 'server_config.profileId';
  static const _usernameKey = 'server_config.username';
  static const _passwordKey = 'server_config.password';
  static const _userAgentKey = 'server_config.userAgent';

  Future<ServerConfig?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final playlistUrl = prefs.getString(_playlistUrlKey);

    if (playlistUrl == null || playlistUrl.trim().isEmpty) {
      return null;
    }

    return ServerConfig(
      serverName: prefs.getString(_serverNameKey) ?? 'Servidor',
      playlistUrl: playlistUrl,
      isManualUrl: prefs.getBool(_isManualUrlKey) ?? false,
      profileId: prefs.getString(_profileIdKey),
      username: prefs.getString(_usernameKey),
      password: prefs.getString(_passwordKey),
      userAgent: prefs.getString(_userAgentKey) ?? 'MK21-MultiServidor/1.0',
    );
  }

  Future<void> save(ServerConfig config) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_serverNameKey, config.serverName);
    await prefs.setString(_playlistUrlKey, config.playlistUrl);
    await prefs.setBool(_isManualUrlKey, config.isManualUrl);
    await prefs.setString(_profileIdKey, config.profileId ?? '');
    await prefs.setString(_usernameKey, config.username ?? '');
    await prefs.setString(_passwordKey, config.password ?? '');
    await prefs.setString(_userAgentKey, config.userAgent);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_serverNameKey);
    await prefs.remove(_playlistUrlKey);
    await prefs.remove(_isManualUrlKey);
    await prefs.remove(_profileIdKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_passwordKey);
    await prefs.remove(_userAgentKey);
  }
}
