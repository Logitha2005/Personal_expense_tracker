# Expense Tracker Application

A complete expense tracking application with Flutter frontend and Flask REST API backend, using Supabase PostgreSQL database.

## Project Structure

```
.
├── backend/              # Flask REST API
│   ├── app.py           # Main application entry point
│   ├── auth.py          # Authentication endpoints
│   ├── expenses.py      # Expense CRUD endpoints
│   ├── reports.py       # Monthly report endpoints
│   ├── requirements.txt # Python dependencies
│   └── .env.example     # Environment variables template
│
└── flutter_app/         # Flutter frontend
    ├── lib/
    │   ├── main.dart
    │   ├── models/
    │   ├── screens/
    │   ├── services/
    │   └── utils/
    ├── pubspec.yaml
    └── .env.example
```

## Features

### Authentication
- User signup with strong password validation
  - Minimum 8 characters
  - At least one uppercase letter
  - At least one lowercase letter
  - At least one digit
  - At least one special character
- User login with JWT token authentication
- Secure password hashing with bcrypt

### Expense Management
- Add new expenses with:
  - Category selection (dropdown)
  - Amount input with validation
  - Date picker (calendar)
  - Optional description
- Edit existing expenses
- Delete expenses with confirmation dialog
- View all expenses in a list
- Real-time expense total calculation

### Categories
- Food & Dining
- Transportation
- Shopping
- Entertainment
- Bills & Utilities
- Healthcare
- Education
- Travel
- Groceries
- Other

### Monthly Reports
- View expenses by month and year
- Total expenses for selected month
- Transaction count
- Category breakdown with:
  - Amount per category
  - Percentage of total
  - Visual progress bars
- Detailed list of all expenses in the month

### User Experience
- Alert messages for all actions (success/error)
- Loading indicators for async operations
- Pull-to-refresh on expense list
- Responsive design
- Clean and intuitive UI

## Backend Setup

### Prerequisites
- Python 3.8+
- Supabase account

### Installation

1. Navigate to backend directory:
```bash
cd backend
```

2. Create virtual environment:
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

3. Install dependencies:
```bash
pip install -r requirements.txt
```

4. Create `.env` file from template:
```bash
cp .env.example .env
```

5. Update `.env` with your credentials:
```
SUPABASE_URL=your_supabase_url
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
JWT_SECRET_KEY=your_jwt_secret_key
```

6. Run the server:
```bash
python app.py
```

The API will be available at `http://localhost:5000`

### API Endpoints

#### Authentication
- `POST /api/auth/signup` - Create new user account
- `POST /api/auth/login` - Login user

#### Expenses
- `GET /api/expenses` - Get all user expenses
- `POST /api/expenses` - Create new expense
- `PUT /api/expenses/<id>` - Update expense
- `DELETE /api/expenses/<id>` - Delete expense
- `GET /api/expenses/categories` - Get all categories

#### Reports
- `GET /api/reports/monthly?year=<year>&month=<month>` - Get monthly report
- `GET /api/reports/summary` - Get overall summary

## Frontend Setup

### Prerequisites
- Flutter SDK 3.0+
- Dart SDK
- Android Studio / Xcode (for mobile development)

### Installation

1. Navigate to flutter_app directory:
```bash
cd flutter_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Create `.env` file from template:
```bash
cp .env.example .env
```

4. Update `.env` with your API URL:
```
API_BASE_URL=http://localhost:5000/api
```

For Android emulator, use: `http://10.0.2.2:5000/api`
For iOS simulator, use: `http://localhost:5000/api`
For real device, use your computer's IP address

5. Run the app:
```bash
flutter run
```

## Database Schema

The database is managed by Supabase and includes:

### Tables

#### users
- `id` (uuid, primary key)
- `email` (text, unique)
- `password_hash` (text)
- `name` (text)
- `created_at` (timestamp)

#### expenses
- `id` (uuid, primary key)
- `user_id` (uuid, foreign key)
- `category` (text)
- `amount` (numeric)
- `date` (date)
- `description` (text)
- `created_at` (timestamp)
- `updated_at` (timestamp)

### Security
- Row Level Security (RLS) enabled on all tables
- Users can only access their own data
- JWT-based authentication

## Testing the Application

1. Start the Flask backend server
2. Launch the Flutter app
3. Create a new account using the signup screen
4. Add expenses with different categories
5. View your dashboard with total expenses
6. Edit or delete expenses
7. Check monthly reports for expense analysis

## Technologies Used

### Backend
- Flask - Web framework
- Flask-CORS - Cross-origin resource sharing
- PyJWT - JWT token handling
- bcrypt - Password hashing
- Supabase Python client - Database operations
- python-dotenv - Environment variable management

### Frontend
- Flutter - UI framework
- http - API communication
- shared_preferences - Local storage
- intl - Date formatting
- flutter_dotenv - Environment variables

### Database
- Supabase (PostgreSQL) - Database and authentication
- Row Level Security - Data access control

## Security Features

- Strong password validation
- Bcrypt password hashing
- JWT token authentication
- Row Level Security (RLS) policies
- Secure API endpoints
- Input validation on both frontend and backend

## Future Enhancements

- Budget planning and alerts
- Recurring expenses
- Multiple currency support
- Data export (CSV, PDF)
- Charts and graphs for expense analysis
- Expense categories customization
- Receipt photo upload
- Multi-user households/groups
