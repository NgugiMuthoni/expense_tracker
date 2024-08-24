import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import '../services/db_service.dart';
import '../models/entry_models.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dbService = Provider.of<DBService>(context);
    const int userId = 1; // Default userId for testing

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: FutureBuilder<List<Entry>>(
        future: dbService.getEntriesForStatistics(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data available.'));
          }

          final entries = snapshot.data!;
          final data = _createChartData(entries);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: charts.BarChart(
              data,
              animate: true,
              vertical: true,
              domainAxis: const charts.OrdinalAxisSpec(),
              primaryMeasureAxis: const charts.NumericAxisSpec(
                tickProviderSpec: charts.BasicNumericTickProviderSpec(
                  zeroBound: false,
                ),
                renderSpec: charts.GridlineRendererSpec(
                  labelStyle: charts.TextStyleSpec(
                    fontSize: 14,
                    color: charts.MaterialPalette.black,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<charts.Series<ChartData, String>> _createChartData(List<Entry> entries) {
    // Convert entries to ChartData
    final combinedEntries = entries
        .map((entry) => ChartData(entry.id.toString(), entry.amount,
            entry.isIncome ? Colors.green : Colors.red))
        .toList();

    // Sort entries by the order they were added (assumed to be by 'id')
    combinedEntries.sort((a, b) => int.parse(a.id).compareTo(int.parse(b.id)));

    return [
      charts.Series<ChartData, String>(
        id: 'Income & Expenses',
        colorFn: (ChartData data, _) =>
            charts.ColorUtil.fromDartColor(data.color),
        domainFn: (ChartData data, _) =>
            data.id, // Use the ID or another unique identifier
        measureFn: (ChartData data, _) => data.amount,
        data: combinedEntries,
      ),
    ];
  }
}

class ChartData {
  final String id; // Use the ID or another unique identifier
  final double amount;
  final Color color;

  ChartData(this.id, this.amount, this.color);
}
