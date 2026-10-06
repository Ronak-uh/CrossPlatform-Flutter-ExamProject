import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/water_provider.dart';
import 'theme/app_theme.dart';
import 'screens/main_navigation_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WaterSaveApp());
}

class WaterSaveApp extends StatelessWidget {
  const WaterSaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WaterProvider(),
      child: Consumer<WaterProvider>(
        builder: (context, provider, child) {
          return MaterialApp(
            title: 'WaterSave',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const MainNavigationScreen(),
          );
        },
      ),
    );
  }
}
