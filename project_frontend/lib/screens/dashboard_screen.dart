import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'add_expense_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  final ApiService apiService;

  const DashboardScreen({Key? key, required this.apiService}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, dynamic>> expenses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchExpenses();
  }

  Future<void> _fetchExpenses() async {
    setState(() => _isLoading = true);
    final result = await widget.apiService.getExpenses();
    setState(() {
      if (result.containsKey('expenses')) {
        expenses = List<Map<String, dynamic>>.from(result['expenses']);
      } else {
        expenses = [];
      }
      _isLoading = false;
    });
  }

  void _deleteExpense(String expenseId) async {
    final result = await widget.apiService.deleteExpense(expenseId);
    if (result.containsKey('message')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
      _fetchExpenses();
    }
  }

  void _logout() async {
    await widget.apiService.clearToken();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen(apiService: widget.apiService)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : expenses.isEmpty
              ? const Center(child: Text('No expenses found'))
              : ListView.builder(
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenses[index];
                    return ListTile(
                      title: Text('${expense['category']} - \$${expense['amount']}'),
                      subtitle: Text(expense['date']),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteExpense(expense['id'].toString()),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddExpenseScreen(apiService: widget.apiService),
            ),
          ).then((_) => _fetchExpenses());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
