import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/db_service.dart';
import '../models/entry_models.dart';
import '../models/user_model.dart';

class ReportScreen extends StatefulWidget {
  final User user;

  const ReportScreen({super.key, required this.user});

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String selectedMetric = 'Type'; // Default selected metric
  String selectedMonth =
      DateFormat.yMMM().format(DateTime.now()); // Current month
  RangeValues selectedRange = const RangeValues(0, 1000); // Default value range
  List<Entry> filteredEntries = [];

  @override
  Widget build(BuildContext context) {
    final dbService = Provider.of<DBService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Summary'),
      ),
      body: Column(
        children: [
          DropdownButton<String>(
            value: selectedMetric,
            items: ['Type', 'Month', 'Value Range']
                .map((metric) => DropdownMenuItem(
                      value: metric,
                      child: Text(metric),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedMetric = value!;
              });
            },
          ),
          const SizedBox(height: 20),
          if (selectedMetric == 'Type') _buildTypeFilter(),
          if (selectedMetric == 'Month') _buildMonthFilter(),
          if (selectedMetric == 'Value Range') _buildValueRangeFilter(),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              List<Entry> entries = await _fetchFilteredEntries(dbService);
              setState(() {
                filteredEntries = entries;
              });
            },
            child: const Text('Show Report'),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: filteredEntries.isEmpty
                ? const Center(child: Text('No entries found.'))
                : ListView.builder(
                    itemCount: filteredEntries.length,
                    itemBuilder: (context, index) {
                      final entry = filteredEntries[index];
                      return ListTile(
                        title: Text(entry.title),
                        subtitle: Text(
                          '${entry.isIncome ? 'Income' : 'Expense'}: \$${entry.amount.toStringAsFixed(2)} on ${entry.date}',
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeFilter() {
    return Column(
      children: [
        const Text('Select Entry Type'),
        DropdownButton<bool>(
          value: selectedMetric == 'Income' ? true : false,
          items: const [
            DropdownMenuItem(value: true, child: Text('Income')),
            DropdownMenuItem(value: false, child: Text('Expense')),
          ],
          onChanged: (value) {
            setState(() {
              selectedMetric = value! ? 'Income' : 'Expense';
            });
          },
        ),
      ],
    );
  }

  Widget _buildMonthFilter() {
    return Column(
      children: [
        const Text('Select Month'),
        DropdownButton<String>(
          value: selectedMonth,
          items: List.generate(
                  12,
                  (index) => DateFormat.yMMM()
                      .format(DateTime(DateTime.now().year, index + 1, 1)))
              .map((month) => DropdownMenuItem(
                    value: month,
                    child: Text(month),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              selectedMonth = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildValueRangeFilter() {
    return Column(
      children: [
        const Text('Select Value Range'),
        RangeSlider(
          values: selectedRange,
          min: 0,
          max: 5000000,
          divisions: 500,
          labels: RangeLabels(
            selectedRange.start.toStringAsFixed(0),
            selectedRange.end.toStringAsFixed(0),
          ),
          onChanged: (RangeValues values) {
            setState(() {
              selectedRange = values;
            });
          },
        ),
      ],
    );
  }

  Future<List<Entry>> _fetchFilteredEntries(DBService dbService) async {
    final allEntries = await dbService.getEntries(widget.user.id!);

    if (selectedMetric == 'Type') {
      bool isIncome = selectedMetric == 'Income';
      return allEntries.where((entry) => entry.isIncome == isIncome).toList();
    } else if (selectedMetric == 'Month') {
      return allEntries.where((entry) {
        final entryDate = DateTime.parse(entry.date);
        final entryMonth = DateFormat.yMMM().format(entryDate);
        return entryMonth == selectedMonth;
      }).toList();
    } else if (selectedMetric == 'Value Range') {
      return allEntries
          .where((entry) =>
              entry.amount >= selectedRange.start &&
              entry.amount <= selectedRange.end)
          .toList();
    }

    return allEntries;
  }
}
