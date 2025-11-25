import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'services/api_service.dart';

void main() {
  final apiService = ApiService(baseUrl: "http://127.0.0.1:5000");
  runApp(ExpenseTrackerApp(apiService: apiService));
}

class ExpenseTrackerApp extends StatelessWidget {
  final ApiService apiService;

  const ExpenseTrackerApp({Key? key, required this.apiService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,
      home: LoginScreen(apiService: apiService),
    );
  }
}
