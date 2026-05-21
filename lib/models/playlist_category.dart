import 'content_type.dart';

class PlaylistCategory {
  const PlaylistCategory({
    required this.id,
    required this.name,
    required this.type,
  });

  final String id;
  final String name;
  final ContentType type;
}
