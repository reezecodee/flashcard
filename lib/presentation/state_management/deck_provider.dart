import 'package:flutter/material.dart';
import '../../data/models/deck_model.dart';
import '../../data/repositories/deck_repository.dart';

class DeckProvider with ChangeNotifier {
  final DeckRepository _deckRepository = DeckRepository();

  // state: list deck yang akan di tampilkan di UI
  List<DeckModel> _decks = [];

  // getter agar UI bisa baca data (tapi gak bisa ubah langsung)
  List<DeckModel> get decks => _decks;

  // loading state (untuk spinner di UI)
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // method: load semua dari deck dari DB
  Future<void> loadDecks() async {
    _isLoading = true;
    notifyListeners(); // untuk kasih tahu sedang loading

    _decks = await _deckRepository.getAllDecks();

    _isLoading = false;
    notifyListeners(); // kasih tahu UI data sudah siap dan suruh render ulang
  }

  // method: tambah deck
  Future<void> addDeck(String name) async {
    final newDeck = DeckModel(
      name: name,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    await _deckRepository.insertDeck(newDeck);

    // refresh list setelah insert
    await loadDecks();
  }

  // method: hapus deck
  Future<void> deleteDeck(int id) async {
    await _deckRepository.deleteDeck(id);
    await loadDecks();
  }
}
