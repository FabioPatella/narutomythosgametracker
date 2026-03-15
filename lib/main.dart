import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const NarutoGameTracker());
}

class NarutoGameTracker extends StatelessWidget {
  const NarutoGameTracker({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Naruto Mythos TCG Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.orange[800],
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange[900]!,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
