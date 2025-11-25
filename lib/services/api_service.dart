import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  // Token management
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Auth
  Future<Map<String, dynamic>> signup(String email, String password, String name) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password, 'name': name}),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data.containsKey('token')) {
      await saveToken(data['token']);
    }
    return data;
  }

  // Expenses
  Future<Map<String, dynamic>> getExpenses() async {
    final response = await http.get(Uri.parse('$baseUrl/expenses'), headers: await getHeaders());
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> addExpense({
    required String category,
    required double amount,
    required String date,
    String description = '',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/expenses'),
      headers: await getHeaders(),
      body: jsonEncode({
        'category': category,
        'amount': amount,
        'date': date,
        'description': description,
      }),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> updateExpense({
    required String id,
    String? category,
    double? amount,
    String? date,
    String? description,
  }) async {
    final Map<String, dynamic> body = {};
    if (category != null) body['category'] = category;
    if (amount != null) body['amount'] = amount;
    if (date != null) body['date'] = date;
    if (description != null) body['description'] = description;

    final response = await http.put(
      Uri.parse('$baseUrl/expenses/$id'),
      headers: await getHeaders(),
      body: jsonEncode(body),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> deleteExpense(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/expenses/$id'), headers: await getHeaders());
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/expenses/categories'), headers: await getHeaders());
    return jsonDecode(response.body);
  }

  // Reports
  Future<Map<String, dynamic>> getMonthlyReport(int year, int month) async {
    final response = await http.get(Uri.parse('$baseUrl/reports/monthly?year=$year&month=$month'), headers: await getHeaders());
    return jsonDecode(response.body);
  }
}
