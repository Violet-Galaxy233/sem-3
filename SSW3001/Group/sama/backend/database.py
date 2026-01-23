"""
SamaRasa Database Models
Defines SQLite database schema for all modules
"""

import sqlite3
from datetime import datetime
import json
import os

class Database:
    def __init__(self, db_path='data/samarasa.db'):
        # Get the project root directory (parent of backend)
        backend_dir = os.path.dirname(os.path.abspath(__file__))
        project_root = os.path.dirname(backend_dir)
        self.db_path = os.path.join(project_root, db_path)
        self.init_database()

    def get_connection(self):
        conn = sqlite3.connect(self.db_path)
        conn.row_factory = sqlite3.Row
        return conn

    def init_database(self):
        """Initialize all database tables"""
        conn = self.get_connection()
        cursor = conn.cursor()

        # Users table (elderly users)
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS users (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                age INTEGER,
                language TEXT DEFAULT 'en',
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        ''')

        # Caregivers table
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS caregivers (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                phone TEXT,
                email TEXT,
                user_id INTEGER,
                FOREIGN KEY (user_id) REFERENCES users(id)
            )
        ''')

        # Medication reminders
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS medications (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER NOT NULL,
                medication_name TEXT NOT NULL,
                dosage TEXT,
                time TEXT NOT NULL,
                frequency TEXT,
                active INTEGER DEFAULT 1,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (user_id) REFERENCES users(id)
            )
        ''')

        # Medication logs (confirmation)
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS medication_logs (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                medication_id INTEGER NOT NULL,
                taken_at TIMESTAMP,
                status TEXT DEFAULT 'pending',
                FOREIGN KEY (medication_id) REFERENCES medications(id)
            )
        ''')

        # Health diary entries
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS health_diary (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER NOT NULL,
                date DATE NOT NULL,
                mood TEXT,
                sleep_hours REAL,
                exercise_minutes INTEGER,
                notes TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (user_id) REFERENCES users(id)
            )
        ''')

        # Fall risk assessments
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS fall_assessments (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER NOT NULL,
                assessment_date DATE NOT NULL,
                score INTEGER NOT NULL,
                risk_level TEXT NOT NULL,
                answers TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (user_id) REFERENCES users(id)
            )
        ''')

        # Chat history
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS chat_history (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER NOT NULL,
                message TEXT NOT NULL,
                response TEXT NOT NULL,
                language TEXT DEFAULT 'en',
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (user_id) REFERENCES users(id)
            )
        ''')

        # Emergency alerts
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS emergency_alerts (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER NOT NULL,
                alert_type TEXT DEFAULT 'SOS',
                status TEXT DEFAULT 'active',
                location TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                resolved_at TIMESTAMP,
                FOREIGN KEY (user_id) REFERENCES users(id)
            )
        ''')

        conn.commit()
        conn.close()

    # User operations
    def create_user(self, name, age, language='en'):
        conn = self.get_connection()
        cursor = conn.cursor()
        cursor.execute(
            'INSERT INTO users (name, age, language) VALUES (?, ?, ?)',
            (name, age, language)
        )
        user_id = cursor.lastrowid
        conn.commit()
        conn.close()
        return user_id

    def get_user(self, user_id):
        conn = self.get_connection()
        cursor = conn.cursor()
        cursor.execute('SELECT * FROM users WHERE id = ?', (user_id,))
        user = cursor.fetchone()
        conn.close()
        return dict(user) if user else None

    # Medication operations
    def add_medication(self, user_id, medication_name, dosage, time, frequency):
        conn = self.get_connection()
        cursor = conn.cursor()
        cursor.execute(
            'INSERT INTO medications (user_id, medication_name, dosage, time, frequency) VALUES (?, ?, ?, ?, ?)',
            (user_id, medication_name, dosage, time, frequency)
        )
        med_id = cursor.lastrowid
        conn.commit()
        conn.close()
        return med_id

    def get_user_medications(self, user_id):
        conn = self.get_connection()
        cursor = conn.cursor()
        cursor.execute(
            'SELECT * FROM medications WHERE user_id = ? AND active = 1 ORDER BY time',
            (user_id,)
        )
        medications = [dict(row) for row in cursor.fetchall()]
        conn.close()
        return medications

    def log_medication_taken(self, medication_id, status='taken'):
        conn = self.get_connection()
        cursor = conn.cursor()
        cursor.execute(
            'INSERT INTO medication_logs (medication_id, taken_at, status) VALUES (?, ?, ?)',
            (medication_id, datetime.now(), status)
        )
        conn.commit()
        conn.close()

    # Health diary operations
    def add_diary_entry(self, user_id, date, mood, sleep_hours, exercise_minutes, notes=''):
        conn = self.get_connection()
        cursor = conn.cursor()
        cursor.execute(
            'INSERT INTO health_diary (user_id, date, mood, sleep_hours, exercise_minutes, notes) VALUES (?, ?, ?, ?, ?, ?)',
            (user_id, date, mood, sleep_hours, exercise_minutes, notes)
        )
        entry_id = cursor.lastrowid
        conn.commit()
        conn.close()
        return entry_id

    def get_diary_entries(self, user_id, days=7):
        conn = self.get_connection()
        cursor = conn.cursor()
        cursor.execute(
            'SELECT * FROM health_diary WHERE user_id = ? ORDER BY date DESC LIMIT ?',
            (user_id, days)
        )
        entries = [dict(row) for row in cursor.fetchall()]
        conn.close()
        return entries

    # Fall risk assessment operations
    def save_fall_assessment(self, user_id, score, risk_level, answers):
        conn = self.get_connection()
        cursor = conn.cursor()
        cursor.execute(
            'INSERT INTO fall_assessments (user_id, assessment_date, score, risk_level, answers) VALUES (?, ?, ?, ?, ?)',
            (user_id, datetime.now().date(), score, risk_level, json.dumps(answers))
        )
        assessment_id = cursor.lastrowid
        conn.commit()
        conn.close()
        return assessment_id

    def get_latest_fall_assessment(self, user_id):
        conn = self.get_connection()
        cursor = conn.cursor()
        cursor.execute(
            'SELECT * FROM fall_assessments WHERE user_id = ? ORDER BY assessment_date DESC LIMIT 1',
            (user_id,)
        )
        assessment = cursor.fetchone()
        conn.close()
        if assessment:
            result = dict(assessment)
            result['answers'] = json.loads(result['answers'])
            return result
        return None

    # Chat history operations
    def save_chat(self, user_id, message, response, language='en'):
        conn = self.get_connection()
        cursor = conn.cursor()
        cursor.execute(
            'INSERT INTO chat_history (user_id, message, response, language) VALUES (?, ?, ?, ?)',
            (user_id, message, response, language)
        )
        conn.commit()
        conn.close()

    def get_chat_history(self, user_id, limit=10):
        conn = self.get_connection()
        cursor = conn.cursor()
        cursor.execute(
            'SELECT * FROM chat_history WHERE user_id = ? ORDER BY created_at DESC LIMIT ?',
            (user_id, limit)
        )
        history = [dict(row) for row in cursor.fetchall()]
        conn.close()
        return history[::-1]  # Reverse to chronological order

    # Emergency alert operations
    def create_alert(self, user_id, alert_type='SOS', location=''):
        conn = self.get_connection()
        cursor = conn.cursor()
        cursor.execute(
            'INSERT INTO emergency_alerts (user_id, alert_type, location) VALUES (?, ?, ?)',
            (user_id, alert_type, location)
        )
        alert_id = cursor.lastrowid
        conn.commit()
        conn.close()
        return alert_id

    def get_active_alerts(self, user_id=None):
        conn = self.get_connection()
        cursor = conn.cursor()
        if user_id:
            cursor.execute(
                'SELECT * FROM emergency_alerts WHERE user_id = ? AND status = "active" ORDER BY created_at DESC',
                (user_id,)
            )
        else:
            cursor.execute(
                'SELECT * FROM emergency_alerts WHERE status = "active" ORDER BY created_at DESC'
            )
        alerts = [dict(row) for row in cursor.fetchall()]
        conn.close()
        return alerts

    def resolve_alert(self, alert_id):
        conn = self.get_connection()
        cursor = conn.cursor()
        cursor.execute(
            'UPDATE emergency_alerts SET status = "resolved", resolved_at = ? WHERE id = ?',
            (datetime.now(), alert_id)
        )
        conn.commit()
        conn.close()

    # Caregiver operations
    def add_caregiver(self, name, phone, email, user_id):
        conn = self.get_connection()
        cursor = conn.cursor()
        cursor.execute(
            'INSERT INTO caregivers (name, phone, email, user_id) VALUES (?, ?, ?, ?)',
            (name, phone, email, user_id)
        )
        caregiver_id = cursor.lastrowid
        conn.commit()
        conn.close()
        return caregiver_id

    def get_caregivers(self, user_id):
        conn = self.get_connection()
        cursor = conn.cursor()
        cursor.execute(
            'SELECT * FROM caregivers WHERE user_id = ?',
            (user_id,)
        )
        caregivers = [dict(row) for row in cursor.fetchall()]
        conn.close()
        return caregivers
