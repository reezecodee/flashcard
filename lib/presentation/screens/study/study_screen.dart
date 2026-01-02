import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/services/srs_algorithm_service.dart';
import '../../state_management/study_session_provider.dart';
import '../../widgets/flashcard_widget.dart';
import 'study_result_screen.dart';

class StudyScreen extends StatefulWidget {
  const StudyScreen({super.key});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  // state lokal untuk tahu apakah jawaban sedang ditampilkan atau belum
  bool _showAnswer = false;

  void _onCardTap() {
    setState(() {
      _showAnswer = !_showAnswer;
    });
  }

  void _processAnswer(BuildContext context, ReviewRating rating) async {
    // reset state kartu ke posisi "Pertanyaan" (Front)
    setState(() {
      _showAnswer = false;
    });

    // panggil provider untuk hitung algoritma & lanjut ke kartu berikutnya
    await Provider.of<StudySessionProvider>(
      context,
      listen: false,
    ).answerCard(rating);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Time'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<StudySessionProvider>(
        builder: (context, session, child) {
          // 1. cek loading
          if (session.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. cek apakah sesi sudah selesai (kartu habis)
          if (session.isSessionFinished || session.currentCard == null) {
            return const StudyResultScreen();
          }

          final card = session.currentCard!;

          return Column(
            children: [
              // progress indicator (sisa kartu)
              LinearProgressIndicator(
                value: 1.0, // bisa di buat dinamis nanti
                backgroundColor: Colors.grey[200],
                color: AppColors.secondary,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Sisa antrean: ${session.remainingCards} kartu"),
              ),

              // area kertu (tengah)
              Expanded(
                child: GestureDetector(
                  onTap: _onCardTap,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    // tampilkan widget front atau back sesuai state _showAnswer
                    child: FlashcardWidget(
                      isFront: !_showAnswer,
                      content: _showAnswer ? card.back : card.front,
                    ),
                  ),
                ),
              ),

              // tombol evaluasi (bawah)
              // hanya muncul jika user sudah membuka jawaban (_showAnswer == true)
              if (_showAnswer)
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildSrsButton(
                        context,
                        "Again",
                        AppColors.again,
                        ReviewRating.again,
                      ),
                      _buildSrsButton(
                        context,
                        "Hard",
                        AppColors.hard,
                        ReviewRating.hard,
                      ),
                      _buildSrsButton(
                        context,
                        "Good",
                        AppColors.good,
                        ReviewRating.good,
                      ),
                      _buildSrsButton(
                        context,
                        "Easy",
                        AppColors.easy,
                        ReviewRating.easy,
                      ),
                    ],
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    "Tap kartu untuk lihat jawaban",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // helper bikin tombol warna warni
  Widget _buildSrsButton(
    BuildContext context,
    String label,
    Color color,
    ReviewRating rating,
  ) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onPressed: () => _processAnswer(context, rating),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
