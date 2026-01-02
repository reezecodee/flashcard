import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/card_model.dart';
import '../../../data/models/deck_model.dart';
import '../../../data/repositories/card_repository.dart';
import '../../state_management/study_session_provider.dart';
import '../study/study_screen.dart';
import 'add_edit_card_screen.dart';

class DeckDetailScreen extends StatefulWidget {
  final DeckModel deck;
  const DeckDetailScreen({super.key, required this.deck});

  @override
  State<DeckDetailScreen> createState() => _DeckDetailScreenState();
}

class _DeckDetailScreenState extends State<DeckDetailScreen> {
  final CardRepository _cardRepo = CardRepository();
  List<CardModel> _cards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  // ambil data kartu dari db local
  Future<void> _loadCards() async {
    setState(() => _isLoading = true);
    final data = await _cardRepo.getCardByDeckId(widget.deck.id!);
    setState(() {
      _cards = data;
      _isLoading = false;
    });
  }

  // hapus kartu
  Future<void> _deleteCard(int id) async {
    await _cardRepo.deleteCard(id);
    _loadCards(); // refresh list
  }

  // navigasi ke halaman belajar
  void _startStudySession() {
    // panggil provider untuk siapkan antrean kartu
    Provider.of<StudySessionProvider>(
      context,
      listen: false,
    ).startSession(widget.deck.id!);

    // pindah ke layar study (Flashcard UI)
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const StudyScreen()),
    );
  }

  void _startReviewAllSession() {
    // panggil provider dengan parameter reviewAll: true
    Provider.of<StudySessionProvider>(
      context,
      listen: false,
    ).startSession(widget.deck.id!, reviewAll: true);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const StudyScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deck.name),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // header: statistik singkat & tombol belajar
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.primary.withValues(alpha: 0.1),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${_cards.length} Kartu",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text("Total kartu dalam deck ini."),
                    ],
                  ),
                ),
                Row(
                  children: [
                    // tombol utama belajar sesuai jadwal
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      // cek: Kalau due cards habis, disable tombol ini (biar user paham)
                      // tapi karena kita belum punya variabel countDueCards di layar ini,
                      // kita biarkan aktif, nanti Provider yang handle kalau kosong.
                      onPressed: _cards.isEmpty ? null : _startStudySession,
                      child: const Text(
                        "Mulai",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // tombol opsi tambahan (titik tiga / menu)
                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_vert,
                        color: AppColors.primary,
                      ),
                      onSelected: (value) {
                        if (value == 'review_all') {
                          _startReviewAllSession();
                        }
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'review_all',
                              child: Row(
                                children: [
                                  Icon(Icons.history, color: Colors.grey),
                                  SizedBox(width: 8),
                                  Text('Review Semua (Abaikan Jadwal)'),
                                ],
                              ),
                            ),
                          ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // list kartu
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _cards.isEmpty
                ? const Center(child: Text("Belum ada kartu. Tambah dulu yuk!"))
                : ListView.separated(
                    itemCount: _cards.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final card = _cards[index];
                      return ListTile(
                        title: Text(
                          card.front,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          card.back,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // tombol edit
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.grey),
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddEditCardScreen(
                                      deckId: widget.deck.id!,
                                      card: card,
                                    ),
                                  ),
                                );

                                if (result == true) _loadCards();
                              },
                            ),

                            // tombol hapus
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteCard(card.id!),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          // buka layar tambah kartu
          // 'result' akan bernilai true jika user berhasil simpan
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddEditCardScreen(deckId: widget.deck.id!),
            ),
          );

          // resfresh list jika ada data baru
          if (result == true) {
            _loadCards();
          }
        },
      ),
    );
  }
}
