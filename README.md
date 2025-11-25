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


