import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../state_management/deck_provider.dart';
import '../deck/deck_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // dijalankan sekali saat halaman di buat
  @override
  void initState() {
    super.initState();

    // panggil fungsi load data dari provider
    // listen: false karena kita cuma mau panggil fungsi, bukan dengan perubahan state disini
    Future.microtask(
      () => {Provider.of<DeckProvider>(context, listen: false).loadDecks()},
    );
  }

  // fungsi untuk menampilkan dialog tambah deck
  void _showAddDeckDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Buat Deck Baru'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            hintText: 'Misal: Belajar Hiragana',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                // panggil Provider untuk simpan ke DB
                Provider.of<DeckProvider>(
                  context,
                  listen: false,
                ).addDeck(nameController.text);
                Navigator.pop(ctx); // tutup dialog
              }
            },
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Flashcards',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: Consumer<DeckProvider>(
        // consumer akan me-rebuild widget di bawahnya
        // SETIAP KALI notifyListeners() dipanggil di Provider
        builder: (context, deckProvider, child) {
          // 1. jika sedang login
          if (deckProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. jika data kosong
          if (deckProvider.decks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.style, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    "Belum ada deck kartu. \nBuat baru yuk!",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            );
          }

          // 3. render list deck
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: deckProvider.decks.length,
            itemBuilder: (context, index) {
              final deck = deckProvider.decks[index];

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: const Icon(Icons.folder, color: AppColors.primary),
                  ),
                  title: Text(
                    deck.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text("Dibuat pada: ${_formatDate(deck.createdAt)}"),
                  trailing: PopupMenuButton(
                    onSelected: (value) {
                      if (value == 'delete') {
                        deckProvider.deleteDeck(deck.id!);
                      }
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Hapus Deck',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    // navigasi ke halaman detail deck (list kartu)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DeckDetailScreen(deck: deck),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showAddDeckDialog(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return "${date.day}/${date.month}/${date.year}";
  }
}
