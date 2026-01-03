import 'package:flutter/material.dart';
import '../../data/models/card_model.dart';
import '../../data/repositories/card_repository.dart';
import '../../domain/services/srs_algorithm_service.dart';

class StudySessionProvider with ChangeNotifier {
  final CardRepository _cardRepository = CardRepository();
  final SrsAlgorithmService _srsService = SrsAlgorithmService();

  // antrean kartu yang harus dipelajari sesi ini
  List<CardModel> _sessionQueue = [];

  // kartu yang sedang tampil di layar sekarang
  CardModel? _currentCard;

  // status
  bool _isLoading = false;
  bool _isSessionFinished = false;

  // getters
  CardModel? get currentCard => _currentCard;
  bool get isLoading => _isLoading;
  bool get isSessionFinished => _isSessionFinished;
  int get remainingCards => _sessionQueue.length;

  // 1. mulai sesi belajar
  Future<void> startSession(int deckId, {bool reviewAll = false}) async {
    _isLoading = true;
    _isSessionFinished = false;
    notifyListeners();

    if (reviewAll) {
      // mode bebas: ambil semua kartu dalam deck (tanpa filter tanggal)
      _sessionQueue = await _cardRepository.getCardByDeckId(deckId);
      // opsional: acak urutan kartu agar tidak monoton
      _sessionQueue.shuffle();
    } else {
      // model normal: hanya ambil yang due date <= sekarang
      _sessionQueue = await _cardRepository.getDueCards(deckId);
    }

    if (_sessionQueue.isNotEmpty) {
      _currentCard = _sessionQueue.first;
    } else {
      _isSessionFinished = true;
    }

    _isLoading = false;
    notifyListeners();
  }

  // 2. user menjawab kartu
  Future<void> answerCard(ReviewRating rating) async {
    if (_currentCard == null) return;

    // hitung logika matematika SRS (interval baru, dll)
    final updatedCard = _srsService.processPreview(_currentCard!, rating);

    // logika sesi
    if (rating == ReviewRating.again) {
      // jika "Again" (Lupa):
      // jangan simpan ke DB dulu (atau simpan tapi interval 0).
      // masukkan lagi ke antrean paling belakang biar muncul lagi sesi ini.
      _sessionQueue.add(_sessionQueue.removeAt(0));
      // artinya: Ambil kartu index 0, taruh di index terakhir.
    } else {
      // jika lulus (Hard/Good/Easy)
      // 1. update data kartu di database (simpan jadwal review berikutnya)
      await _cardRepository.updateCard(updatedCard);

      // 2. hapus kartu dari antrean sesi ini
      _sessionQueue.removeAt(0);
    }

    // load kartu berikutnya
    _loadNextCard();
  }

  void _loadNextCard() {
    if (_sessionQueue.isNotEmpty) {
      _currentCard = _sessionQueue.first;
    } else {
      // antrean habis, sesi selesai
      _currentCard = null;
      _isSessionFinished = true;
    }

    notifyListeners();
  }
}
