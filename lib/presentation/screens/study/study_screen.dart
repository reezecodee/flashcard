import 'package:flutter/material.dart';

class StudyScreen extends StatelessWidget {
  const StudyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Study Mode')),
      body: const Center(
        child: Text('Halaman Belajar akan kita buat setelah ini'),
      ),
    );
  }
}
