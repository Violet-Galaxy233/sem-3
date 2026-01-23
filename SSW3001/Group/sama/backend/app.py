"""
SamaRasa Backend Server
Flask API for AI-powered elderly care assistant
Enhanced with external API integrations
"""

from flask import Flask, request, jsonify, render_template, send_from_directory
from flask_cors import CORS
from datetime import datetime, timedelta
import os
import sys

# Add backend to path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from database import Database
from chatbot import ChatBot
from api_services import api_services

app = Flask(__name__,
            template_folder='../templates',
            static_folder='../static')
CORS(app)

# Initialize database and chatbot with API services
db = Database()
chatbot = ChatBot(api_services=api_services)

# Create a default user for testing
def init_default_user():
    """Initialize default user if none exists"""
    user = db.get_user(1)
    if not user:
        user_id = db.create_user("Ahmad bin Abdullah", 72, "en")
        # Add a caregiver
        db.add_caregiver("Siti (Daughter)", "+60123456789", "siti@example.com", user_id)
        # Add sample medication
        db.add_medication(user_id, "Blood Pressure Medicine", "1 tablet", "08:00", "daily")
        db.add_medication(user_id, "Diabetes Medicine", "1 tablet", "20:00", "daily")
        print(f"Created default user with ID: {user_id}")

init_default_user()

# ============= Routes =============

@app.route('/')
def index():
    """Main application page"""
    return render_template('index.html')

@app.route('/dashboard')
def dashboard():
    """Family dashboard page"""
    return render_template('dashboard.html')

# ============= API Endpoints =============

# User Management
@app.route('/api/user/<int:user_id>', methods=['GET'])
def get_user(user_id):
    """Get user information"""
    user = db.get_user(user_id)
    if user:
        return jsonify({'success': True, 'user': user})
    return jsonify({'success': False, 'error': 'User not found'}), 404

@app.route('/api/user', methods=['POST'])
def create_user():
    """Create new user"""
    data = request.json
    user_id = db.create_user(
        data.get('name'),
        data.get('age'),
        data.get('language', 'en')
    )
    return jsonify({'success': True, 'user_id': user_id})

# Chat Module (FR-1)
@app.route('/api/chat', methods=['POST'])
def chat():
    """Handle chat messages"""
    data = request.json
    user_id = data.get('user_id', 1)
    message = data.get('message', '')
    language = data.get('language', 'en')

    # Get chatbot response
    result = chatbot.get_response(message, language)

    # Save to database
    db.save_chat(user_id, message, result['response'], language)

    # Handle actions
    additional_data = {}
    if result.get('action') == 'check_medication':
        medications = db.get_user_medications(user_id)
        additional_data['medications'] = medications
    elif result.get('action') == 'trigger_sos':
        alert_id = db.create_alert(user_id, 'SOS')
        additional_data['alert_id'] = alert_id

    return jsonify({
        'success': True,
        'response': result['response'],
        'intent': result['intent'],
        **additional_data
    })

@app.route('/api/chat/history/<int:user_id>', methods=['GET'])
def get_chat_history(user_id):
    """Get chat history"""
    limit = request.args.get('limit', 10, type=int)
    history = db.get_chat_history(user_id, limit)
    return jsonify({'success': True, 'history': history})

@app.route('/api/chat/greeting/<int:user_id>', methods=['GET'])
def get_greeting(user_id):
    """Get personalized greeting"""
    user = db.get_user(user_id)
    if not user:
        return jsonify({'success': False, 'error': 'User not found'}), 404

    language = user.get('language', 'en')
    greeting = chatbot.get_daily_greeting(user['name'], language)

    return jsonify({'success': True, 'greeting': greeting})

# Medication Module (FR-2)
@app.route('/api/medications/<int:user_id>', methods=['GET'])
def get_medications(user_id):
    """Get all medications for user"""
    medications = db.get_user_medications(user_id)
    return jsonify({'success': True, 'medications': medications})

@app.route('/api/medications', methods=['POST'])
def add_medication():
    """Add new medication"""
    data = request.json
    med_id = db.add_medication(
        data['user_id'],
        data['medication_name'],
        data['dosage'],
        data['time'],
        data.get('frequency', 'daily')
    )
    return jsonify({'success': True, 'medication_id': med_id})

@app.route('/api/medications/<int:med_id>/confirm', methods=['POST'])
def confirm_medication(med_id):
    """Confirm medication taken"""
    data = request.json
    status = data.get('status', 'taken')
    db.log_medication_taken(med_id, status)
    return jsonify({'success': True})

