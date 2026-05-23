import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/server_config.dart';

class ServerConfigService {
  const ServerConfigService();

  static const _storage = FlutterSecureStorage();
  static const _serverNameKey = 'server_config.serverName';
  static const _playlistUrlKey = 'server_config.playlistUrl';
  static const _isManualUrlKey = 'server_config.isManualUrl';
  static const _profileIdKey = 'server_config.profileId';
  static const _userAgentKey = 'server_config.userAgent';
  static const _usernameKey = 'server_config.username';
  static const _passwordKey = 'server_config.password';

  Future<ServerConfig?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final playlistUrl = prefs.getString(_playlistUrlKey);

    if (playlistUrl == null || playlistUrl.trim().isEmpty) {
      return null;
    }

    final username = await _storage.read(key: _usernameKey);
    final password = await _storage.read(key: _passwordKey);

    return ServerConfig(
      serverName: prefs.getString(_serverNameKey) ?? 'Servidor',
      playlistUrl: playlistUrl,
      isManualUrl: prefs.getBool(_isManualUrlKey) ?? false,
      profileId: _normalizeNullable(prefs.getString(_profileIdKey)),
      username: _normalizeNullable(username),
      password: _normalizeNullable(password),
      userAgent: prefs.getString(_userAgentKey) ?? 'MK21-MultiServidor/1.0',
    );
  }

  Future<void> save(ServerConfig config) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_serverNameKey, config.serverName);
    await prefs.setString(_playlistUrlKey, config.playlistUrl);
    await prefs.setBool(_isManualUrlKey, config.isManualUrl);
    await prefs.setString(_profileIdKey, config.profileId ?? '');
    await prefs.setString(_userAgentKey, config.userAgent);

    if (config.username != null && config.username!.trim().isNotEmpty) {
      await _storage.write(key: _usernameKey, value: config.username!.trim());
    } else {
      await _storage.delete(key: _usernameKey);
    }

    if (config.password != null && config.password!.trim().isNotEmpty) {
      await _storage.write(key: _passwordKey, value: config.password!.trim());
    } else {
      await _storage.delete(key: _passwordKey);
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_serverNameKey);
    await prefs.remove(_playlistUrlKey);
    await prefs.remove(_isManualUrlKey);
    await prefs.remove(_profileIdKey);
    await prefs.remove(_userAgentKey);
    await _storage.delete(key: _usernameKey);
    await _storage.delete(key: _passwordKey);
  }

  String? _normalizeNullable(String? value) {
    if (value == null) return null;
    final normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }
}
