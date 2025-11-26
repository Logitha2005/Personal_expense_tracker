class Expense {
  final String id;
  final String userId;
  final String category;
  final double amount;
  final DateTime date;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;

  Expense({
    required this.id,
    required this.userId,
    required this.category,
    required this.amount,
    required this.date,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      userId: json['user_id'],
      category: json['category'],
      amount: double.parse(json['amount'].toString()),
      date: DateTime.parse(json['date']),
      description: json['description'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String().split('T')[0],
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
