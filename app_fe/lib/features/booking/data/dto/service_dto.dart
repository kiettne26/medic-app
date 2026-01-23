/// DTO cho Medical Service
class ServiceDto {
  final String id;
  final String name;
  final String? description;
  final double price;
  final int durationMinutes;
  final String? category;
  final String? imageUrl;

  ServiceDto({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.durationMinutes,
    this.category,
    this.imageUrl,
  });

  factory ServiceDto.fromJson(Map<String, dynamic> json) {
    return ServiceDto(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      price: (json['price'] ?? 0).toDouble(),
      durationMinutes: json['durationMinutes'] ?? 0,
      category: json['category'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'durationMinutes': durationMinutes,
      'category': category,
      'imageUrl': imageUrl,
    };
  }
}
