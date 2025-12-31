import '../local/db_helper.dart';
import '../models/card_model.dart';

class CardRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // create: tambah kartu
  Future<int> insertCard(CardModel card) async {
    final db = await _dbHelper.database;

    return await db.insert('cards', card.toMap());
  }

  // read: ambil semua kartu dalam satu deck (untuk menu edit/list)
  Future<List<CardModel>> getCardByDeckId(int deckId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'cards',
      where: 'deck_id = ?',
      whereArgs: [deckId],
    );

    return result.map((map) => CardModel.fromMap(map)).toList();
  }

  // read: query penting untuk SRS (ambil kartu yang harus di pelajari)
  // logic: ambil kartu yang due_datenya <= waktu sekarang
  Future<List<CardModel>> getDueCards(int deckId) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().millisecondsSinceEpoch;

    final result = await db.query(
      'cards',
      where: 'deck_id = ? AND due_date <= ?',
      whereArgs: [deckId, now],
      orderBy: 'due_date ASC',
    );

    return result.map((map) => CardModel.fromMap(map)).toList();
  }

  // update: update status kartu setelah berjajar (interval & due date baru)
  Future<int> updateCard(CardModel card) async {
    final db = await _dbHelper.database;

    return await db.update(
      'cards',
      card.toMap(),
      where: 'id = ?',
      whereArgs: [card.id],
    );
  }

  // delete: hapus kartu
  Future<int> deleteCard(int id) async {
    final db = await _dbHelper.database;

    return await db.delete('cards', where: 'id = ?', whereArgs: [id]);
  }
}
