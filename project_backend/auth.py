from flask import Blueprint, request, jsonify
from passlib.hash import bcrypt
import jwt
import datetime
from db import get_db
from decorators import token_required
import os

SECRET_KEY = os.getenv('JWT_SECRET_KEY', 'your-secret-key-change-in-production')

auth_bp = Blueprint('auth', __name__)

@auth_bp.route('/signup', methods=['POST'])
def signup():
    data = request.get_json()
    full_name = data.get('name')
    email = data.get('email')
    password = data.get('password')

    if not full_name or not email or not password:
        return jsonify({'message': 'All fields are required'}), 400

    hashed_password = bcrypt.hash(password)
    db = get_db()
    cursor = db.cursor()
    try:
        cursor.execute('INSERT INTO users (full_name, email, password) VALUES (?, ?, ?)',
                       (full_name, email, hashed_password))
        db.commit()
        return jsonify({'message': 'User created successfully'}), 201
    except Exception as e:
        return jsonify({'message': f'Error: {str(e)}'}), 400

@auth_bp.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    email = data.get('email')
    password = data.get('password')

    db = get_db()
    cursor = db.cursor()
    cursor.execute('SELECT * FROM users WHERE email=?', (email,))
    user = cursor.fetchone()

    if not user or not bcrypt.verify(password, user['password']):
        return jsonify({'message': 'Invalid email or password'}), 401

    token = jwt.encode({'user_id': user['id'], 
                        'exp': datetime.datetime.utcnow() + datetime.timedelta(hours=12)},
                       SECRET_KEY, algorithm='HS256')

    return jsonify({
        'message': 'Login successful',
        'token': token,
        'user': {'id': user['id'], 'full_name': user['full_name'], 'email': user['email']}
    }), 200
