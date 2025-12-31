import 'package:flutter/material.dart';
import '../../../data/models/deck_model.dart';

class DeckDetailScreen extends StatelessWidget {
  final DeckModel deck;
  const DeckDetailScreen({super.key, required this.deck});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(deck.name)),
      body: const Center(child: Text('List kartu akan ada di sini')),
    );
  }
}
