import 'package:expense_tracker/screens/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/db_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => DBService(),
        ),
      ],
      child: MaterialApp(
        title: 'Expense Tracker',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const AuthScreen(),
      ),
    );
  }
}
