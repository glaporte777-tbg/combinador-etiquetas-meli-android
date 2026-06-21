import 'package:flutter/material.dart';

import 'home_screen.dart';

void main() {
  runApp(const CombinadorApp());
}

class CombinadorApp extends StatelessWidget {
  const CombinadorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Combinar Etiquetas ML',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFFE600),
          onPrimary: Color(0xFF1A1D24),
          surface: Color(0xFF1A1D24),
          onSurface: Color(0xFFE8EAED),
        ),
        scaffoldBackgroundColor: const Color(0xFF0F1115),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
