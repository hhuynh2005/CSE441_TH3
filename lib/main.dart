import 'package:flutter/material.dart';
import 'views/progress_dashboard_view.dart';
import 'views/pronunciation_practice_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SpeakUpAIApp());
}

class SpeakUpAIApp extends StatelessWidget {
  const SpeakUpAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpeakUp AI - TH3 Nhóm 16',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamilyFallback: const ['Noto Sans', 'Roboto', 'Arial Unicode MS', 'sans-serif'],
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      home: const MainNavigationShell(),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    ProgressDashboardView(),
    PronunciationPracticeView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: Color(0xFF4F46E5)),
            label: 'Tiến Độ & Streak',
          ),
          NavigationDestination(
            icon: Icon(Icons.mic_none_outlined),
            selectedIcon: Icon(Icons.mic, color: Color(0xFF4F46E5)),
            label: 'Luyện Phát Âm AI',
          ),
        ],
      ),
    );
  }
}
