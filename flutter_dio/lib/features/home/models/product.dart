class ProductModel {
  final int id;
  final String title;
  final String description;
  final double price;
  final int quantity;
  final String? image;

  ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.quantity,
    this.image,
  });
   factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      quantity: 1, // FakeStore không có quantity
      image: json['image'],
    );
  }

  // factory ProductModel.fromJson(Map<String, dynamic> json) {
  //   return ProductModel(
  //     id: json['id'] as int,
  //     title: json['title'] as String,
  //     description: json['description'] as String,
  //     price: (json['price'] is int ? (json['price'] as int).toDouble() : json['price'] as double),
  //     quantity: json['quantity'] is int
  //         ? json['quantity'] as int
  //         : int.tryParse(json['quantity']?.toString() ?? '') ?? 0,
  //     image: json['image'] as String?,
  //   );
  // }

  // static String? _normalizeImageUrl(String? url) {
  //   if (url == null || url.trim().isEmpty) return null;
  //   final trimmed = url.trim();
  //   final parsed = Uri.tryParse(trimmed);
  //   if (parsed != null && parsed.hasScheme) return trimmed;
  //   final base = ApiConstants.baseUrl.replaceAll(RegExp(r'/+$'), '').replaceAll(RegExp(r'/+$'), '');
  //   final path = trimmed.replaceAll(RegExp(r'^/+'), '');
  //   return '$base/$path';
  // }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'quantity': quantity,
      'image': image,
    };
  }
}