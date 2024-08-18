// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:charts_flutter/flutter.dart' as charts;
// import '../services/db_service.dart';
// import '../models/entry_models.dart';

// class StatisticsScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final dbService = Provider.of<DBService>(context);
//     final int userId = 1; // Default userId for testing

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Statistics'),
//       ),
//       body: FutureBuilder<List<Entry>>(
//         future: dbService.getEntriesForStatistics(userId),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return Center(child: Text('No data available.'));
//           }

//           final entries = snapshot.data!;
//           final data = _createChartData(entries);

//           return Padding(
//             padding: EdgeInsets.all(16.0),
//             child: charts.BarChart(
//               data,
//               animate: true,
//               vertical: false,
//               domainAxis: charts.OrdinalAxisSpec(),
//               primaryMeasureAxis: charts.NumericAxisSpec(
//                 tickProviderSpec: charts.BasicNumericTickProviderSpec(
//                   zeroBound: false,
//                 ),
//                 renderSpec: charts.GridlineRendererSpec(
//                   labelStyle: charts.TextStyleSpec(
//                     fontSize: 14,
//                     color: charts.MaterialPalette.black,
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   List<charts.Series<ChartData, String>> _createChartData(List<Entry> entries) {
//     final incomeData = entries
//         .where((entry) => entry.isIncome)
//         .take(14)
//         .toList();
//     final expenseData = entries
//         .where((entry) => !entry.isIncome)
//         .take(14)
//         .toList();

//     final incomeSeries = incomeData.map((entry) => ChartData(entry.date, entry.amount, Colors.green)).toList();
//     final expenseSeries = expenseData.map((entry) => ChartData(entry.date, entry.amount, Colors.red)).toList();

//     return [
//       charts.Series<ChartData, String>(
//         id: 'Income',
//         colorFn: (_, __) => charts.ColorUtil.fromDartColor(Colors.green),
//         domainFn: (ChartData data, _) => data.date,
//         measureFn: (ChartData data, _) => data.amount,
//         data: incomeSeries,
//       ),
//       charts.Series<ChartData, String>(
//         id: 'Expenses',
//         colorFn: (_, __) => charts.ColorUtil.fromDartColor(Colors.red),
//         domainFn: (ChartData data, _) => data.date,
//         measureFn: (ChartData data, _) => data.amount,
//         data: expenseSeries,
//       ),
//     ];
//   }
// }

// class ChartData {
//   final String date;
//   final double amount;
//   final Color color;

//   ChartData(this.date, this.amount, this.color);
// }
