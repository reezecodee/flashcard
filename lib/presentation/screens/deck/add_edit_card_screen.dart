import 'package:flutter/material.dart';
import '../../../core/constants//app_colors.dart';
import '../../../data/models/card_model.dart';
import '../../../data/repositories/card_repository.dart';

class AddEditCardScreen extends StatefulWidget {
  final int deckId;
  final CardModel? card; // jika null = mode tambah, jika ada = mode edit

  const AddEditCardScreen({super.key, required this.deckId, this.card});

  @override
  State<AddEditCardScreen> createState() => _AddEditCardScreenState();
}

class _AddEditCardScreenState extends State<AddEditCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _frontController = TextEditingController();
  final _backController = TextEditingController();
  final _cardRepo = CardRepository();

  @override
  void initState() {
    super.initState();

    // jika model edit, isi text field dengan data lama
    if (widget.card != null) {
      _frontController.text = widget.card!.front;
      _backController.text = widget.card!.back;
    }
  }

  Future<void> _saveCard() async {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now().millisecondsSinceEpoch;

      if (widget.card == null) {
        // -- mode tambah ---
        final newCard = CardModel(
          deckId: widget.deckId,
          front: _frontController.text,
          back: _backController.text,
          dueDate: now,
        );

        await _cardRepo.insertCard(newCard);
      } else {
        // -- mode edit --
        // copy object lama lalu ganti front & back saja
        // status SRS (interval, ease factor) jangan di reset
        final updateCard = widget.card!.copyWith(
          front: _frontController.text,
          back: _backController.text,
        );

        await _cardRepo.updateCard(updateCard);
      }

      if (mounted) {
        Navigator.pop(
          context,
          true,
        ); // kembali ke layar sebelumnya dan kasih sinyal sukses
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.card == null ? 'Tambah Kartu' : 'Edit Kartu'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // input depan soal
              TextFormField(
                controller: _frontController,
                decoration: const InputDecoration(
                  labelText: 'Bagian Depan (Pertanyaan)',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                validator: (val) => val!.isEmpty ? 'Tidak boleh kosong' : null,
              ),

              const SizedBox(height: 16),

              // input belakang (jawaban)
              TextFormField(
                controller: _backController,
                decoration: const InputDecoration(
                  labelText: 'Bagian Belakang (Jawaban)',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                validator: (val) => val!.isEmpty ? 'Tidak boleh kosong' : null,
              ),

              const SizedBox(height: 24),

              // tombol simpan
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  onPressed: _saveCard,
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text(
                    'Simpan Kartu',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
