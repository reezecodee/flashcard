import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class FlashcardWidget extends StatelessWidget {
  final String content;
  final bool isFront;

  const FlashcardWidget({
    super.key,
    required this.content,
    required this.isFront,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isFront ? Colors.white : AppColors.primary.withValues(alpha: 0.1),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isFront ? 'PERTANYAAN' : 'JAWABAN',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              content,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w500,
                color: isFront ? Colors.black87 : AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
