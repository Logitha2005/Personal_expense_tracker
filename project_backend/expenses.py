from flask import Blueprint, request, jsonify
from decorators import token_required
from db import get_db
from datetime import datetime

expenses_bp = Blueprint('expenses', __name__)

@expenses_bp.route('/expenses', methods=['GET'])
@token_required
def get_expenses(current_user_id):
    db = get_db()
    cursor = db.cursor()
    cursor.execute('SELECT * FROM expenses WHERE user_id=? ORDER BY date DESC', (current_user_id,))
    expenses = [dict(row) for row in cursor.fetchall()]
    return jsonify({'expenses': expenses}), 200

@expenses_bp.route('/expenses', methods=['POST'])
@token_required
def add_expense(current_user_id):
    data = request.get_json()
    category = data.get('category')
    amount = data.get('amount')
    date = data.get('date')
    description = data.get('description', '')

    if not category or not amount or not date:
        return jsonify({'message': 'Category, amount, and date are required'}), 400

    try:
        amount = float(amount)
    except ValueError:
        return jsonify({'message': 'Invalid amount format'}), 400

    db = get_db()
    cursor = db.cursor()
    cursor.execute('INSERT INTO expenses (user_id, category, amount, date, description) VALUES (?, ?, ?, ?, ?)',
                   (current_user_id, category, amount, date, description))
    db.commit()
    return jsonify({'message': 'Expense added successfully'}), 201

# Update & delete routes can follow the same logic
