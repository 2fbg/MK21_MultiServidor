import '../models/content_type.dart';
import '../models/playlist_category.dart';
import '../models/playlist_item.dart';
import 'iptv_library_service.dart';

class DemoIptvLibraryService {
  const DemoIptvLibraryService._();

  static IptvLibrary build() {
    final items = <PlaylistItem>[
      const PlaylistItem(
        id: 'live-1',
        name: 'Canal Brasil HD',
        url: 'https://example.com/live/canal-brasil.m3u8',
        type: ContentType.live,
        groupTitle: 'TV Aberta',
      ),
      const PlaylistItem(
        id: 'live-2',
        name: 'Esporte Total',
        url: 'https://example.com/live/esporte-total.m3u8',
        type: ContentType.live,
        groupTitle: 'Esportes',
      ),
      const PlaylistItem(
        id: 'movie-1',
        name: 'Ação Máxima 2026',
        url: 'https://example.com/movies/acao-maxima-2026.mp4',
        type: ContentType.movie,
        groupTitle: 'Lançamentos',
        year: 2026,
      ),
      const PlaylistItem(
        id: 'movie-2',
        name: 'Noite de Mistério 2025',
        url: 'https://example.com/movies/noite-misterio-2025.mp4',
        type: ContentType.movie,
        groupTitle: 'Suspense',
        year: 2025,
      ),
      const PlaylistItem(
        id: 'series-1',
        name: 'Cidade Oculta S01E01',
        url: 'https://example.com/series/cidade-oculta-s01e01.mp4',
        type: ContentType.series,
        groupTitle: 'Drama',
        seasonNumber: 1,
        episodeNumber: 1,
      ),
      const PlaylistItem(
        id: 'series-2',
        name: 'Cidade Oculta S01E02',
        url: 'https://example.com/series/cidade-oculta-s01e02.mp4',
        type: ContentType.series,
        groupTitle: 'Drama',
        seasonNumber: 1,
        episodeNumber: 2,
      ),
    ];

    return IptvLibrary(
      allItems: items,
      liveItems: items.where((item) => item.type == ContentType.live).toList(),
      movieItems: items.where((item) => item.type == ContentType.movie).toList(),
      seriesItems: items.where((item) => item.type == ContentType.series).toList(),
      unknownItems: items.where((item) => item.type == ContentType.unknown).toList(),
      categories: const [
        PlaylistCategory(id: 'live_tv_aberta', name: 'TV Aberta', type: ContentType.live),
        PlaylistCategory(id: 'live_esportes', name: 'Esportes', type: ContentType.live),
        PlaylistCategory(id: 'movie_lancamentos', name: 'Lançamentos', type: ContentType.movie),
        PlaylistCategory(id: 'movie_suspense', name: 'Suspense', type: ContentType.movie),
        PlaylistCategory(id: 'series_drama', name: 'Drama', type: ContentType.series),
      ],
    );
  }
}
