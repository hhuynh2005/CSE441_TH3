/// ==============================================================================
/// GIAO DIỆN BẢNG ĐIỀU KHIỂN TIẾN ĐỘ & KỶ LUẬT HỌC TẬP (PROGRESS DASHBOARD VIEW)
/// Phụ trách: Lê Anh Tuấn (2151060296) - Phân hệ Theo dõi Kỷ luật & Thông báo
/// Mục Checklist 2 & 6 - Bài tập thực hành 3 (TH3) - Nhóm 16
/// ==============================================================================

import 'package:flutter/material.dart';
import '../models/user_progress_model.dart';
import '../services/streak_service.dart';
import '../services/daily_notification_service.dart';
import '../widgets/streak_badge_widget.dart';

class ProgressDashboardView extends StatefulWidget {
  final UserProgressModel? initialProgress;

  const ProgressDashboardView({Key? key, this.initialProgress}) : super(key: key);

  @override
  State<ProgressDashboardView> createState() => _ProgressDashboardViewState();
}

class _ProgressDashboardViewState extends State<ProgressDashboardView> {
  final StreakService _streakService = StreakService();
  final DailyNotificationService _notificationService = DailyNotificationService();

  late UserProgressModel _userProgress;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);
  bool _isReminderEnabled = true;
  bool _isSmartWarningEnabled = true;

  @override
  void initState() {
    super.initState();
    _userProgress = widget.initialProgress ??
        UserProgressModel(
          userId: 'user_001',
          displayName: 'Nguyễn Văn Huỳnh',
          currentStreak: 5,
          longestStreak: 12,
          lastPracticeDate: DateTime.now().subtract(const Duration(days: 1)),
          streakFreezeCount: 2,
          dailyGoalMinutes: 15,
          dailyGoalWords: 10,
          todayMinutesLearned: 10,
          todayWordsPracticed: 6,
          totalMinutesLearned: 145,
          totalWordsPracticed: 120,
          practiceDatesHistory: [
            DateTime.now().subtract(const Duration(days: 4)).toIso8601String().split('T')[0],
            DateTime.now().subtract(const Duration(days: 3)).toIso8601String().split('T')[0],
            DateTime.now().subtract(const Duration(days: 2)).toIso8601String().split('T')[0],
            DateTime.now().subtract(const Duration(days: 1)).toIso8601String().split('T')[0],
          ],
        );

    _reminderTime = TimeOfDay(
      hour: _userProgress.reminderHour,
      minute: _userProgress.reminderMinute,
    );
    _isReminderEnabled = _userProgress.isDailyReminderEnabled;
  }

  void _onGoalTimeSelected(int minutes) {
    setState(() {
      _userProgress = _streakService.updateDailyGoals(_userProgress, minutes: minutes);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🎯 Đã đổi mục tiêu học tập thành $minutes phút/ngày!'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _simulatePracticeSession() {
    final result = _streakService.recordPracticeSession(
      current: _userProgress,
      sessionMinutes: 5,
      wordsCount: 5,
      practiceTime: DateTime.now(),
    );

    setState(() {
      _userProgress = result.updatedProgress;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.deepOrange.shade700,
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.yellowAccent),
            const SizedBox(width: 8),
            Expanded(child: Text(result.statusMessage)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Bắn thông báo mốc nếu chuỗi đạt mốc
    if (result.isStreakIncreased) {
      _notificationService.createStreakMilestoneNotification(_userProgress.currentStreak);
    }
  }

  void _simulateStreakRecovery() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.healing, color: Colors.deepOrange),
            SizedBox(width: 8),
            Text('Giải Cứu Chuỗi Streak'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🎯 Thử Thách Cứu Chuỗi:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6),
            Text(
              'Nếu chẳng may quên học khiến chuỗi bị reset, bạn có thể thực hiện bài kiểm tra phát âm đặc biệt (hoàn thành 5 câu phát âm chuẩn ≥ 85 điểm) để khôi phục lại chuỗi ngày học của mình!',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Để sau'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _userProgress = _streakService.recoverBrokenStreak(
                  _userProgress,
                  originalStreak: _userProgress.longestStreak,
                );
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.teal.shade700,
                  content: Text(
                    '🎉 Xuất sắc! Bạn đã vượt qua bài test và khôi phục chuỗi ${_userProgress.currentStreak} ngày!',
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
            child: const Text('Thực hiện thử thách', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _selectReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (picked != null) {
      setState(() {
        _reminderTime = picked;
        _userProgress = _userProgress.copyWith(
          reminderHour: picked.hour,
          reminderMinute: picked.minute,
        );
      });
      await _notificationService.scheduleDailyReminder(
        hour: picked.hour,
        minute: picked.minute,
        isEnabled: _isReminderEnabled,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⏰ Đã cập nhật giờ nhắc nhở lúc ${_reminderTime.format(context)}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _sendTestNotification() async {
    final riskStatus = _streakService.checkStreakRiskStatus(_userProgress, DateTime.now());
    String title = '⏰ Nhắc nhở SpeakUp AI';
    String message = '';

    if (riskStatus == 'CRITICAL_RISK') {
      message = await _notificationService.triggerStreakUrgentWarning(
        currentStreak: _userProgress.currentStreak,
        hasFreezeLeft: _userProgress.streakFreezeCount > 0,
      );
      title = '🚨 Cảnh Báo Nguy Cơ Mất Chuỗi!';
    } else {
      message = _notificationService.generateDailyMotivationMessage(_userProgress);
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.notifications_active, color: Colors.deepOrange),
            const SizedBox(width: 8),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 18))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message, style: const TextStyle(fontSize: 15, height: 1.4)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: Colors.orange),
                  const SizedBox(width: 6),
                  Text(
                    'Đã lên lịch nhắc lúc ${_reminderTime.format(context)}',
                    style: TextStyle(fontSize: 12, color: Colors.orange.shade900),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rank = _streakService.getDisciplineRank(_userProgress.currentStreak);
    final weekStatus = _streakService.getWeeklyCalendarStatus(_userProgress);
    final milestone = _streakService.getNextMilestoneTarget(_userProgress.currentStreak);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text(
          'Tiến Độ & Kỷ Luật Học Tập',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: StreakBadgeWidget(progress: _userProgress, isCompact: true),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. User Header & Discipline Rank
            _buildUserHeaderCard(rank),
            const SizedBox(height: 16),

            // 2. Streak Badge Card
            Center(child: StreakBadgeWidget(progress: _userProgress)),
            const SizedBox(height: 16),

            // 3. Next Milestone Target Card
            _buildMilestoneTargetCard(milestone),
            const SizedBox(height: 16),

            // 4. Daily Goal Progress Card
            _buildDailyGoalCard(),
            const SizedBox(height: 16),

            // 5. Weekly Calendar / Heatmap
            _buildWeeklyCalendarCard(weekStatus),
            const SizedBox(height: 16),

            // 6. Overall Analytics Grid
            _buildAnalyticsGrid(),
            const SizedBox(height: 16),

            // 7. Streak Challenge & Recovery Card
            _buildRecoveryCard(),
            const SizedBox(height: 16),

            // 8. Daily Notification & Smart Reminder Settings
            _buildNotificationSettingsCard(),
            const SizedBox(height: 24),

            // 9. Action Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _simulatePracticeSession,
                icon: const Icon(Icons.mic, color: Colors.white),
                label: const Text(
                  'Luyện Phát Âm Ngay Để Giữ Chuỗi 🔥',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeaderCard(DisciplineRank rank) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.deepOrange.shade100,
            child: const Text('NH', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.deepOrange)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userProgress.displayName,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(rank.badgeIcon, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                    Text(
                      '${rank.title} (Level ${rank.level})',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.deepOrange.shade700,
                      ),
                    ),
                  ],
                ),
                Text(
                  rank.description,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneTargetCard(MilestoneTarget milestone) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade50, Colors.deepPurple.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.deepPurple.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(milestone.icon, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(
                    'Mốc Tiếp Theo: ${milestone.targetDays} Ngày',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple.shade900,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Còn ${milestone.remainingDays} ngày',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple.shade800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: milestone.progressPercent / 100.0,
              minHeight: 8,
              backgroundColor: Colors.deepPurple.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple.shade400),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Phần thưởng: ${milestone.rewardTitle}',
            style: TextStyle(fontSize: 12, color: Colors.deepPurple.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyGoalCard() {
    final pct = _userProgress.goalCompletionPercentage;
    final isDone = _userProgress.isDailyGoalCompleted;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.flag, color: Colors.blueAccent),
                  SizedBox(width: 8),
                  Text(
                    'Mục Tiêu Hôm Nay',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDone ? Colors.green.shade50 : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isDone ? '🎉 Hoàn thành' : '$pct%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDone ? Colors.green.shade700 : Colors.orange.shade800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (pct / 100.0).clamp(0.0, 1.0),
              minHeight: 12,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDone ? Colors.green : Colors.deepOrange,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '⏱️ Thời gian: ${_userProgress.todayMinutesLearned} / ${_userProgress.dailyGoalMinutes} phút',
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
              Text(
                '🗣️ Từ vựng: ${_userProgress.todayWordsPracticed} / ${_userProgress.dailyGoalWords} từ',
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(),
          const SizedBox(height: 8),
          const Text('Chọn nhanh mục tiêu:', style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [5, 10, 15, 30].map((mins) {
              final isSelected = _userProgress.dailyGoalMinutes == mins;
              return ChoiceChip(
                label: Text('$mins phút'),
                selected: isSelected,
                selectedColor: Colors.deepOrange,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                onSelected: (_) => _onGoalTimeSelected(mins),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyCalendarCard(List<DayProgressStatus> weekStatus) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.calendar_month, color: Colors.deepOrange),
              SizedBox(width: 8),
              Text(
                'Chuỗi Ngày Tuần Này',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: weekStatus.map((day) {
              Color bgColor = Colors.grey.shade100;
              Color textColor = Colors.grey.shade600;
              Widget icon = const SizedBox(height: 18);

              if (day.isPracticed) {
                bgColor = Colors.deepOrange.shade100;
                textColor = Colors.deepOrange.shade900;
                icon = const Icon(Icons.local_fire_department, color: Colors.deepOrange, size: 20);
              } else if (day.isToday) {
                bgColor = Colors.blue.shade50;
                textColor = Colors.blue.shade900;
                icon = const Icon(Icons.schedule, color: Colors.blueAccent, size: 18);
              }

              return Container(
                width: 42,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: day.isToday ? Border.all(color: Colors.blueAccent, width: 2) : null,
                ),
                child: Column(
                  children: [
                    Text(
                      day.dayLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${day.date.day}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    icon,
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _buildStatCard(
          icon: Icons.timer,
          title: 'Tổng Thời Gian',
          value: '${_userProgress.totalMinutesLearned} phút',
          color: Colors.indigo,
        ),
        _buildStatCard(
          icon: Icons.record_voice_over,
          title: 'Tổng Từ Phát Âm',
          value: '${_userProgress.totalWordsPracticed} từ',
          color: Colors.teal,
        ),
        _buildStatCard(
          icon: Icons.emoji_events,
          title: 'Kỷ Lục Streak',
          value: '${_userProgress.longestStreak} ngày',
          color: Colors.amber.shade800,
        ),
        _buildStatCard(
          icon: Icons.shield,
          title: 'Khiên Freeze',
          value: '${_userProgress.streakFreezeCount} khiên',
          color: Colors.cyan.shade700,
        ),
      ],
    );
  }

  Widget _buildRecoveryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.deepOrange.shade50,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.healing, color: Colors.deepOrange, size: 26),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thử Thách Giải Cứu Chuỗi',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 2),
                Text(
                  'Làm bài test phát âm bù nếu lỡ đứt chuỗi',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _simulateStreakRecovery,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade100,
              foregroundColor: Colors.deepOrange.shade800,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Thử ngay', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(title, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettingsCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.notifications, color: Colors.purple),
              SizedBox(width: 8),
              Text(
                'Cài Đặt Nhắc Nhở Học Tập',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Bật nhắc nhở hàng ngày', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text('Thông báo lúc ' + _reminderTime.format(context), style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              Switch.adaptive(
                value: _isReminderEnabled,
                activeThumbColor: Colors.deepOrange,
                onChanged: (val) {
                  setState(() {
                    _isReminderEnabled = val;
                  });
                },
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Khung giờ nhắc nhở', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              OutlinedButton.icon(
                icon: const Icon(Icons.access_time, size: 16, color: Colors.deepOrange),
                onPressed: _selectReminderTime,
                label: Text(_reminderTime.format(context), style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cảnh báo nguy cơ mất chuỗi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    SizedBox(height: 2),
                    Text('Gửi cảnh báo gấp vào 20:00 nếu chưa học', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              Switch.adaptive(
                value: _isSmartWarningEnabled,
                activeThumbColor: Colors.deepOrange,
                onChanged: (val) {
                  setState(() {
                    _isSmartWarningEnabled = val;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton.icon(
              onPressed: _sendTestNotification,
              icon: const Icon(Icons.send, size: 16, color: Colors.deepOrange),
              label: const Text(
                'Gửi Thử Nghiệm Thông Báo Ngay',
                style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
