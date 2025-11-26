from flask import Blueprint, request, jsonify
from db import get_db
from datetime import datetime
import uuid
from decorators import token_required

expenses_bp = Blueprint('expenses', __name__)

def row_to_dict(row):
    return dict(row) if row else None

@expenses_bp.route('/expenses', methods=['GET'])
@token_required
def get_expenses(current_user_id):
    try:
        db = get_db()
        cursor = db.cursor()

        cursor.execute(
            'SELECT * FROM expenses WHERE user_id = ? ORDER BY date DESC',
            (current_user_id,)
        )
        expenses = [row_to_dict(row) for row in cursor.fetchall()]
        db.close()

        return jsonify({'expenses': expenses}), 200

    except Exception as e:
        return jsonify({'message': f'Error: {str(e)}'}), 500

@expenses_bp.route('/expenses', methods=['POST'])
@token_required
def add_expense(current_user_id):
    try:
        data = request.get_json()
        category = data.get('category')
        amount = data.get('amount')
        date = data.get('date')
        description = data.get('description', '')

        if not category or not amount or not date:
            return jsonify({'message': 'Category, amount, and date are required'}), 400

        try:
            amount = float(amount)
            if amount <= 0:
                return jsonify({'message': 'Amount must be greater than 0'}), 400
        except ValueError:
            return jsonify({'message': 'Invalid amount format'}), 400

        expense_id = str(uuid.uuid4())
        db = get_db()
        cursor = db.cursor()

        cursor.execute(
            'INSERT INTO expenses (id, user_id, category, amount, date, description) VALUES (?, ?, ?, ?, ?, ?)',
            (expense_id, current_user_id, category, amount, date, description)
        )
        db.commit()

        cursor.execute('SELECT * FROM expenses WHERE id = ?', (expense_id,))
        expense = row_to_dict(cursor.fetchone())
        db.close()

        return jsonify({
            'message': 'Expense added successfully',
            'expense': expense
        }), 201

    except Exception as e:
        return jsonify({'message': f'Error: {str(e)}'}), 500

@expenses_bp.route('/expenses/<expense_id>', methods=['PUT'])
@token_required
def update_expense(current_user_id, expense_id):
    try:
        db = get_db()
        cursor = db.cursor()

        cursor.execute(
            'SELECT * FROM expenses WHERE id = ? AND user_id = ?',
            (expense_id, current_user_id)
        )
        expense = cursor.fetchone()

        if not expense:
            db.close()
            return jsonify({'message': 'Expense not found'}), 404

        data = request.get_json()
        update_fields = []
        update_values = []

        if 'category' in data:
            update_fields.append('category = ?')
            update_values.append(data['category'])
        if 'amount' in data:
            try:
                amount = float(data['amount'])
                if amount <= 0:
                    db.close()
                    return jsonify({'message': 'Amount must be greater than 0'}), 400
                update_fields.append('amount = ?')
                update_values.append(amount)
            except ValueError:
                db.close()
                return jsonify({'message': 'Invalid amount format'}), 400
        if 'date' in data:
            update_fields.append('date = ?')
            update_values.append(data['date'])
        if 'description' in data:
            update_fields.append('description = ?')
            update_values.append(data['description'])

        if not update_fields:
            db.close()
            return jsonify({'message': 'No data to update'}), 400

        update_fields.append('updated_at = CURRENT_TIMESTAMP')
        update_values.append(expense_id)

        query = f"UPDATE expenses SET {', '.join(update_fields)} WHERE id = ?"
        cursor.execute(query, update_values)
        db.commit()

        cursor.execute('SELECT * FROM expenses WHERE id = ?', (expense_id,))
        updated_expense = row_to_dict(cursor.fetchone())
        db.close()

        return jsonify({
            'message': 'Expense updated successfully',
            'expense': updated_expense
        }), 200

    except Exception as e:
        return jsonify({'message': f'Error: {str(e)}'}), 500

@expenses_bp.route('/expenses/<expense_id>', methods=['DELETE'])
@token_required
def delete_expense(current_user_id, expense_id):
    try:
        db = get_db()
        cursor = db.cursor()

        cursor.execute(
            'SELECT * FROM expenses WHERE id = ? AND user_id = ?',
            (expense_id, current_user_id)
        )
        expense = cursor.fetchone()

        if not expense:
            db.close()
            return jsonify({'message': 'Expense not found'}), 404

        cursor.execute('DELETE FROM expenses WHERE id = ?', (expense_id,))
        db.commit()
        db.close()

        return jsonify({'message': 'Expense deleted successfully'}), 200

    except Exception as e:
        return jsonify({'message': f'Error: {str(e)}'}), 500

@expenses_bp.route('/expenses/categories', methods=['GET'])
@token_required
def get_categories(current_user_id):
    categories = [
        'Food & Dining',
        'Transportation',
        'Shopping',
        'Entertainment',
        'Bills & Utilities',
        'Healthcare',
        'Education',
        'Travel',
        'Groceries',
        'Other'
    ]
    return jsonify({'categories': categories}), 200
