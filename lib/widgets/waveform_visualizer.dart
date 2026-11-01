/// ==============================================================================
/// WIDGET HIỂN THỊ SÓNG ÂM THANH THỜI GIAN THỰC (WAVEFORM VISUALIZER)
/// Phụ trách: NGUYỄN TRUNG KIÊN (2251172394) - Checklist 3 & Sprint 3
/// ==============================================================================

import 'dart:async';
import 'package:flutter/material.dart';

/// Chế độ hiển thị của bộ trực quan hóa sóng âm
enum WaveformDisplayMode {
  idle,       // Nghỉ / Sẵn sàng
  recording,  // Đang thu âm (hiệu ứng sóng đỏ/cam chuyển động theo micro)
  playback,   // Đang phát lại âm thanh đã thu (sóng xanh dương chạy theo tiến độ)
}

class WaveformVisualizerWidget extends StatefulWidget {
  final bool isRecording;
  final bool isPlaying;
  final WaveformDisplayMode? mode;
  final List<double>? amplitudes;
  final Stream<double>? amplitudeStream;
  final double playbackProgress; // 0.0 - 1.0 khi đang phát lại
  final double height;
  final int barCount;
  final Color? activeColor;
  final Color? inactiveColor;
  final bool showLiveMetrics;

  const WaveformVisualizerWidget({
    Key? key,
    this.isRecording = false,
    this.isPlaying = false,
    this.mode,
    this.amplitudes,
    this.amplitudeStream,
    this.playbackProgress = 0.0,
    this.height = 90.0,
    this.barCount = 28,
    this.activeColor,
    this.inactiveColor,
    this.showLiveMetrics = true,
  }) : super(key: key);

  @override
  State<WaveformVisualizerWidget> createState() => _WaveformVisualizerWidgetState();
}

class _WaveformVisualizerWidgetState extends State<WaveformVisualizerWidget> {
  late List<double> _liveBars;
  StreamSubscription<double>? _streamSub;
  double _currentPeak = 0.0;

  @override
  void initState() {
    super.initState();
    _liveBars = widget.amplitudes != null && widget.amplitudes!.isNotEmpty
        ? List.from(widget.amplitudes!)
        : _generateRestingBars(widget.barCount);
    _listenToAmplitudeStream();
  }

  @override
  void didUpdateWidget(covariant WaveformVisualizerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.amplitudeStream != oldWidget.amplitudeStream) {
      _streamSub?.cancel();
      _listenToAmplitudeStream();
    }
    if (widget.amplitudes != null && widget.amplitudes != oldWidget.amplitudes) {
      _liveBars = List.from(widget.amplitudes!);
    }
  }

  void _listenToAmplitudeStream() {
    if (widget.amplitudeStream != null) {
      _streamSub = widget.amplitudeStream!.listen((amp) {
        if (!mounted) return;
        setState(() {
          _currentPeak = amp;
          if (_liveBars.length >= widget.barCount) {
            _liveBars.removeAt(0);
          }
          _liveBars.add(amp);
        });
      });
    }
  }

  @override
  void dispose() {
    _streamSub?.cancel();
    super.dispose();
  }

  List<double> _generateRestingBars(int count) {
    return List.generate(count, (i) {
      // Dạng sóng hình sin tĩnh nhẹ khi nghỉ
      return 0.15 + 0.12 * (1.0 - (2.0 * i / count - 1.0).abs());
    });
  }

  WaveformDisplayMode get _resolvedMode {
    if (widget.mode != null) return widget.mode!;
    if (widget.isRecording) return WaveformDisplayMode.recording;
    if (widget.isPlaying) return WaveformDisplayMode.playback;
    return WaveformDisplayMode.idle;
  }

  @override
  Widget build(BuildContext context) {
    final mode = _resolvedMode;
    final theme = Theme.of(context);

    // Bảng màu thích ứng theo trạng thái
    final Color activeColor = widget.activeColor ??
        (mode == WaveformDisplayMode.recording
            ? Colors.redAccent.shade700
            : mode == WaveformDisplayMode.playback
                ? Colors.blue.shade600
                : theme.primaryColor);

    final Color inactiveColor = widget.inactiveColor ??
        (mode == WaveformDisplayMode.recording
            ? Colors.red.shade100
            : Colors.grey.shade300);

    final Color bgColor = mode == WaveformDisplayMode.recording
        ? Colors.red.shade50.withOpacity(0.6)
        : mode == WaveformDisplayMode.playback
            ? Colors.blue.shade50.withOpacity(0.5)
            : Colors.grey.shade50;

    final Color borderColor = mode == WaveformDisplayMode.recording
        ? Colors.red.shade300
        : mode == WaveformDisplayMode.playback
            ? Colors.blue.shade300
            : Colors.grey.shade300;

    // Đảm bảo số lượng cột sóng luôn khớp barCount
    final displayAmplitudes = _getDisplayAmplitudes(widget.barCount);

    return Container(
      height: widget.height,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: mode == WaveformDisplayMode.recording
            ? [
                BoxShadow(
                  color: Colors.red.withOpacity(0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                )
              ]
            : [],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: List.generate(displayAmplitudes.length, (index) {
                final amp = displayAmplitudes[index];
                
                // Xác định chiều cao thanh sóng (min 8px, max 54px)
                double barHeight = (amp * (widget.height - 34.0)).clamp(8.0, widget.height - 30.0);
                if (mode == WaveformDisplayMode.idle) {
                  barHeight = 10.0 + (amp * 16.0);
                }

                // Khi đang playback, tô màu thanh đã chạy qua
                bool isPassedInPlayback = false;
                if (mode == WaveformDisplayMode.playback) {
                  final thresholdIndex = (widget.playbackProgress * displayAmplitudes.length).round();
                  isPassedInPlayback = index <= thresholdIndex;
                }

                final barColor = mode == WaveformDisplayMode.recording
                    ? activeColor
                    : mode == WaveformDisplayMode.playback
                        ? (isPassedInPlayback ? activeColor : inactiveColor)
                        : inactiveColor;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 90),
                  curve: Curves.easeOutQuad,
                  width: (MediaQuery.of(context).size.width - 90) / (displayAmplitudes.length * 1.5),
                  height: barHeight,
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                );
              }),
            ),
          ),
          if (widget.showLiveMetrics)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: mode == WaveformDisplayMode.recording
                              ? Colors.red
                              : mode == WaveformDisplayMode.playback
                                  ? Colors.blue
                                  : Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        mode == WaveformDisplayMode.recording
                            ? 'Đang thu âm (16kHz Mono WAV)...'
                            : mode == WaveformDisplayMode.playback
                                ? 'Đang phát lại giọng đọc'
                                : 'Sẵn sàng thu âm',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: mode == WaveformDisplayMode.recording
                              ? Colors.red.shade700
                              : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    mode == WaveformDisplayMode.recording
                        ? 'Cường độ: ${(_currentPeak * 100).round()}%'
                        : mode == WaveformDisplayMode.playback
                            ? '${(widget.playbackProgress * 100).round()}%'
                            : 'Mic 16kHz',
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  List<double> _getDisplayAmplitudes(int targetCount) {
    if (_liveBars.length == targetCount) return _liveBars;
    if (_liveBars.length > targetCount) {
      return _liveBars.sublist(_liveBars.length - targetCount);
    }
    // Bổ sung thêm các bar giá trị nghỉ nếu chưa đủ
    final diff = targetCount - _liveBars.length;
    return [...List.filled(diff, 0.15), ..._liveBars];
  }
}
