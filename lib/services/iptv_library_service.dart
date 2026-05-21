import '../models/content_type.dart';
import '../models/playlist_category.dart';
import '../models/playlist_item.dart';
import 'm3u_parser_service.dart';

class IptvLibrary {
  const IptvLibrary({
    required this.allItems,
    required this.liveItems,
    required this.movieItems,
    required this.seriesItems,
    required this.unknownItems,
    required this.categories,
  });

  final List<PlaylistItem> allItems;
  final List<PlaylistItem> liveItems;
  final List<PlaylistItem> movieItems;
  final List<PlaylistItem> seriesItems;
  final List<PlaylistItem> unknownItems;
  final List<PlaylistCategory> categories;

  bool get isEmpty => allItems.isEmpty;

  int get totalCount => allItems.length;
  int get liveCount => liveItems.length;
  int get movieCount => movieItems.length;
  int get seriesCount => seriesItems.length;
  int get unknownCount => unknownItems.length;

  /// Compatível com chamadas do tipo:
  /// library.currentYearHighlights()
  /// library.currentYearHighlights(items: someList, year: 2026)
  List<PlaylistItem> currentYearHighlights({
    List<PlaylistItem>? items,
    int? year,
    int limit = 20,
  }) {
    final selectedYear = year ?? DateTime.now().year;
    final sourceItems = items ?? movieItems;

    final highlights = sourceItems
        .where((item) => item.year == selectedYear)
        .take(limit)
        .toList();

    if (highlights.isNotEmpty) {
      return highlights;
    }

    return sourceItems.take(limit).toList();
  }
}

class IptvLibraryService {
  const IptvLibraryService({this.parser = const M3uParserService()});

  final M3uParserService parser;

  IptvLibrary buildFromM3u(String content) {
    final allItems = parser.parse(content);

    final liveItems = _sortItems(
      allItems.where((item) => item.type == ContentType.live).toList(),
    );

    final movieItems = _sortItems(
      allItems.where((item) => item.type == ContentType.movie).toList(),
    );

    final seriesItems = _sortItems(
      allItems.where((item) => item.type == ContentType.series).toList(),
    );

    final unknownItems = _sortItems(
      allItems.where((item) => item.type == ContentType.unknown).toList(),
    );

    final categories = _buildCategories(allItems);

    return IptvLibrary(
      allItems: allItems,
      liveItems: liveItems,
      movieItems: movieItems,
      seriesItems: seriesItems,
      unknownItems: unknownItems,
      categories: categories,
    );
  }

  List<PlaylistItem> filterByCategory({
    required List<PlaylistItem> items,
    required String categoryName,
  }) {
    final normalizedCategory = _normalize(categoryName);

    return items.where((item) {
      return _normalize(item.groupTitle ?? '') == normalizedCategory;
    }).toList();
  }

  List<PlaylistItem> search({
    required List<PlaylistItem> items,
    required String query,
  }) {
    final normalizedQuery = _normalize(query);

    if (normalizedQuery.isEmpty) {
      return items;
    }

    return items.where((item) {
      final name = _normalize(item.name);
      final group = _normalize(item.groupTitle ?? '');
      final tvgId = _normalize(item.tvgId ?? '');

      return name.contains(normalizedQuery) ||
          group.contains(normalizedQuery) ||
          tvgId.contains(normalizedQuery);
    }).toList();
  }

  /// Mantido caso alguma parte do app use o serviço diretamente.
  List<PlaylistItem> currentYearHighlights({
    required List<PlaylistItem> items,
    required int year,
  }) {
    return items.where((item) => item.year == year).toList();
  }

  List<PlaylistCategory> _buildCategories(List<PlaylistItem> items) {
    final byKey = <String, PlaylistCategory>{};

    for (final item in items) {
      final groupTitle = item.groupTitle?.trim();

      if (groupTitle == null || groupTitle.isEmpty) {
        continue;
      }

      final key = '${item.type.name}|${_normalize(groupTitle)}';

      byKey.putIfAbsent(
        key,
        () => PlaylistCategory(id: key, name: groupTitle, type: item.type),
      );
    }

    final categories = byKey.values.toList()
      ..sort((a, b) {
        final typeCompare = a.type.name.compareTo(b.type.name);
        if (typeCompare != 0) {
          return typeCompare;
        }

        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

    return categories;
  }

  List<PlaylistItem> _sortItems(List<PlaylistItem> items) {
    return [...items]..sort((a, b) {
      final groupCompare = (a.groupTitle ?? '').toLowerCase().compareTo(
            (b.groupTitle ?? '').toLowerCase(),
          );

      if (groupCompare != 0) {
        return groupCompare;
      }

      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
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
