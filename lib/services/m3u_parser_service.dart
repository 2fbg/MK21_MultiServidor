import '../models/content_type.dart';
import '../models/playlist_item.dart';
import 'playlist_classifier.dart';

class M3uParserService {
  const M3uParserService({this.classifier = const PlaylistClassifier()});

  final PlaylistClassifier classifier;

  List<PlaylistItem> parse(String content) {
    final lines = content
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    final items = <PlaylistItem>[];

    String? pendingName;
    String? pendingLogo;
    String? pendingGroup;
    String? pendingTvgId;

    for (final line in lines) {
      if (line.startsWith('#EXTINF')) {
        pendingName = _extractName(line);
        pendingLogo = _extractAttribute(line, 'tvg-logo');
        pendingGroup = _extractAttribute(line, 'group-title');
        pendingTvgId = _extractAttribute(line, 'tvg-id');
        continue;
      }

      if (line.startsWith('#')) {
        continue;
      }

      final url = line;
      final name = pendingName ?? _fallbackNameFromUrl(url);
      final type = classifier.classify(
        name: name,
        url: url,
        groupTitle: pendingGroup,
      );

      items.add(
        PlaylistItem(
          id: _stableId(name, url),
          name: name,
          url: url,
          type: type,
          logoUrl: pendingLogo,
          groupTitle: pendingGroup,
          tvgId: pendingTvgId,
          year: _extractYear(name),
          seasonNumber: _extractSeasonNumber(name),
          episodeNumber: _extractEpisodeNumber(name),
        ),
      );

      pendingName = null;
      pendingLogo = null;
      pendingGroup = null;
      pendingTvgId = null;
    }

    return items;
  }

  List<PlaylistItem> parseLive(String content) {
    return parse(
      content,
    ).where((item) => item.type == ContentType.live).toList();
  }

  List<PlaylistItem> parseMovies(String content) {
    return parse(
      content,
    ).where((item) => item.type == ContentType.movie).toList();
  }

  List<PlaylistItem> parseSeries(String content) {
    return parse(
      content,
    ).where((item) => item.type == ContentType.series).toList();
  }

  String? _extractAttribute(String line, String attribute) {
    final pattern = RegExp('$attribute="([^"]*)"');
    final match = pattern.firstMatch(line);
    return match?.group(1)?.trim();
  }

  String _extractName(String line) {
    final commaIndex = line.lastIndexOf(',');
    if (commaIndex == -1 || commaIndex == line.length - 1) {
      return 'Sem nome';
    }

    return line.substring(commaIndex + 1).trim();
  }

  String _fallbackNameFromUrl(String url) {
    final cleanUrl = url.split('?').first;
    final segments = cleanUrl
        .split('/')
        .where((part) => part.isNotEmpty)
        .toList();

    if (segments.isEmpty) {
      return 'Sem nome';
    }

    final last = segments.last;
    return last
        .replaceAll('.m3u8', '')
        .replaceAll('.ts', '')
        .replaceAll('.mp4', '')
        .replaceAll('.mkv', '')
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .trim();
  }

  int? _extractYear(String name) {
    final match = RegExp(r'\b(19|20)\d{2}\b').firstMatch(name);
    if (match == null) {
      return null;
    }

    return int.tryParse(match.group(0)!);
  }

  int? _extractSeasonNumber(String name) {
    final normalized = name.toLowerCase();

    final sPattern = RegExp(r's(\d{1,2})\s*e\d{1,3}');
    final sMatch = sPattern.firstMatch(normalized);
    if (sMatch != null) {
      return int.tryParse(sMatch.group(1)!);
    }

    final xPattern = RegExp(r'\b(\d{1,2})x\d{1,3}\b');
    final xMatch = xPattern.firstMatch(normalized);
    if (xMatch != null) {
      return int.tryParse(xMatch.group(1)!);
    }

    return null;
  }

  int? _extractEpisodeNumber(String name) {
    final normalized = name.toLowerCase();

    final sPattern = RegExp(r's\d{1,2}\s*e(\d{1,3})');
    final sMatch = sPattern.firstMatch(normalized);
    if (sMatch != null) {
      return int.tryParse(sMatch.group(1)!);
    }

    final xPattern = RegExp(r'\b\d{1,2}x(\d{1,3})\b');
    final xMatch = xPattern.firstMatch(normalized);
    if (xMatch != null) {
      return int.tryParse(xMatch.group(1)!);
    }

    return null;
  }

  String _stableId(String name, String url) {
    return '${name.trim()}|${url.trim()}'.hashCode.toString();
  }
}
