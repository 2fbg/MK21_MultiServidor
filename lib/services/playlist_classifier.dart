import '../models/content_type.dart';
import '../models/playlist_item.dart';

class PlaylistClassifier {
  const PlaylistClassifier();

  ContentType classify({
    required String name,
    required String url,
    String? groupTitle,
  }) {
    final normalizedName = _normalize(name);
    final normalizedUrl = _normalize(url);
    final normalizedGroup = _normalize(groupTitle ?? '');

    if (_looksLikeSeries(normalizedName, normalizedUrl, normalizedGroup)) {
      return ContentType.series;
    }

    if (_looksLikeMovie(normalizedName, normalizedUrl, normalizedGroup)) {
      return ContentType.movie;
    }

    if (_looksLikeLive(normalizedName, normalizedUrl, normalizedGroup)) {
      return ContentType.live;
    }

    return ContentType.unknown;
  }

  List<PlaylistItem> onlyLive(List<PlaylistItem> items) {
    return items.where((item) => item.type == ContentType.live).toList();
  }

  List<PlaylistItem> onlyMovies(List<PlaylistItem> items) {
    return items.where((item) => item.type == ContentType.movie).toList();
  }

  List<PlaylistItem> onlySeries(List<PlaylistItem> items) {
    return items.where((item) => item.type == ContentType.series).toList();
  }

  PlaylistItem classifyItem(PlaylistItem item) {
    return item.copyWith(
      type: classify(
        name: item.name,
        url: item.url,
        groupTitle: item.groupTitle,
      ),
    );
  }

  List<PlaylistItem> classifyAll(List<PlaylistItem> items) {
    return items.map(classifyItem).toList();
  }

  bool _looksLikeSeries(String name, String url, String group) {
    final hasEpisodePattern =
        RegExp(r's\d{1,2}\s*e\d{1,3}').hasMatch(name) ||
        RegExp(r'\b\d{1,2}x\d{1,3}\b').hasMatch(name);

    return hasEpisodePattern ||
        group.contains('serie') ||
        group.contains('series') ||
        group.contains('temporada') ||
        url.contains('/series/') ||
        url.contains('/serie/');
  }

  bool _looksLikeMovie(String name, String url, String group) {
    final hasYear = RegExp(r'\b(19|20)\d{2}\b').hasMatch(name);
    final hasMovieExtension =
        url.endsWith('.mp4') ||
        url.endsWith('.mkv') ||
        url.endsWith('.avi') ||
        url.endsWith('.mov') ||
        url.endsWith('.m4v');

    return group.contains('filme') ||
        group.contains('filmes') ||
        group.contains('movie') ||
        group.contains('movies') ||
        group.contains('vod') ||
        url.contains('/movie/') ||
        url.contains('/movies/') ||
        hasMovieExtension ||
        hasYear;
  }

  bool _looksLikeLive(String name, String url, String group) {
    return group.contains('live') ||
        group.contains('ao vivo') ||
        group.contains('canais') ||
        group.contains('tv') ||
        url.endsWith('.m3u8') ||
        url.endsWith('.ts') ||
        url.contains('/live/');
  }

  String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('à', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('â', 'a')
        .replaceAll('é', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ç', 'c')
        .trim();
  }
}
