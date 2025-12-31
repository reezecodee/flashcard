import '../local/db_helper.dart';
import '../models/deck_model.dart';

class DeckRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // create: menambah deck baru
  Future<int> insertDeck(DeckModel deck) async {
    final db = await _dbHelper.database;

    // kembalikan id dari row yang baru dibuat
    return await db.insert('decks', deck.toMap());
  }

  // read: ambil semua deck
  Future<List<DeckModel>> getAllDecks() async {
    final db = await _dbHelper.database;

    // ambil semua dan urutkan berdasarkan created_at desc
    final result = await db.query('decks', orderBy: 'created_at DESC');

    return result.map((map) => DeckModel.fromMap(map)).toList();
  }

  // update: ganti nama deck (opsional: buat jaga-jaga)
  Future<int> updateDeck(DeckModel deck) async {
    final db = await _dbHelper.database;

    return await db.update(
      'decks',
      deck.toMap(),
      where: 'id = ?',
      whereArgs: [deck.id],
    );
  }

  // delete: menghapus deck
  // karena di set ON DELETE CASCADE otomatis kartu di dalamnya ikut hilang
  Future<int> deleteDeck(int id) async {
    final db = await _dbHelper.database;

    return await db.delete('decks', where: 'id = ?', whereArgs: [id]);
  }
}
