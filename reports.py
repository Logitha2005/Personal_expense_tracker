from flask import Blueprint, request, jsonify
from decorators import token_required
from db import get_db
from collections import defaultdict
from datetime import datetime

reports_bp = Blueprint('reports', __name__)

@reports_bp.route('/reports/monthly', methods=['GET'])
@token_required
def monthly_report(current_user_id):
    year = int(request.args.get('year', datetime.now().year))
    month = int(request.args.get('month', datetime.now().month))

    start_date = f'{year}-{month:02d}-01'
    end_date = f'{year}-{month+1:02d}-01' if month < 12 else f'{year+1}-01-01'

    db = get_db()
    cursor = db.cursor()
    cursor.execute('SELECT * FROM expenses WHERE user_id=? AND date >= ? AND date < ? ORDER BY date',
                   (current_user_id, start_date, end_date))
    expenses = [dict(row) for row in cursor.fetchall()]

    total = sum(e['amount'] for e in expenses)
    categories = defaultdict(float)
    for e in expenses:
        categories[e['category']] += e['amount']

    return jsonify({
        'year': year,
        'month': month,
        'total_expenses': total,
        'expense_count': len(expenses),
        'category_breakdown': dict(categories),
        'expenses': expenses
    }), 200
