import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'design_system/theme.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) {
        final state = AppState();
        state.loadTransactions();
        state.refreshUserLocation();
        return state;
      },
      child: const KabadiwalaApp(),
    ),
  );
}

class KabadiwalaApp extends StatelessWidget {
  const KabadiwalaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kabadiwala Connect',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const HomeScreen(),
    );
  }
}
