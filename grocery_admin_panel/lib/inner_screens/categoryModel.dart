class Category {
  final String id;
  final String name;
  final String imagePath;
  final String type; // 'food' or 'liquor'

  Category({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.type,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      imagePath: map['imagePath'],
      type: map['type'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imagePath': imagePath,
      'type': type,
    };
  }
}