class MovieItem {
  const MovieItem({
    required this.id,
    required this.title,
    required this.streamUrl,
    this.posterUrl,
    this.category,
    this.year,
    this.durationMinutes,
    this.isFavorite = false,
    this.lastPositionSeconds = 0,
  });

  final String id;
  final String title;
  final String streamUrl;
  final String? posterUrl;
  final String? category;
  final int? year;
  final int? durationMinutes;
  final bool isFavorite;
  final int lastPositionSeconds;
}
