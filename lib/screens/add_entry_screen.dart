import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/db_service.dart';
import '../models/entry_models.dart';
import '../models/user_model.dart';

class AddEntryScreen extends StatefulWidget {
  final User user;

  const AddEntryScreen({super.key, required this.user});

  @override
  _AddEntryScreenState createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final DateTime _selectedDate = DateTime.now();
  bool _isIncome = true;

  void _submit() async {
    if (_titleController.text.isEmpty || _amountController.text.isEmpty) {
      return; 
    }

    final title = _titleController.text;
    final amount = double.tryParse(_amountController.text);
    final date = _selectedDate.toIso8601String();

    if (amount != null) {
      final entry = Entry(
        title: title,
        amount: amount,
        date: date,
        userId: widget.user.id!,
        isIncome: _isIncome,
      );

      final dbService = Provider.of<DBService>(context, listen: false);
      await dbService.insertEntry(entry);

      Navigator.pop(context); // Return to previous screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Entry'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ToggleButtons(
                  isSelected: [_isIncome, !_isIncome],
                  onPressed: (index) {
                    setState(() {
                      _isIncome = index == 0;
                    });
                  },
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text('Income', style: TextStyle(fontSize: 16)),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text('Expense', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Add Entry'),
            ),
          ],
        ),
      ),
    );
  }
}
