class Product {
  int? id;
  String name;
  double price;
  int stock;
  String? imageUrl;

  Product({
    this.id,
    required this.name,
    required this.price,
    required this.stock,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'stock': stock,
      'imageUrl': imageUrl,
    };
  }
}
