from flask import Flask
from flask_cors import CORS
from db import init_db
from auth import auth_bp
from expenses import expenses_bp
from reports import reports_bp

app = Flask(__name__)
CORS(app)

# Initialize DB tables
init_db()

# Register blueprints
app.register_blueprint(auth_bp, url_prefix='/api/auth')
app.register_blueprint(expenses_bp, url_prefix='/api')
app.register_blueprint(reports_bp, url_prefix='/api')

@app.route('/api/health', methods=['GET'])
def health():
    return {'status': 'ok'}, 200

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
