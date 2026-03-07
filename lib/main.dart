import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/app_shell.dart';
import 'services/auth_service.dart';
import 'services/localization_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalizationService.init();
  await AuthService.init();
  runApp(const AgroAssistApp());
}

class AgroAssistApp extends StatelessWidget {
  const AgroAssistApp({super.key});

  static const Color primaryGreen = Color(0xFF2ECC71);
  static const Color darkGreen = Color(0xFF27AE60);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LocalizationService.languageNotifier,
      builder: (context, language, _) {
        return MaterialApp(
          title: 'AgroAssist',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.green,
            primaryColor: primaryGreen,
            colorScheme: ColorScheme.fromSeed(
              seedColor: primaryGreen,
              primary: primaryGreen,
              secondary: darkGreen,
            ),
            scaffoldBackgroundColor: const Color(0xFFF5F7FA),
            appBarTheme: const AppBarTheme(
              backgroundColor: primaryGreen,
              foregroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
            ),
            cardTheme: CardThemeData(
              elevation: 1,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.white,
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: primaryGreen, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.red),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
            chipTheme: ChipThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            ),
            dividerTheme: const DividerThemeData(
              space: 1,
              thickness: 1,
              color: Color(0xFFEEEEEE),
            ),
            useMaterial3: true,
          ),
          home: AuthService.session == null
              ? const LoginScreen()
              : const AppShell(),
        );
      },
    );
  }
}
