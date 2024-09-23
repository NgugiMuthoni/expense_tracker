import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/db_service.dart';
import '../models/user_model.dart';
import '../models/entry_models.dart';

class ExpensesScreen extends StatelessWidget {
  final User user;

  const ExpensesScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final dbService = Provider.of<DBService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
      ),
      body: FutureBuilder<List<Entry>>(
        future: dbService.getEntries(user.id!), // Fetch all entries for the user
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No expenses found.'));
          }

          final expenses = snapshot.data!.where((entry) => !entry.isIncome).toList(); // Filter expenses

          return ListView.builder(
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              final entry = expenses[index];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                color: Colors.red.shade50,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16.0),
                  title: Text(entry.title),
                  subtitle: Text(
                    'Expense: \$${entry.amount.toStringAsFixed(2)} on ${entry.date}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    color: Colors.red,
                    onPressed: () async {
                      await dbService.deleteEntry(entry.id!);
                      // Refresh the screen after deletion
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
