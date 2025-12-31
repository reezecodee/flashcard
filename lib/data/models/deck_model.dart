class DeckModel {
  final int? id; // nullable karena saat insert belum punya ID (auto-increment)
  final String name;
  final int createdAt;

  DeckModel({this.id, required this.name, required this.createdAt});

  // konversi dari Map (database) ke Object dart
  factory DeckModel.fromMap(Map<String, dynamic> map) {
    return DeckModel(
      id: map['id'],
      name: map['name'],
      createdAt: map['created_at'],
    );
  }

  // konversi dari Object dart ke Map (database)
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'created_at': createdAt};
  }
}
