from flask import Blueprint, request, jsonify, current_app
import jwt
import datetime
import re
import bcrypt
import uuid
from db import get_db

auth_bp = Blueprint('auth', __name__)

# Password validation function
def validate_password(password):
    if len(password) < 8:
        return False, "Password must be at least 8 characters long"
    if not re.search(r'[A-Z]', password):
        return False, "Password must contain at least one uppercase letter"
    if not re.search(r'[a-z]', password):
        return False, "Password must contain at least one lowercase letter"
    if not re.search(r'\d', password):
        return False, "Password must contain at least one digit"
    if not re.search(r'[!@#$%^&*(),.?":{}|<>]', password):
        return False, "Password must contain at least one special character"
    return True, "Password is valid"

# Signup route
@auth_bp.route('/signup', methods=['POST'])
def signup():
    try:
        data = request.get_json()
        email = data.get('email')
        password = data.get('password')
        name = data.get('name')

        if not email or not password or not name:
            return jsonify({'message': 'Email, password, and name are required'}), 400

        is_valid, message = validate_password(password)
        if not is_valid:
            return jsonify({'message': message}), 400

        db = get_db()
        cursor = db.cursor()

        cursor.execute('SELECT * FROM users WHERE email = ?', (email,))
        existing_user = cursor.fetchone()

        if existing_user:
            db.close()
            return jsonify({'message': 'User already exists'}), 409

        # Hash the password using bcrypt
        password_bytes = password.encode('utf-8')
        salt = bcrypt.gensalt()
        hashed_password = bcrypt.hashpw(password_bytes, salt)
        hashed_password_str = hashed_password.decode('utf-8')  # store in DB as string

        user_id = str(uuid.uuid4())

        cursor.execute(
            'INSERT INTO users (id, email, password_hash, name) VALUES (?, ?, ?, ?)',
            (user_id, email, hashed_password_str, name)
        )
        db.commit()
        db.close()

        # Generate JWT token
        token = jwt.encode({
            'user_id': user_id,
            'exp': datetime.datetime.utcnow() + datetime.timedelta(days=30)
        }, current_app.config['SECRET_KEY'], algorithm='HS256')

        return jsonify({
            'message': 'User created successfully',
            'token': token,
            'user': {
                'id': user_id,
                'email': email,
                'name': name
            }
        }), 201

    except Exception as e:
        return jsonify({'message': f'Error: {str(e)}'}), 500

# Login route
@auth_bp.route('/login', methods=['POST'])
def login():
    try:
        data = request.get_json()
        email = data.get('email')
        password = data.get('password')

        if not email or not password:
            return jsonify({'message': 'Email and password are required'}), 400

        db = get_db()
        cursor = db.cursor()
        cursor.execute('SELECT * FROM users WHERE email = ?', (email,))
        user = cursor.fetchone()
        db.close()

        if not user:
            return jsonify({'message': 'Invalid credentials'}), 401

        # Verify password
        password_bytes = password.encode('utf-8')
        hashed_bytes = user['password_hash'].encode('utf-8')
        if not bcrypt.checkpw(password_bytes, hashed_bytes):
            return jsonify({'message': 'Invalid credentials'}), 401

        # Generate JWT token
        token = jwt.encode({
            'user_id': user['id'],
            'exp': datetime.datetime.utcnow() + datetime.timedelta(days=30)
        }, current_app.config['SECRET_KEY'], algorithm='HS256')

        return jsonify({
            'message': 'Login successful',
            'token': token,
            'user': {
                'id': user['id'],
                'email': user['email'],
                'name': user['name']
            }
        }), 200

    except Exception as e:
        return jsonify({'message': f'Error: {str(e)}'}), 500
