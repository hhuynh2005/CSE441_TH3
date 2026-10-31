/// ==============================================================================
/// WIDGET PHẢN HỒI ÂM VỊ TRỰC QUAN (PHONEME FEEDBACK WIDGET)
/// Phụ trách: Trần Anh Tuấn (2351170629) - Mục Checklist 5
/// ==============================================================================

import 'package:flutter/material.dart';
import '../models/pronunciation_result_model.dart';

class PhonemeFeedbackWidget extends StatelessWidget {
  final PronunciationResult result;

  const PhonemeFeedbackWidget({Key? key, required this.result}) : super(key: key);

  Color _getColorForStatus(PhonemeStatus status) {
    switch (status) {
      case PhonemeStatus.correct:
        return const Color(0xFF2E7D32); // Xanh lục (Chuẩn)
      case PhonemeStatus.incorrect:
        return const Color(0xFFC62828); // Đỏ (Sai âm)
      case PhonemeStatus.missed:
        return const Color(0xFFEF6C00); // Cam (Nuốt âm)
      case PhonemeStatus.inserted:
        return const Color(0xFF6A1B9A); // Tím (Thừa âm)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  result.targetWord.toUpperCase(),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: result.overallScore >= 80 ? Colors.green.shade50 : Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: result.overallScore >= 80 ? Colors.green : Colors.amber,
                    ),
                  ),
                  child: Text(
                    '${result.overallScore.toStringAsFixed(0)} / 100',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: result.overallScore >= 80 ? Colors.green.shade800 : Colors.amber.shade900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Phân tích chi tiết từng âm vị (IPA):',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: result.phonemeDetails.map((item) {
                final color = _getColorForStatus(item.status);
                return Chip(
                  avatar: CircleAvatar(
                    backgroundColor: color,
                    radius: 10,
                    child: Icon(
                      item.status == PhonemeStatus.correct ? Icons.check : Icons.priority_high,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                  label: Text(
                    '/${item.targetPhoneme}/',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  backgroundColor: color.withValues(alpha: 0.12),
                  side: BorderSide(color: color),
                );
              }).toList(),
            ),
            const Divider(height: 24),
            Text(
              result.feedbackSummary,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            if (result.targetedExerciseSuggestion != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.lightbulb_outline, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Gợi ý: ${result.targetedExerciseSuggestion}',
                      style: TextStyle(fontSize: 13, color: Colors.blueGrey.shade800),
                    ),
                  ),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }
}
