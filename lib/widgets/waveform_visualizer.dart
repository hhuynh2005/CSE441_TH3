/// ==============================================================================
/// WIDGET HIỂN THỊ SÓNG ÂM THANH THỜI GIAN THỰC (WAVEFORM VISUALIZER)
/// Phụ trách: NGUYỄN TRUNG KIÊN (2251172394) - Mục Checklist 3
/// ==============================================================================

import 'package:flutter/material.dart';

class WaveformVisualizerWidget extends StatelessWidget {
  final bool isRecording;
  final List<double> amplitudes;

  const WaveformVisualizerWidget({
    Key? key,
    required this.isRecording,
    this.amplitudes = const [0.2, 0.5, 0.8, 0.4, 0.9, 0.6, 0.3, 0.7, 0.5, 0.2],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isRecording ? Colors.red.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRecording ? Colors.red.shade300 : Colors.grey.shade300,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: amplitudes.map((amp) {
          final height = isRecording ? (amp * 60.0).clamp(8.0, 65.0) : 10.0;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: 6,
            height: height,
            decoration: BoxDecoration(
              color: isRecording ? Colors.redAccent : Colors.grey.shade400,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }).toList(),
      ),
    );
  }
}
