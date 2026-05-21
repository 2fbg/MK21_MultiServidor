import 'iptv_library_service.dart';

class DemoIptvLibraryService {
  static IptvLibrary build() {
    return const IptvLibraryService().buildFromM3u(_demoM3u);
  }
}

const _demoM3u = '''
#EXTM3U
#EXTINF:-1 tvg-id="globo" tvg-logo="https://example.com/globo.png" group-title="Canais | Brasil", Globo HD
http://demo.local/live/user/pass/globo.ts
#EXTINF:-1 tvg-id="sportv" tvg-logo="https://example.com/sportv.png" group-title="Canais | Esportes", SporTV HD
http://demo.local/live/user/pass/sportv.ts
#EXTINF:-1 tvg-id="espn" tvg-logo="https://example.com/espn.png" group-title="Canais | Esportes", ESPN Brasil
http://demo.local/live/user/pass/espn.ts
#EXTINF:-1 tvg-id="bandnews" tvg-logo="https://example.com/bandnews.png" group-title="Canais | Notícias", Band News
http://demo.local/live/user/pass/bandnews.ts
#EXTINF:-1 tvg-id="premiere" tvg-logo="https://example.com/premiere.png" group-title="Canais | Futebol", Premiere Clubes
http://demo.local/live/user/pass/premiere.ts

#EXTINF:-1 tvg-logo="https://example.com/movie1.png" group-title="Filmes | Lançamentos", Filme Ação Total 2026
http://demo.local/movie/user/pass/acao-total-2026.mp4
#EXTINF:-1 tvg-logo="https://example.com/movie2.png" group-title="Filmes | Drama", Caminho Final 2025
http://demo.local/movie/user/pass/caminho-final-2025.mp4
#EXTINF:-1 tvg-logo="https://example.com/movie3.png" group-title="Filmes | Infantil", Mundo Kids 2026
http://demo.local/movie/user/pass/mundo-kids-2026.mkv
#EXTINF:-1 tvg-logo="https://example.com/movie4.png" group-title="Filmes | Comédia", Comédia da Noite 2024
http://demo.local/movie/user/pass/comedia-noite-2024.mp4

#EXTINF:-1 tvg-logo="https://example.com/series1.png" group-title="Séries | Drama", Série Alpha S01E01
http://demo.local/series/user/pass/serie-alpha-s01e01.mp4
#EXTINF:-1 tvg-logo="https://example.com/series1.png" group-title="Séries | Drama", Série Alpha S01E02
http://demo.local/series/user/pass/serie-alpha-s01e02.mp4
#EXTINF:-1 tvg-logo="https://example.com/series2.png" group-title="Séries | Suspense", Mistério Azul 1x01
http://demo.local/series/user/pass/misterio-azul-1x01.mp4
#EXTINF:-1 tvg-logo="https://example.com/series2.png" group-title="Séries | Suspense", Mistério Azul 1x02
http://demo.local/series/user/pass/misterio-azul-1x02.mp4
''';
