from flask import Blueprint, request, jsonify
from db import get_db
from datetime import datetime
from collections import defaultdict
from decorators import token_required

reports_bp = Blueprint('reports', __name__)

def row_to_dict(row):
    return dict(row) if row else None

@reports_bp.route('/reports/monthly', methods=['GET'])
@token_required
def get_monthly_report(current_user_id):
    try:
        year = request.args.get('year', datetime.now().year)
        month = request.args.get('month', datetime.now().month)

        try:
            year = int(year)
            month = int(month)
        except ValueError:
            return jsonify({'message': 'Invalid year or month format'}), 400

        if month < 1 or month > 12:
            return jsonify({'message': 'Month must be between 1 and 12'}), 400

        start_date = f'{year}-{month:02d}-01'

        if month == 12:
            end_date = f'{year + 1}-01-01'
        else:
            end_date = f'{year}-{month + 1:02d}-01'

        db = get_db()
        cursor = db.cursor()

        cursor.execute(
            'SELECT * FROM expenses WHERE user_id = ? AND date >= ? AND date < ? ORDER BY date ASC',
            (current_user_id, start_date, end_date)
        )
        expenses = [row_to_dict(row) for row in cursor.fetchall()]
        db.close()

        total_amount = sum(float(expense['amount']) for expense in expenses)

        category_totals = defaultdict(float)
        for expense in expenses:
            category_totals[expense['category']] += float(expense['amount'])

        category_breakdown = [
            {'category': category, 'amount': amount}
            for category, amount in category_totals.items()
        ]
        category_breakdown.sort(key=lambda x: x['amount'], reverse=True)

        return jsonify({
            'year': year,
            'month': month,
            'total_expenses': total_amount,
            'expense_count': len(expenses),
            'category_breakdown': category_breakdown,
            'expenses': expenses
        }), 200

    except Exception as e:
        return jsonify({'message': f'Error: {str(e)}'}), 500

@reports_bp.route('/reports/summary', methods=['GET'])
@token_required
def get_summary(current_user_id):
    try:
        db = get_db()
        cursor = db.cursor()

        cursor.execute(
            'SELECT * FROM expenses WHERE user_id = ?',
            (current_user_id,)
        )
        expenses = [row_to_dict(row) for row in cursor.fetchall()]
        db.close()

        total_amount = sum(float(expense['amount']) for expense in expenses)

        category_totals = defaultdict(float)
        for expense in expenses:
            category_totals[expense['category']] += float(expense['amount'])

        return jsonify({
            'total_expenses': total_amount,
            'expense_count': len(expenses),
            'categories': dict(category_totals)
        }), 200

    except Exception as e:
        return jsonify({'message': f'Error: {str(e)}'}), 500
