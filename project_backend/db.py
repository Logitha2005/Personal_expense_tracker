import sqlite3

DATABASE = 'expense_tracker.db'

def get_db():
    conn = sqlite3.connect(DATABASE)
    conn.row_factory = sqlite3.Row
    return conn

def init_db():
    db = get_db()
    cursor = db.cursor()
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS users (
            id TEXT PRIMARY KEY,
            full_name TEXT NOT NULL,
            email TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL
        )
    ''')
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS expenses (
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            category TEXT,
            amount REAL,
            date TEXT,
            description TEXT
        )
    ''')
    db.commit()
    db.close()
