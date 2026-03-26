import 'package:flutter/material.dart';
import 'services/localization_service.dart';
import 'services/auth_service.dart';
import 'screens/app_shell.dart';
import 'screens/login_screen.dart';

/// Main entry point of the Flutter application
/// This function is called when the app starts
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalizationService.init();
  await AuthService.init();
  runApp(const AgroAssistApp());  // Run the app
}

/// Root widget of the application
/// This is a StatelessWidget because it doesn't change
class AgroAssistApp extends StatelessWidget {
  const AgroAssistApp({super.key});

  ThemeData _buildTheme() {
    const seedColor = Color(0xFF1D9A6C);
    final colorScheme = ColorScheme.fromSeed(seedColor: seedColor);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF4F7F5),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 1.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        indicatorColor: colorScheme.primaryContainer,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LocalizationService.languageNotifier,
      builder: (context, language, _) {
        return MaterialApp(
          title: LocalizationService.tr('AgroAssist'),
          debugShowCheckedModeBanner: false,
          theme: _buildTheme(),
          home: AuthService.session == null ? const LoginScreen() : const AppShell(),
        );
      },
    );
  }
}

