/// ==============================================================================
/// WIDGET THẺ ĐIỂM PHÁT ÂM DẠNG GAUGE CHART (SCORE CARD WIDGET)
/// Phụ trách: Trần Anh Tuấn (2351170629) - Mục Checklist 5
/// ==============================================================================
///
/// Hiển thị điểm tổng hợp dạng Gauge Chart (0–100) kèm 3 tiêu chí
/// Accuracy / Completeness / Fluency và so sánh IPA chuẩn - người đọc.
/// Chỉ dùng Flutter có sẵn, không cần thêm dependency.
/// Tương thích với model hiện tại của repo (PronunciationResult).

import 'dart:math';

import 'package:flutter/material.dart';

import '../models/pronunciation_result_model.dart';

class ScoreCardWidget extends StatelessWidget {
  final PronunciationResult result;

  const ScoreCardWidget({super.key, required this.result});

  /// Màu theo ngưỡng của [PronunciationResult.ratingTier] trong repo:
  /// >= 85 Xuất sắc, >= 70 Tốt, >= 50 Cần luyện tập thêm, còn lại Chưa đạt.
  Color _scoreColor(double score) {
    if (score >= 85) return Colors.green;
    if (score >= 70) return Colors.teal;
    if (score >= 50) return Colors.amber.shade700;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final color = _scoreColor(result.overallScore);
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Kết quả: "${result.targetWord}"',
              style:
                  textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Chuẩn /${result.standardIpa}/ — Bạn đọc /${result.recognizedIpa}/',
              style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: 170,
              height: 170,
              child: CustomPaint(
                painter:
                    _GaugePainter(score: result.overallScore, color: color),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        result.overallScore.toStringAsFixed(0),
                        style: textTheme.displaySmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        result.ratingTier,
                        style: textTheme.titleSmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _SubScoreRow(label: 'Độ chính xác', score: result.accuracyScore),
            const SizedBox(height: 8),
            _SubScoreRow(label: 'Độ đầy đủ', score: result.completenessScore),
            const SizedBox(height: 8),
            _SubScoreRow(label: 'Độ trôi chảy', score: result.fluencyScore),
          ],
        ),
      ),
    );
  }
}

class _SubScoreRow extends StatelessWidget {
  final String label;
  final double score;

  const _SubScoreRow({required this.label, required this.score});

  Color get _color {
    if (score >= 85) return Colors.green;
    if (score >= 70) return Colors.teal;
    if (score >= 50) return Colors.amber.shade700;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score / 100,
              minHeight: 8,
              color: _color,
              backgroundColor: _color.withValues(alpha: 0.15),
            ),
          ),
        ),
        SizedBox(
          width: 44,
          child: Text(
            score.toStringAsFixed(0),
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

/// Vẽ gauge 270 độ: nền xám + cung tiến trình theo điểm.
class _GaugePainter extends CustomPainter {
  final double score;
  final Color color;

  _GaugePainter({required this.score, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const startAngle = 3 * pi / 4;
    const totalSweep = 3 * pi / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final bgPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, startAngle, totalSweep, false, bgPaint);

    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, startAngle, totalSweep * score / 100, false, fgPaint);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) =>
      oldDelegate.score != score || oldDelegate.color != color;
}
