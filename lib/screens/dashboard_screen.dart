import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../services/db_service.dart';
import '../models/user_model.dart';
import '../models/entry_models.dart';
import 'add_entry_screen.dart';
import 'statistics_screen.dart'; // Import your statistics screen

class DashboardScreen extends StatelessWidget {
  final User user;

  const DashboardScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final dbService = Provider.of<DBService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Column(
        children: [
          // FutureBuilder to get total income, expenses, and savings
          FutureBuilder<Map<String, double>>(
            future: _getTotals(dbService),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData) {
                return const Center(child: Text('No data available.'));
              }

              final totals = snapshot.data!;
              final double incomeTotal = totals['incomeTotal']!;
              final double expensesTotal = totals['expensesTotal']!;
              final double savings = incomeTotal - expensesTotal;
              final savingsColor =
                  savings >= 0 ? Colors.blue.shade200 : Colors.yellow.shade200;
              final savingsText = savings >= 0
                  ? 'Savings: \$${savings.toStringAsFixed(2)}'
                  : 'Savings: -\$${(-savings).toStringAsFixed(2)}';

              return Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // First Row: Savings
                    Container(
                      color: savingsColor,
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        savingsText,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10), // Space between rows
                    // Second Row: Income and Expenses
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            color: Colors.red.shade200,
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Total Expenses: \$${expensesTotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            color: Colors.green.shade200,
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Total Income: \$${incomeTotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          Expanded(
            child: FutureBuilder<List<Entry>>(
              future: dbService.getEntries(user.id!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No entries found.'));
                }

                final entries = snapshot.data!;

                return ListView.builder(
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      color: entry.isIncome
                          ? Colors.green.shade50
                          : Colors.red.shade50,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16.0),
                        title: Text(entry.title),
                        subtitle: Text(
                          '${entry.isIncome ? 'Income' : 'Expense'}: \$${entry.amount.toStringAsFixed(2)} on ${entry.date}',
                          style: TextStyle(
                            color: entry.isIncome ? Colors.green : Colors.red,
                          ),
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
          ),
        ],
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        backgroundColor: Colors.blue,
        overlayOpacity: 0.4,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.add_chart_rounded),
            label: 'Statistics',
            backgroundColor: Colors.green,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StatisticsScreen(),
                ),
              );
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.receipt_long_rounded),
            label: 'New Entry',
            backgroundColor: Colors.blue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEntryScreen(user: user),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<Map<String, double>> _getTotals(DBService dbService) async {
    final entries = await dbService.getEntries(user.id!);
    double incomeTotal = 0.0;
    double expensesTotal = 0.0;

    for (var entry in entries) {
      if (entry.isIncome) {
        incomeTotal += entry.amount;
      } else {
        expensesTotal += entry.amount;
      }
    }

    return {
      'incomeTotal': incomeTotal,
      'expensesTotal': expensesTotal,
    };
  }
}
