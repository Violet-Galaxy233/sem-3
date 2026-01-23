# SamaRasa - AI-Powered Elderly Care Assistant

![SamaRasa Logo](https://img.shields.io/badge/SamaRasa-Elderly%20Care-blue)
![Python](https://img.shields.io/badge/Python-3.8+-green)
![Flask](https://img.shields.io/badge/Flask-3.0-red)
![License](https://img.shields.io/badge/License-Educational-yellow)

**SamaRasa** is an AI-powered bilingual (English/Bahasa Malaysia) assistant designed to support Malaysia's ageing society. The system provides health management, medication reminders, companionship, and caregiver alerts through an elderly-friendly voice-interactive interface.

---

## 📋 Table of Contents

- [Features](#features)
- [System Architecture](#system-architecture)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Modules](#modules)
- [API Documentation](#api-documentation)
- [Accessibility Features](#accessibility-features)
- [Development Team](#development-team)
- [References](#references)

---

## ✨ Features

### Core Modules (All 6 Functional Requirements Implemented)

1. **AI Chat Companion** (FR-1)
   - Rule-based conversational AI with empathy dialogue
   - Bilingual support (English & Bahasa Malaysia)
   - Context-aware responses
   - Voice input simulation ready

2. **Medication Reminder** (FR-2)
   - Schedule-based reminders
   - Voice and visual alerts
   - Confirmation tracking
   - Time-based notifications

3. **Health Diary** (FR-3)
   - Daily mood tracking
   - Sleep and exercise logging
   - Weekly summary charts
   - Trend analysis

4. **Fall Risk Assessment** (FR-4)
   - 10-question assessment tool
   - Risk level calculation (Low/Medium/High)
   - Personalized recommendations
   - Progress tracking

5. **Emergency Alert (SOS)** (FR-5)
   - One-button emergency trigger
   - Caregiver notifications
   - Real-time alert tracking
   - Alert resolution system

6. **Family Dashboard** (FR-6)
   - Comprehensive monitoring interface
   - Medication schedule view
   - Health diary overview
   - Active alerts management
   - Chat history review

---

## 🏗️ System Architecture

```
┌─────────────────────────────────────────┐
│         Frontend (HTML/CSS/JS)          │
│  • Elderly-friendly UI (Large fonts)    │
│  • Bilingual Interface (EN/BM)          │
│  • Voice input ready                    │
└─────────────────────────────────────────┘
                    ↓ ↑
┌─────────────────────────────────────────┐
│         Flask Backend (Python)          │
│  • RESTful API                          │
│  • Business Logic                       │
│  • AI Chatbot Engine                    │
└─────────────────────────────────────────┘
                    ↓ ↑
┌─────────────────────────────────────────┐
│         SQLite Database                 │
│  • User data                            │
│  • Health records                       │
│  • Chat history                         │
└─────────────────────────────────────────┘
```

### Tech Stack

| Component | Technology |
|-----------|-----------|
| Backend | Python 3.8+ with Flask |
| Database | SQLite 3 |
| Frontend | HTML5, CSS3, JavaScript (ES6+) |
| UI Framework | Custom CSS (Accessibility-focused) |
| API | RESTful JSON API |

---

## 📦 Requirements

### System Requirements
- Python 3.8 or higher
- Modern web browser (Chrome, Firefox, Safari, Edge)
- 100MB free disk space
- Internet connection (for initial setup)

### Python Dependencies
```
Flask==3.0.0
flask-cors==4.0.0
```

---

## 🚀 Installation

### 1. Clone or Download the Project

```bash
cd /path/to/sama
```

### 2. Install Python Dependencies

```bash
pip install -r requirements.txt
```

Or install manually:
```bash
pip install Flask==3.0.0 flask-cors==4.0.0
```

### 3. Initialize Database

The database will be automatically created on first run. The system creates a default user:
- **Name:** Ahmad bin Abdullah
- **Age:** 72 years
- **Language:** English
- **Sample medications and caregiver data included**

### 4. Start the Server

```bash
cd backend
python app.py
```

The server will start on `http://localhost:5000`

You should see:
```
==================================================
SamaRasa Backend Server Starting...
==================================================
Elderly Care AI Assistant
Bilingual Support: English & Bahasa Malaysia
==================================================
```

---

## 💻 Usage

### Accessing the Application

1. **Elderly User Interface**
   - Open browser: `http://localhost:5000`
   - Main interface with large buttons and clear navigation
   - Switch language using EN/Bahasa toggle

2. **Family Dashboard**
   - Open browser: `http://localhost:5000/dashboard`
   - Comprehensive monitoring interface for caregivers
   - Real-time alert management

### Basic Workflow

#### For Elderly Users:

1. **Start Chat**
   - Click "Chat Companion" icon
   - Type or use voice input
   - AI responds with empathy and helpful information

2. **Check Medications**
   - Click "Medications" icon
   - View scheduled medications
   - Confirm when taken

3. **Log Health Diary**
   - Click "Health Diary" icon
   - Select mood, enter sleep hours, exercise minutes
   - View weekly summary

4. **Assess Fall Risk**
   - Click "Fall Risk" icon
   - Answer 10 yes/no questions
   - Receive risk level and recommendations

5. **Emergency Alert**
   - Click large red "🆘 EMERGENCY" button
   - Confirm alert
   - Caregivers are notified

#### For Caregivers:

1. **Monitor Overview**
   - Open family dashboard
   - View statistics at a glance
   - Check active alerts

2. **Review Health Data**
   - View medication compliance
   - Check health diary trends
   - Monitor fall risk assessments

3. **Respond to Alerts**
   - See emergency alerts immediately
   - Review details
   - Resolve when addressed

---

## 📱 Modules

### 1. AI Chat Companion

**Features:**
- Natural language understanding
- Intent detection (greeting, health, medication, mood, etc.)
- Empathetic responses
- Bilingual conversation

**Example Interactions:**

English:
```
User: "Hello, how are you?"
AI: "Good day! I'm here to help you. How are you feeling today?"

User: "I need to take my medicine"
AI: "Let me check your medication schedule for you."
```

Bahasa Malaysia:
```
User: "Apa khabar?"
AI: "Selamat sejahtera! Saya di sini untuk membantu anda."

User: "Saya perlu makan ubat"
AI: "Mari saya semak jadual ubat anda."
```

### 2. Medication Reminder

**Features:**
- Time-based scheduling
- Visual and text alerts
- Confirmation tracking
- Automatic reminders every 5 minutes

**Database Schema:**
```sql
medications (
    id, user_id, medication_name, dosage,
    time, frequency, active, created_at
)
```

### 3. Health Diary

**Features:**
- Mood tracking (Happy, Neutral, Sad, Tired)
- Sleep hours logging
- Exercise minutes tracking
- Weekly summary statistics

**Statistics Calculated:**
- Average sleep hours
- Average exercise minutes
- Mood distribution
- Trend analysis

### 4. Fall Risk Assessment

**10-Question Assessment:**
1. Past falls history
2. Walking aid usage
3. Unsteady walking
4. Chair push-up difficulty
5. Fear of falling
6. Stair climbing problems
7. Balance issues
8. Dizziness from medication
9. Leg weakness
10. Vision problems

**Risk Levels:**
- **Low** (0-3 yes answers): Continue normal activities with basic precautions
- **Medium** (4-6 yes answers): Implement safety measures and exercises
- **High** (7-10 yes answers): Immediate doctor consultation recommended

### 5. Emergency Alert (SOS)

**Features:**
- One-button activation
- Confirmation dialog
- Instant caregiver notification
- Alert tracking and resolution

**Alert Flow:**
```
User triggers → Confirmation → Alert created →
Caregivers notified → Dashboard updated →
Caregiver resolves → System logs resolution
```

### 6. Family Dashboard

**Features:**
- Real-time monitoring
- Alert management
- Medication schedule view
- Health diary overview
- Chat history review
- Caregiver contact information

---

## 🔌 API Documentation

### Base URL
```
http://localhost:5000/api
```

### Endpoints

#### User Management

**GET /api/user/{user_id}**
```json
Response: {
    "success": true,
    "user": {
        "id": 1,
        "name": "Ahmad bin Abdullah",
        "age": 72,
        "language": "en"
    }
}
```

#### Chat Module

**POST /api/chat**
```json
Request: {
    "user_id": 1,
    "message": "Hello",
    "language": "en"
}

Response: {
    "success": true,
    "response": "Good day! I'm here to help you.",
    "intent": "greeting"
}
```

**GET /api/chat/history/{user_id}?limit=10**

**GET /api/chat/greeting/{user_id}**

#### Medication Module

**GET /api/medications/{user_id}**

**POST /api/medications**
```json
Request: {
    "user_id": 1,
    "medication_name": "Aspirin",
    "dosage": "1 tablet",
    "time": "08:00",
    "frequency": "daily"
}
```

**POST /api/medications/{med_id}/confirm**

**GET /api/medications/reminder/{user_id}**

#### Health Diary Module

**GET /api/diary/{user_id}?days=7**

**POST /api/diary**
```json
Request: {
    "user_id": 1,
    "mood": "happy",
    "sleep_hours": 7.5,
    "exercise_minutes": 30,
    "notes": "Feeling good today"
}
```

**GET /api/diary/summary/{user_id}**

#### Fall Assessment Module

**POST /api/fall-assessment**
```json
Request: {
    "user_id": 1,
    "answers": {
        "0": "yes",
        "1": "no",
        ...
    },
    "language": "en"
}

Response: {
    "success": true,
    "score": 3,
    "risk_level": "Low",
    "recommendations": [...]
}
```

**GET /api/fall-assessment/{user_id}**

#### Emergency Alert Module

**POST /api/emergency/alert**
```json
Request: {
    "user_id": 1,
    "alert_type": "SOS"
}

Response: {
    "success": true,
    "alert_id": 1,
    "caregivers_notified": 1
}
```

**GET /api/emergency/alerts?user_id=1**

**POST /api/emergency/alert/{alert_id}/resolve**

#### Dashboard Module

**GET /api/dashboard/{user_id}**
```json
Response: {
    "success": true,
    "dashboard": {
        "user": {...},
        "medications": [...],
        "diary_entries": [...],
        "fall_assessment": {...},
        "active_alerts": [...],
        "caregivers": [...],
        "recent_chats": [...],
        "statistics": {...}
    }
}
```

---

## ♿ Accessibility Features

### WCAG 2.1 Compliance

1. **Visual Accessibility**
   - Large fonts (≥18pt base, up to 40pt headings)
   - High contrast color scheme
   - Clear visual hierarchy
   - Large icons (≥48px)

2. **Navigation**
   - Maximum 2-level navigation depth
   - Large touch targets (≥60px minimum height)
   - Clear labeling with icons + text
   - Simple, intuitive layout

3. **Interaction**
   - Large, clearly labeled buttons
   - Confirmation dialogs for critical actions
   - Visual feedback for all interactions
   - Keyboard navigation support

4. **Language**
   - Bilingual support (English/Bahasa Malaysia)
   - Simple, clear language
   - Consistent terminology
   - Voice input ready

5. **Responsive Design**
   - Adapts to different screen sizes
   - Mobile-friendly interface
   - Maintains readability across devices

---

## 👥 Development Team

| Name | ID | Role | Responsibility |
|------|----|------|----------------|
| Yue Chenghao | 227154 | Project Manager | Architecture, coordination |
| Zhao Yunu | 227225 | UI/UX | Wireframes, storyboards |
| Fan Haoqi | 227259 | Front-End | Interface implementation |
| Hua Jie | 226758 | Testing | QA, validation |
| Wang Kailun | 227046 | Back-End | AI logic, data flow |
| Zhang Yaoyuan | 226557 | AI Interaction | Chat design |

---

## 📂 Project Structure

```
sama/
├── backend/
│   ├── app.py              # Flask application
│   ├── database.py         # Database models & operations
│   └── chatbot.py          # AI chatbot logic
├── templates/
│   ├── index.html          # Main elderly interface
│   └── dashboard.html      # Family dashboard
├── static/
│   ├── css/
│   │   ├── main.css        # Main styles
│   │   └── dashboard.css   # Dashboard styles
│   └── js/
│       ├── main.js         # Main app logic
│       ├── dashboard.js    # Dashboard logic
│       └── translations.js # Bilingual translations
├── data/
│   └── samarasa.db         # SQLite database (auto-generated)
├── requirements.txt        # Python dependencies
├── requirements.md         # Project SRS document
└── README.md              # This file
```

---

## 🧪 Testing

### Manual Testing Checklist

- [ ] Chat responds appropriately in both languages
- [ ] Medication reminders trigger at scheduled times
- [ ] Health diary entries save correctly
- [ ] Fall risk assessment calculates scores accurately
- [ ] Emergency alert notifies caregivers
- [ ] Dashboard displays all data correctly
- [ ] Language switching works seamlessly
- [ ] All buttons are responsive and accessible

### Test User Credentials

**Default User:**
- User ID: 1
- Name: Ahmad bin Abdullah
- Age: 72
- Language: English

**Registered Caregiver:**
- Name: Siti (Daughter)
- Phone: +60123456789

---

## 🔧 Configuration

### Changing Default User

Edit `backend/app.py` in the `init_default_user()` function:

```python
user_id = db.create_user("Your Name", 70, "en")  # or "bm" for Bahasa
```

### Adjusting Reminder Frequency

In `static/js/main.js`, modify:

```javascript
setInterval(checkForReminders, 300000); // 300000ms = 5 minutes
```

### Database Location

Default: `data/samarasa.db`

To change, modify `backend/database.py`:

```python
class Database:
    def __init__(self, db_path='your/custom/path.db'):
```

---

## 🚀 Future Enhancements

1. **Real API Integration**
   - SMS/Email notifications for caregivers
   - Cloud-based data synchronization
   - Real-time voice recognition

2. **Machine Learning**
   - Mood detection from text analysis
   - Predictive health insights
   - Personalized conversation patterns

3. **IoT Integration**
   - Wearable device data
   - Fall detection sensors
   - Automatic medication dispensers

4. **Advanced Features**
   - Video calling with caregivers
   - Appointment scheduling
   - Telemedicine integration
   - Multi-user support

---

## 📚 References

1. **DOSM (2025)** — Malaysia Ageing Report
2. **WHO (2023)** — Global Report on Ageing and Health
3. **MOH (2024)** — National Policy for Older Persons
4. **WCAG 2.1** — Web Content Accessibility Guidelines

---

## 📄 License

This is an educational prototype developed for SSW3001 course at UPM (Universiti Putra Malaysia), 2025.

**For educational and research purposes only.**

---

## 🆘 Support

For issues or questions:
1. Review this README
2. Check `requirements.md` for SRS details
3. Inspect browser console for errors
4. Verify Flask server is running
5. Contact development team

---

## 📝 Version History

- **v1.0.0** (2025) - Initial prototype release
  - All 6 core modules implemented
  - Bilingual support (EN/BM)
  - Accessibility features
  - Family dashboard
  - Complete API documentation

---

## 🎯 Project Alignment

This prototype aligns with:
- ✅ MOH National Policy for Older Persons (2024)
- ✅ WHO Guidelines on Ageing and Health
- ✅ WCAG 2.1 Accessibility Standards
- ✅ IEEE SRS Documentation Format

---

**SamaRasa** - *Together in Harmony* 🤝

Making elderly care accessible, dignified, and technologically empowered.

---

*Last Updated: November 2025*
