import 'package:flutter/material.dart';
import '../services/api_service.dart';

class MonthlyReportScreen extends StatefulWidget {
  final ApiService apiService;

  const MonthlyReportScreen({Key? key, required this.apiService}) : super(key: key);

  @override
  State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends State<MonthlyReportScreen> {
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;
  Map<String, dynamic>? report;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReport();
  }

  Future<void> _fetchReport() async {
    setState(() => _isLoading = true);
    final result = await widget.apiService.getMonthlyReport(selectedYear, selectedMonth);
    setState(() {
      report = result.containsKey('total_expenses') ? result : null;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Monthly Report')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : report == null
              ? const Center(child: Text('No data found'))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Month: $selectedMonth/$selectedYear'),
                      Text('Total Expenses: \$${report!['total_expenses']}'),
                      Text('Expense Count: ${report!['expense_count']}'),
                      const SizedBox(height: 20),
                      const Text('Category Breakdown:', style: TextStyle(fontWeight: FontWeight.bold)),
                      ...List<Widget>.from(report!['category_breakdown'].map<Widget>((cat) => Text('${cat['category']}: \$${cat['amount']}'))),
                    ],
                  ),
                ),
    );
  }
}
