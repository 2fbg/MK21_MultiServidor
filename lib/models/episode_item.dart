class EpisodeItem {
  const EpisodeItem({
    required this.id,
    required this.title,
    required this.streamUrl,
    required this.seasonNumber,
    required this.episodeNumber,
    this.posterUrl,
    this.durationMinutes,
    this.lastPositionSeconds = 0,
  });

  final String id;
  final String title;
  final String streamUrl;
  final int seasonNumber;
  final int episodeNumber;
  final String? posterUrl;
  final int? durationMinutes;
  final int lastPositionSeconds;
}
