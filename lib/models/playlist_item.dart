import 'content_type.dart';

class PlaylistItem {
  const PlaylistItem({
    required this.id,
    required this.name,
    required this.url,
    required this.type,
    this.logoUrl,
    this.groupTitle,
    this.tvgId,
    this.year,
    this.seasonNumber,
    this.episodeNumber,
  });

  final String id;
  final String name;
  final String url;
  final ContentType type;
  final String? logoUrl;
  final String? groupTitle;
  final String? tvgId;
  final int? year;
  final int? seasonNumber;
  final int? episodeNumber;

  PlaylistItem copyWith({
    String? id,
    String? name,
    String? url,
    ContentType? type,
    String? logoUrl,
    String? groupTitle,
    String? tvgId,
    int? year,
    int? seasonNumber,
    int? episodeNumber,
  }) {
    return PlaylistItem(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      type: type ?? this.type,
      logoUrl: logoUrl ?? this.logoUrl,
      groupTitle: groupTitle ?? this.groupTitle,
      tvgId: tvgId ?? this.tvgId,
      year: year ?? this.year,
      seasonNumber: seasonNumber ?? this.seasonNumber,
      episodeNumber: episodeNumber ?? this.episodeNumber,
    );
  }
}
