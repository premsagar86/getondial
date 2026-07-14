class BannerModel {
  final int id;
  final String imageUrl;
  final String type; // store|item|link (backend-specific)
  final String data; // store_id or item_id or url

  const BannerModel({
    required this.id,
    required this.imageUrl,
    required this.type,
    required this.data,
  });
}

