import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:5000/api';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  static Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> signup(String email, String password, String name) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'name': name,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      await saveToken(data['token']);
      return {'success': true, 'data': data};
    } else {
      return {'success': false, 'message': data['message']};
    }
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      await saveToken(data['token']);
      return {'success': true, 'data': data};
    } else {
      return {'success': false, 'message': data['message']};
    }
  }

  static Future<Map<String, dynamic>> getExpenses() async {
    final headers = await getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/expenses'),
      headers: headers,
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {'success': true, 'data': data['expenses']};
    } else {
      return {'success': false, 'message': data['message']};
    }
  }

  static Future<Map<String, dynamic>> addExpense(
      String category, double amount, String date, String description) async {
    final headers = await getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/expenses'),
      headers: headers,
      body: jsonEncode({
        'category': category,
        'amount': amount,
        'date': date,
        'description': description,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return {'success': true, 'data': data};
    } else {
      return {'success': false, 'message': data['message']};
    }
  }

  static Future<Map<String, dynamic>> updateExpense(
      String expenseId, Map<String, dynamic> updates) async {
    final headers = await getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/expenses/$expenseId'),
      headers: headers,
      body: jsonEncode(updates),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {'success': true, 'data': data};
    } else {
      return {'success': false, 'message': data['message']};
    }
  }

  static Future<Map<String, dynamic>> deleteExpense(String expenseId) async {
    final headers = await getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/expenses/$expenseId'),
      headers: headers,
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {'success': true, 'data': data};
    } else {
      return {'success': false, 'message': data['message']};
    }
  }

  static Future<Map<String, dynamic>> getCategories() async {
    final headers = await getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/expenses/categories'),
      headers: headers,
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {'success': true, 'data': data['categories']};
    } else {
      return {'success': false, 'message': data['message']};
    }
  }

  static Future<Map<String, dynamic>> getMonthlyReport(int year, int month) async {
    final headers = await getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/reports/monthly?year=$year&month=$month'),
      headers: headers,
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {'success': true, 'data': data};
    } else {
      return {'success': false, 'message': data['message']};
    }
  }
}
