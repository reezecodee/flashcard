import '../../data/models/card_model.dart';

// enum untuk representasi tombol yang ditekan user
enum ReviewRating {
  again, // lupa/salah
  hard, // ingat tapi susah payah
  good, // ingat dengan wajar
  easy, // sangat mudah
}

class SrsAlgorithmService {
  // fungsi utama yang di panggil ketika user klik tombol
  CardModel processPreview(CardModel card, ReviewRating rating) {
    // 1. konversi rating ke quality (0-5) ala SuperMemo
    // again = 0-1, hard = 3, good = 4, easy = 5
    int quality = _getQualityFromRating(rating);

    // 2. hitung ease factor baru
    // ef menentukan seberapa cepat interval bertambah (multiplier)
    double newEaseFactor = _calculateEaseFactor(card.easeFactor, quality);

    // 3. hitung interval baru (jeda hari)
    int newInterval = _calculateInterval(card, rating, newEaseFactor);

    // 4. hitung due date baru (hari ini + interval baru)
    // menggunakan DateTime untuk akurasi, lalu konvert ke timestamp
    final now = DateTime.now();
    final nextDueDate = now.add(Duration(days: newInterval));

    // 5. kembalikan object card baru dengan data yang sudah di update
    return card.copyWith(
      interval: newInterval,
      easeFactor: newEaseFactor,
      dueDate: nextDueDate.millisecondsSinceEpoch,
      reviewCount: card.reviewCount + 1,
    );
  }

  int _getQualityFromRating(ReviewRating rating) {
    switch (rating) {
      case ReviewRating.again:
        return 0; // gatot
      case ReviewRating.hard:
        return 3; // susah
      case ReviewRating.good:
        return 4; // oke
      case ReviewRating.easy:
        return 5; // gampang
    }
  }

  double _calculateEaseFactor(double currentEaseFactor, int quality) {
    if (quality < 3) {
      // jika gagal (again), ease factor tidak berubah (atau bisa diturunkan sedikit)
      return currentEaseFactor;
    }

    // rumus standar SM-2:
    // EF = EF + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02))
    double newEF =
        currentEaseFactor +
        (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));

    // batas bawah ef adalah 1.3 (biar interval tidak mengecil terlalu parah)
    if (newEF < 1.3) return 1.3;

    return newEF;
  }

  int _calculateInterval(
    CardModel card,
    ReviewRating rating,
    double easeFactor,
  ) {
    // jika user menekang AGAIN (lupa)
    if (rating == ReviewRating.again) {
      return 0; // reset, muncul lagi hari ini (session yang sama)
      // note: Di UI nanti, kalau interval 0, jangan simpan ke DB dulu,
      // tapi masukkan lagi ke antrian belajar sesi ini.
    }

    // penanganan interval awal (review count masih sedikit)
    if (card.reviewCount == 0) {
      return 1; // pertemuan pertama -> besok
    } else if (card.reviewCount == 1) {
      return 6; // pertemuan kedua -> 6 hari lagi
    } else {
      // pertemuan selanjutnya -> interval lama * ease factor
      // contoh: 6 hari * 2.5 = 15 hari
      return (card.interval * easeFactor).round();
    }
  }
}