@app.route('/api/medications/reminder/<int:user_id>', methods=['GET'])
def get_medication_reminder(user_id):
    """Get current medication reminder"""
    medications = db.get_user_medications(user_id)
    user = db.get_user(user_id)
    language = user.get('language', 'en') if user else 'en'

    # Check if any medication is due now (within 30 minutes)
    current_time = datetime.now()
    due_medications = []

    for med in medications:
        med_time = datetime.strptime(med['time'], '%H:%M').time()
        med_datetime = datetime.combine(current_time.date(), med_time)

        time_diff = abs((med_datetime - current_time).total_seconds() / 60)

        if time_diff <= 30:  # Within 30 minutes
            message = chatbot.get_medication_reminder_message(
                med['medication_name'],
                language
            )
            due_medications.append({
                **med,
                'reminder_message': message
            })

    return jsonify({
        'success': True,
        'due_medications': due_medications
    })

# Health Diary Module (FR-3)
@app.route('/api/diary/<int:user_id>', methods=['GET'])
def get_diary_entries(user_id):
    """Get health diary entries"""
    days = request.args.get('days', 7, type=int)
    entries = db.get_diary_entries(user_id, days)
    return jsonify({'success': True, 'entries': entries})

@app.route('/api/diary', methods=['POST'])
def add_diary_entry():
    """Add health diary entry"""
    data = request.json
    entry_id = db.add_diary_entry(
        data['user_id'],
        data.get('date', datetime.now().date().isoformat()),
        data.get('mood'),
        data.get('sleep_hours'),
        data.get('exercise_minutes'),
        data.get('notes', '')
    )
    return jsonify({'success': True, 'entry_id': entry_id})

@app.route('/api/diary/summary/<int:user_id>', methods=['GET'])
def get_diary_summary(user_id):
    """Get weekly summary of health diary"""
    entries = db.get_diary_entries(user_id, 7)

    if not entries:
        return jsonify({'success': True, 'summary': None})

    # Calculate averages
    total_sleep = sum(e['sleep_hours'] or 0 for e in entries)
    total_exercise = sum(e['exercise_minutes'] or 0 for e in entries)
    moods = [e['mood'] for e in entries if e['mood']]

    summary = {
        'entries_count': len(entries),
        'avg_sleep_hours': round(total_sleep / len(entries), 1) if entries else 0,
        'total_exercise_minutes': total_exercise,
        'avg_exercise_minutes': round(total_exercise / len(entries), 1) if entries else 0,
        'mood_distribution': {
            'happy': moods.count('happy'),
            'neutral': moods.count('neutral'),
            'sad': moods.count('sad'),
            'tired': moods.count('tired'),
        },
        'entries': entries
    }

    return jsonify({'success': True, 'summary': summary})

# Fall Risk Assessment Module (FR-4)
@app.route('/api/fall-assessment', methods=['POST'])
def submit_fall_assessment():
    """Submit fall risk assessment"""
    data = request.json
    user_id = data['user_id']
    answers = data['answers']

    # Calculate score (simple scoring: sum of yes answers)
    score = sum(1 for answer in answers.values() if answer == 'yes')

    # Determine risk level
    if score <= 3:
        risk_level = 'Low'
    elif score <= 6:
        risk_level = 'Medium'
    else:
        risk_level = 'High'

    # Save assessment
    assessment_id = db.save_fall_assessment(user_id, score, risk_level, answers)

    # Generate recommendations
    recommendations = get_fall_risk_recommendations(risk_level, data.get('language', 'en'))

    return jsonify({
        'success': True,
        'assessment_id': assessment_id,
        'score': score,
        'risk_level': risk_level,
        'recommendations': recommendations
    })

@app.route('/api/fall-assessment/<int:user_id>', methods=['GET'])
def get_fall_assessment(user_id):
    """Get latest fall risk assessment"""
    assessment = db.get_latest_fall_assessment(user_id)
    if assessment:
        language = request.args.get('language', 'en')
        recommendations = get_fall_risk_recommendations(assessment['risk_level'], language)
        return jsonify({
            'success': True,
            'assessment': assessment,
            'recommendations': recommendations
        })
    return jsonify({'success': True, 'assessment': None})

def get_fall_risk_recommendations(risk_level, language='en'):
    """Get recommendations based on risk level"""
    recommendations = {
        'en': {
            'Low': [
                "Continue with regular light exercise",
                "Maintain good lighting in your home",
                "Wear proper footwear with good grip",
                "Keep walkways clear of obstacles"
            ],
            'Medium': [
                "Consider balance exercises daily",
                "Install handrails in bathrooms",
                "Remove loose rugs and mats",
                "Use a walking aid if needed",
                "Consult your doctor about your medications"
            ],
            'High': [
                "Consult your doctor immediately",
                "Use mobility aids at all times",
                "Install grab bars throughout your home",
                "Consider a personal alert system",
                "Arrange for regular checkups",
                "Never walk in dimly lit areas"
            ]
        },
        'bm': {
            'Low': [
                "Teruskan senaman ringan secara kerap",
                "Pastikan rumah mempunyai cahaya yang baik",
                "Pakai kasut yang sesuai dengan cengkaman baik",
                "Pastikan laluan berjalan bebas dari halangan"
            ],
            'Medium': [
                "Cuba senaman keseimbangan setiap hari",
                "Pasang pegangan tangan di bilik air",
                "Buang permaidani longgar",
                "Guna alat bantuan berjalan jika perlu",
                "Berjumpa doktor tentang ubat-ubatan anda"
            ],
            'High': [
                "Berjumpa doktor dengan segera",
                "Guna alat bantuan bergerak setiap masa",
                "Pasang pegangan di seluruh rumah",
                "Pertimbangkan sistem penggera peribadi",
                "Aturkan pemeriksaan kesihatan berkala",
                "Jangan berjalan di tempat gelap"
            ]
        }
    }
    return recommendations.get(language, {}).get(risk_level, [])

