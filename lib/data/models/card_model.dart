class CardModel {
  final int? id;
  final int deckId; // foreign key ke deck
  final String front;
  final String back;

  // kolom khusus algoritma SRS (SuperMemo-2)
  final int interval; // jeda hari sampai muncul lagi
  final double easeFactor; // tingkat kemudahan (biasanya 2.5)
  final int dueDate; // timestamp kapan kartu harus di review
  final int reviewCount; // berapa kali sudah di review

  CardModel({
    this.id,
    required this.deckId,
    required this.front,
    required this.back,
    this.interval = 0, // default: 0 hari (baru)
    this.easeFactor = 2.5, // default SM-2
    required this.dueDate, // di isi DateTime.now() saat create
    this.reviewCount = 0,
  });

  // database -> dart
  factory CardModel.fromMap(Map<String, dynamic> map) {
    return CardModel(
      id: map['id'],
      deckId: map['deck_id'],
      front: map['front'],
      back: map['back'],
      interval: map['interval'],
      easeFactor: map['ease_factor'],
      dueDate: map['due_date'],
      reviewCount: map['review_count'],
    );
  }

  // dart -> database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'deck_id': deckId,
      'front': front,
      'back': back,
      'interval': interval,
      'ease_factor': easeFactor,
      'due_date': dueDate,
      'review_count': reviewCount,
    };
  }

  // helper untuk membuat copy object dengan update data (karena field final)
  CardModel copyWith({
    int? id,
    int? deckId,
    String? front,
    String? back,
    int? interval,
    double? easeFactor,
    int? dueDate,
    int? reviewCount,
  }) {
    return CardModel(
      id: id ?? this.id,
      deckId: deckId ?? this.deckId,
      front: front ?? this.front,
      back: back ?? this.back,
      interval: interval ?? this.interval,
      easeFactor: easeFactor ?? this.easeFactor,
      dueDate: dueDate ?? this.dueDate,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }
}
