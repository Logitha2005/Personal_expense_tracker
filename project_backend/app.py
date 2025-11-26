from flask import Flask, request, jsonify
from flask_cors import CORS
from functools import wraps
import bcrypt
import jwt
import datetime
import os
import sqlite3
from pathlib import Path
from dotenv import load_dotenv
from db import init_db

load_dotenv()

app = Flask(__name__)
CORS(app)

app.config['SECRET_KEY'] = os.getenv('JWT_SECRET_KEY', 'your-secret-key-change-in-production')

DB_PATH = Path(__file__).parent / 'expense_tracker.db'

def get_db():
    db = sqlite3.connect(str(DB_PATH))
    db.row_factory = sqlite3.Row
    return db

def init_db():
    db = get_db()
    cursor = db.cursor()

    cursor.execute('''
        CREATE TABLE IF NOT EXISTS users (
            id TEXT PRIMARY KEY,
            email TEXT UNIQUE NOT NULL,
            password_hash TEXT NOT NULL,
            name TEXT NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ''')

    cursor.execute('''
        CREATE TABLE IF NOT EXISTS expenses (
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            category TEXT NOT NULL,
            amount REAL NOT NULL CHECK (amount > 0),
            date TEXT NOT NULL,
            description TEXT DEFAULT '',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        )
    ''')

    cursor.execute('CREATE INDEX IF NOT EXISTS idx_users_email ON users(email)')
    cursor.execute('CREATE INDEX IF NOT EXISTS idx_expenses_user_id ON expenses(user_id)')
    cursor.execute('CREATE INDEX IF NOT EXISTS idx_expenses_date ON expenses(date)')

    db.commit()
    db.close()

init_db()

def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        token = request.headers.get('Authorization')

        if not token:
            return jsonify({'message': 'Token is missing'}), 401

        try:
            if token.startswith('Bearer '):
                token = token[7:]
            data = jwt.decode(token, app.config['SECRET_KEY'], algorithms=['HS256'])
            current_user_id = data['user_id']
        except jwt.ExpiredSignatureError:
            return jsonify({'message': 'Token has expired'}), 401
        except jwt.InvalidTokenError:
            return jsonify({'message': 'Token is invalid'}), 401

        return f(current_user_id, *args, **kwargs)

    return decorated

from auth import auth_bp
from expenses import expenses_bp
from reports import reports_bp

app.register_blueprint(auth_bp, url_prefix='/api/auth')
app.register_blueprint(expenses_bp, url_prefix='/api')
app.register_blueprint(reports_bp, url_prefix='/api')

@app.route('/api/health', methods=['GET'])
def health():
    return jsonify({'status': 'ok'}), 200

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
