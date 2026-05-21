class ServerConfig {
  const ServerConfig({
    required this.serverName,
    required this.playlistUrl,
    required this.isManualUrl,
    this.profileId,
    this.username,
    this.password,
    this.userAgent = 'MK21-MultiServidor/1.0',
  });

  final String serverName;
  final String playlistUrl;
  final bool isManualUrl;
  final String? profileId;
  final String? username;
  final String? password;
  final String userAgent;

  Map<String, String> toMap() {
    return {
      'serverName': serverName,
      'playlistUrl': playlistUrl,
      'isManualUrl': isManualUrl.toString(),
      'profileId': profileId ?? '',
      'username': username ?? '',
      'password': password ?? '',
      'userAgent': userAgent,
    };
  }

  static ServerConfig fromMap(Map<String, String> map) {
    return ServerConfig(
      serverName: map['serverName'] ?? 'Servidor',
      playlistUrl: map['playlistUrl'] ?? '',
      isManualUrl: (map['isManualUrl'] ?? 'false') == 'true',
      profileId: _emptyToNull(map['profileId']),
      username: _emptyToNull(map['username']),
      password: _emptyToNull(map['password']),
      userAgent: map['userAgent'] ?? 'MK21-MultiServidor/1.0',
    );
  }

  static String? _emptyToNull(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    return value;
  }
}
