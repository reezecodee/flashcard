import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'presentation/state_management/deck_provider.dart';
import 'presentation/state_management/study_session_provider.dart';
import 'presentation/screens/home/home_screen.dart';
import 'core/constants/app_colors.dart';

void main() async {
  // pastikan binding initialized sebelum akses ke native code (SQLite)
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // multiprovider: mendaftarkan semua controller agar bisa di akses widget manapun
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DeckProvider()),
        ChangeNotifierProvider(create: (_) => StudySessionProvider()),
      ],
      child: MaterialApp(
        title: 'Flashcard App',
        theme: ThemeData(
          primaryColor: AppColors.primary,
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: AppColors.primary,
            secondary: AppColors.secondary,
          ),
          scaffoldBackgroundColor: AppColors.backround,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
