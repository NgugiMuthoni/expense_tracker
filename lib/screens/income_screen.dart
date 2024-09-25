import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/db_service.dart';
import '../models/user_model.dart';
import '../models/entry_models.dart';

class IncomesScreen extends StatelessWidget {
  final User user;

  const IncomesScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final dbService = Provider.of<DBService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Incomes'),
      ),
      body: FutureBuilder<List<Entry>>(
        future: dbService.getEntries(user.id!), 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No incomes found.'));
          }

          final incomes = snapshot.data!.where((entry) => entry.isIncome).toList(); 

          return ListView.builder(
            itemCount: incomes.length,
            itemBuilder: (context, index) {
              final entry = incomes[index];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                color: Colors.green.shade50,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16.0),
                  title: Text(entry.title),
                  subtitle: Text(
                    'Income: \$${entry.amount.toStringAsFixed(2)} on ${entry.date}',
                    style: const TextStyle(color: Colors.green),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    color: Colors.red,
                    onPressed: () async {
                      await dbService.deleteEntry(entry.id!);

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
