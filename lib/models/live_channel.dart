class LiveChannel {
  const LiveChannel({
    required this.id,
    required this.name,
    required this.streamUrl,
    this.logoUrl,
    this.category,
    this.tvgId,
    this.isFavorite = false,
  });

  final String id;
  final String name;
  final String streamUrl;
  final String? logoUrl;
  final String? category;
  final String? tvgId;
  final bool isFavorite;
}
