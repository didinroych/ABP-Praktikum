class Drink {
  final String id;
  final String name;
  final String description;
  final int price;
  final String rating;
  final String createdAt;
  final String updatedAt;

  Drink({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.rating,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Drink.fromJson(Map<String, dynamic> json) {
    return Drink(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: json['price'] ?? 0,
      rating: json['rating']?.toString() ?? '0.00',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'rating': double.tryParse(rating) ?? 1.0,
    };
  }

  Drink copyWith({
    String? id,
    String? name,
    String? description,
    int? price,
    String? rating,
    String? createdAt,
    String? updatedAt,
  }) {
    return Drink(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}