# Emergency Alert Module (FR-5)
@app.route('/api/emergency/alert', methods=['POST'])
def create_emergency_alert():
    """Create emergency SOS alert with real notifications"""
    data = request.json
    user_id = data['user_id']
    alert_type = data.get('alert_type', 'SOS')
    location = data.get('location', '')

    alert_id = db.create_alert(user_id, alert_type, location)

    # Get user and caregiver info for notification
    user = db.get_user(user_id)
    caregivers = db.get_caregivers(user_id)

    # Send real notifications via API services
    notification_results = api_services.send_emergency_alert(
        user_info=user,
        alert_type=alert_type,
        location=location
    )

    return jsonify({
        'success': True,
        'alert_id': alert_id,
        'message': 'Emergency alert sent to caregivers',
        'caregivers_notified': len(caregivers),
        'notifications': {
            'sms_sent': notification_results.get('sms', {}).get('success', False),
            'email_sent': notification_results.get('email', {}).get('success', False),
            'call_made': notification_results.get('call', {}).get('success', False)
        }
    })

@app.route('/api/emergency/alerts', methods=['GET'])
def get_emergency_alerts():
    """Get all active emergency alerts"""
    user_id = request.args.get('user_id', type=int)
    alerts = db.get_active_alerts(user_id)
    return jsonify({'success': True, 'alerts': alerts})

@app.route('/api/emergency/alert/<int:alert_id>/resolve', methods=['POST'])
def resolve_emergency_alert(alert_id):
    """Resolve emergency alert"""
    db.resolve_alert(alert_id)
    return jsonify({'success': True, 'message': 'Alert resolved'})

# Caregiver/Family Dashboard (FR-6)
@app.route('/api/dashboard/<int:user_id>', methods=['GET'])
def get_dashboard_data(user_id):
    """Get comprehensive dashboard data for caregiver"""
    user = db.get_user(user_id)
    if not user:
        return jsonify({'success': False, 'error': 'User not found'}), 404

    # Get all relevant data
    medications = db.get_user_medications(user_id)
    diary_entries = db.get_diary_entries(user_id, 7)
    fall_assessment = db.get_latest_fall_assessment(user_id)
    active_alerts = db.get_active_alerts(user_id)
    caregivers = db.get_caregivers(user_id)
    chat_history = db.get_chat_history(user_id, 5)

    dashboard_data = {
        'user': user,
        'medications': medications,
        'diary_entries': diary_entries,
        'fall_assessment': fall_assessment,
        'active_alerts': active_alerts,
        'caregivers': caregivers,
        'recent_chats': chat_history,
        'statistics': {
            'total_medications': len(medications),
            'active_alerts': len(active_alerts),
            'diary_entries_this_week': len(diary_entries),
        }
    }

    return jsonify({'success': True, 'dashboard': dashboard_data})

# Utility endpoints
@app.route('/api/languages', methods=['GET'])
def get_languages():
    """Get supported languages"""
    return jsonify({
        'success': True,
        'languages': [
            {'code': 'en', 'name': 'English'},
            {'code': 'bm', 'name': 'Bahasa Malaysia'}
        ]
    })

@app.route('/api/encouragement/<int:user_id>', methods=['GET'])
def get_encouragement(user_id):
    """Get random encouragement message"""
    user = db.get_user(user_id)
    language = user.get('language', 'en') if user else 'en'
    message = chatbot.get_encouragement(language)
    return jsonify({'success': True, 'message': message})

# API Status check
@app.route('/api/status', methods=['GET'])
def api_status():
    """Get status of all API integrations"""
    status = api_services.get_api_status()
    return jsonify({
        'success': True,
        'api_services': status
    })

# Health check
@app.route('/api/health', methods=['GET'])
def health_check():
    """API health check"""
    return jsonify({
        'success': True,
        'status': 'healthy',
        'timestamp': datetime.now().isoformat()
    })

if __name__ == '__main__':
    print("=" * 50)
    print("SamaRasa Backend Server Starting...")
    print("=" * 50)
    print("Elderly Care AI Assistant")
    print("Bilingual Support: English & Bahasa Malaysia")
    print("=" * 50)
    print("Server URL: http://localhost:5001")
    print("=" * 50)
    app.run(debug=True, host='0.0.0.0', port=5001)
