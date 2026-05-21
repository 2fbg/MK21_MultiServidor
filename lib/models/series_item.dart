import 'episode_item.dart';

class SeriesItem {
  const SeriesItem({
    required this.id,
    required this.title,
    this.posterUrl,
    this.category,
    this.year,
    this.episodes = const [],
    this.isFavorite = false,
  });

  final String id;
  final String title;
  final String? posterUrl;
  final String? category;
  final int? year;
  final List<EpisodeItem> episodes;
  final bool isFavorite;
}
