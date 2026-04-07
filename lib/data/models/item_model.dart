import 'category_model.dart';

class ItemModel {
  final int id;
  final String name;
  final double price;
  final String? description;
  final String? image;
  final List<CategoryModel> categories;

  const ItemModel({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    this.image,
    this.categories = const [],
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    double parsedPrice = 0.0;
    final raw = json['price'];
    if (raw is num) {
      parsedPrice = raw.toDouble();
    } else if (raw is String) {
      parsedPrice = double.tryParse(raw) ?? 0.0;
    }

    final cats = (json['categories'] as List? ?? [])
        .map((c) => CategoryModel.fromJson(c as Map<String, dynamic>))
        .toList();

    return ItemModel(
      id: json['id'] as int,
      name: json['name'] as String,
      price: parsedPrice,
      description: json['description'] as String?,
      image: json['image'] as String?,
      categories: cats,
    );
  }

  String get categoryNames =>
      categories.map((c) => c.name).join(', ');
}
