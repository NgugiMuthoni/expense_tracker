import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/db_service.dart';
import '../models/entry_models.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dbService = Provider.of<DBService>(context);
    const int userId = 1; 
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
            padding: const EdgeInsets.all(17.0),
            child: BarChart(
              BarChartData(
                barGroups: data,
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        return Text(
                          index >= entries.length ? '' : entries[index].date,
                          style: const TextStyle(
                            fontSize: 6,
                            color: Colors.black,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: const FlGridData(show: true),
                borderData: FlBorderData(show: false),
              ),
            ),
          );
        },
      ),
    );
  }

  List<BarChartGroupData> _createChartData(List<Entry> entries) {
    entries.where((entry) => entry.isIncome).toList();
    entries.where((entry) => !entry.isIncome).toList();

    List<BarChartGroupData> barGroups = [];

    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final barData = BarChartRodData(
        toY: entry.amount,
        color: entry.isIncome ? Colors.green.shade300 : Colors.red.shade300,
        width: 10,
      );

      barGroups.add(BarChartGroupData(
        x: i,
        barRods: [barData],
        showingTooltipIndicators: [0],
      ));
    }

    return barGroups;
  }
}
