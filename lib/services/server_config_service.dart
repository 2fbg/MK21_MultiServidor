import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/server_config.dart';

class ServerCredentials {
  const ServerCredentials({
    required this.username,
    required this.password,
  });

  final String username;
  final String password;

  bool get isComplete => username.trim().isNotEmpty && password.trim().isNotEmpty;
}

class ServerEntry {
  const ServerEntry({
    required this.id,
    required this.name,
    required this.playlistUrl,
    required this.isManual,
    this.profileId,
    this.userAgent = 'MK21-MultiServidor/1.0',
  });

  final String id;
  final String name;
  final String playlistUrl;
  final bool isManual;
  final String? profileId;
  final String userAgent;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'playlistUrl': playlistUrl,
      'isManual': isManual,
      'profileId': profileId,
      'userAgent': userAgent,
    };
  }

  factory ServerEntry.fromMap(Map<String, dynamic> map) {
    return ServerEntry(
      id: (map['id'] ?? '').toString(),
      name: (map['name'] ?? 'Servidor').toString(),
      playlistUrl: (map['playlistUrl'] ?? '').toString(),
      isManual: map['isManual'] == true,
      profileId: _nullableString(map['profileId']),
      userAgent: (map['userAgent'] ?? 'MK21-MultiServidor/1.0').toString(),
    );
  }

  static String? _nullableString(Object? value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }
}

class PlaylistCacheData {
  const PlaylistCacheData({
    required this.content,
    required this.savedAt,
    required this.serverId,
    required this.serverName,
  });

  final String content;
  final DateTime savedAt;
  final String serverId;
  final String serverName;

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'savedAt': savedAt.toIso8601String(),
      'serverId': serverId,
      'serverName': serverName,
    };
  }

  factory PlaylistCacheData.fromMap(Map<String, dynamic> map) {
    return PlaylistCacheData(
      content: (map['content'] ?? '').toString(),
      savedAt: DateTime.tryParse((map['savedAt'] ?? '').toString()) ?? DateTime.fromMillisecondsSinceEpoch(0),
      serverId: (map['serverId'] ?? '').toString(),
      serverName: (map['serverName'] ?? 'Servidor').toString(),
    );
  }
}

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
  static const _serverEntriesKey = 'server_config.entries';
  static const _selectedServerIdKey = 'server_config.selectedServerId';
  static const _playlistCachePrefix = 'server_config.cache.';

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

  Future<List<ServerEntry>> loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_serverEntriesKey);
    if (raw == null || raw.trim().isEmpty) {
      final legacy = await load();
      if (legacy == null) return const [];
      return [
        ServerEntry(
          id: legacy.profileId ?? 'legacy_default',
          name: legacy.serverName,
          playlistUrl: legacy.playlistUrl,
          isManual: legacy.isManualUrl,
          profileId: legacy.profileId,
          userAgent: legacy.userAgent,
        ),
      ];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map>()
          .map((item) => ServerEntry.fromMap(item.cast<String, dynamic>()))
          .where((item) => item.id.trim().isNotEmpty && item.playlistUrl.trim().isNotEmpty)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveEntries(List<ServerEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _serverEntriesKey,
      jsonEncode(entries.map((entry) => entry.toMap()).toList()),
    );
  }

  Future<void> upsertEntry(ServerEntry entry) async {
    final entries = await loadEntries();
    final index = entries.indexWhere((item) => item.id == entry.id);
    if (index >= 0) {
      entries[index] = entry;
    } else {
      entries.add(entry);
    }
    await saveEntries(entries);
    await setSelectedServerId(entry.id);

    await save(
      ServerConfig(
        serverName: entry.name,
        playlistUrl: entry.playlistUrl,
        isManualUrl: entry.isManual,
        profileId: entry.profileId,
        userAgent: entry.userAgent,
      ),
    );
  }

  Future<void> deleteEntry(String id) async {
    final entries = await loadEntries();
    entries.removeWhere((item) => item.id == id);
    await saveEntries(entries);

    final prefs = await SharedPreferences.getInstance();
    final selectedId = prefs.getString(_selectedServerIdKey);
    if (selectedId == id) {
      if (entries.isEmpty) {
        await prefs.remove(_selectedServerIdKey);
      } else {
        await prefs.setString(_selectedServerIdKey, entries.first.id);
      }
    }

    await prefs.remove('$_playlistCachePrefix$id');
  }

  Future<String?> loadSelectedServerId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedServerIdKey);
  }

  Future<void> setSelectedServerId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedServerIdKey, id);
  }

  Future<ServerEntry?> loadSelectedEntry() async {
    final entries = await loadEntries();
    if (entries.isEmpty) {
      final legacy = await load();
      if (legacy == null) return null;
      return ServerEntry(
        id: legacy.profileId ?? 'legacy_default',
        name: legacy.serverName,
        playlistUrl: legacy.playlistUrl,
        isManual: legacy.isManualUrl,
        profileId: legacy.profileId,
        userAgent: legacy.userAgent,
      );
    }

    final selectedId = await loadSelectedServerId();
    if (selectedId == null || selectedId.trim().isEmpty) {
      await setSelectedServerId(entries.first.id);
      return entries.first;
    }

    for (final entry in entries) {
      if (entry.id == selectedId) return entry;
    }
    return entries.first;
  }

  Future<void> saveCredentials({
    required String username,
    required String password,
  }) async {
    await _storage.write(key: _usernameKey, value: username.trim());
    await _storage.write(key: _passwordKey, value: password.trim());
  }

  Future<ServerCredentials> loadCredentials() async {
    final username = await _storage.read(key: _usernameKey) ?? '';
    final password = await _storage.read(key: _passwordKey) ?? '';
    return ServerCredentials(username: username, password: password);
  }

  Future<void> savePlaylistCache(PlaylistCacheData cache) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_playlistCachePrefix${cache.serverId}', jsonEncode(cache.toMap()));
  }

  Future<PlaylistCacheData?> loadPlaylistCache(String serverId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_playlistCachePrefix$serverId');
    if (raw == null || raw.trim().isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return PlaylistCacheData.fromMap(decoded.cast<String, dynamic>());
    } catch (_) {
      return null;
    }
  }

    Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await loadEntries();
    await prefs.remove(_serverNameKey);
    await prefs.remove(_playlistUrlKey);
    await prefs.remove(_isManualUrlKey);
    await prefs.remove(_profileIdKey);
    await prefs.remove(_userAgentKey);
    await prefs.remove(_serverEntriesKey);
    await prefs.remove(_selectedServerIdKey);
    for (final entry in entries) {
      await prefs.remove('$_playlistCachePrefix${entry.id}');
    }
    await _storage.delete(key: _usernameKey);
    await _storage.delete(key: _passwordKey);
  }

  String? _normalizeNullable(String? value) {
    if (value == null) return null;
    final normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }
}
