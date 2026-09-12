import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:media_kit/media_kit.dart';

import 'core/constants/app_colors.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/library/presentation/screens/netflix_style_library_screen.dart';
import 'features/network/presentation/screens/network_hub_screen.dart';
import 'features/settings/presentation/settings_screen.dart';
import 'features/subtitles/presentation/subtitle_studio_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize media_kit native backend (libmpv fallback)
  MediaKit.ensureInitialized();

  runApp(const ProviderScope(child: VelaPlayerApp()));
}

class VelaPlayerApp extends StatelessWidget {
  const VelaPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vela Player - مشغل وسائط وترجمة ذكية',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.accent,
          surface: AppColors.surface,
        ),
        textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surface,
          elevation: 0,
        ),
      ),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: MainShell(),
      ),
    );
  }
}

/// Main shell with 5-destination bottom navigation (Section 15.2: Home | Library | Studio | Network | Settings)
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    NetflixStyleLibraryScreen(),
    SubtitleStudioScreen(),
    NetworkHubScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: Colors.white10, width: 0.5)),
        ),
        child: NavigationBar(
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.primary.withValues(alpha: 0.25),
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home, color: AppColors.primaryLight),
              label: 'الرئيسية',
            ),
            NavigationDestination(
              icon: Icon(Icons.movie_filter_outlined),
              selectedIcon: Icon(
                Icons.movie_filter_rounded,
                color: AppColors.primaryLight,
              ),
              label: 'المكتبة الذكية',
            ),
            NavigationDestination(
              icon: Icon(Icons.subtitles_outlined),
              selectedIcon: Icon(
                Icons.subtitles_rounded,
                color: AppColors.primaryLight,
              ),
              label: 'استوديو الترجمة',
            ),
            NavigationDestination(
              icon: Icon(Icons.hub_outlined),
              selectedIcon: Icon(
                Icons.hub_rounded,
                color: AppColors.primaryLight,
              ),
              label: 'الشبكات',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(
                Icons.settings_rounded,
                color: AppColors.primaryLight,
              ),
              label: 'الإعدادات',
            ),
          ],
        ),
      ),
    );
  }
}
