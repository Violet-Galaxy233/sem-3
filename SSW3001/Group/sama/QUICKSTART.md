# SamaRasa - Quick Start Guide

Get up and running with SamaRasa in 5 minutes!

## 🚀 Quick Setup

### Option 1: Using Startup Scripts (Recommended)

#### On macOS/Linux:
```bash
./start.sh
```

#### On Windows:
```
start.bat
```

### Option 2: Manual Setup

1. **Install Dependencies**
   ```bash
   pip install -r requirements.txt
   ```

2. **Start Server**
   ```bash
   cd backend
   python app.py
   ```

3. **Open Browser**
   - Elderly Interface: `http://localhost:5000`
   - Family Dashboard: `http://localhost:5000/dashboard`

---

## 📱 First Steps

### For Elderly Users:

1. **Open** `http://localhost:5000` in your browser
2. **Choose Language**: Click "English" or "Bahasa" button at top
3. **Try the Chat**:
   - Click "💬 Chat Companion"
   - Type "Hello" or "Helo"
   - See AI response!

4. **Check Medications**:
   - Click "💊 Medications"
   - View scheduled medicines
   - Click "✓ Taken" to confirm

5. **Log Your Health**:
   - Click "📔 Health Diary"
   - Select mood (😊 😐 😢 😴)
   - Enter sleep hours and exercise
   - Click "Save Entry"

6. **Emergency Button**:
   - Big red button at bottom right
   - Click "🆘 EMERGENCY" if needed

### For Caregivers:

1. **Open Dashboard**: `http://localhost:5000/dashboard`
2. **Monitor** elderly person's health
3. **View** medication compliance
4. **Check** for active alerts
5. **Review** chat history

---

## 🎯 Quick Test Scenarios

### Test Chat (English):
```
You: "Hello"
AI: "Good day! I'm here to help you."

You: "I need medicine"
AI: "Let me check your medication schedule for you."
```

### Test Chat (Bahasa Malaysia):
Switch language to "Bahasa", then:
```
You: "Apa khabar"
AI: "Selamat sejahtera! Saya di sini untuk membantu anda."
```

### Test Medication Reminder:
1. Go to Medications page
2. Click "Check Reminders"
3. See if any medicines are due

### Test Health Diary:
1. Go to Health Diary
2. Select mood: 😊 Happy
3. Enter sleep: 7.5 hours
4. Enter exercise: 30 minutes
5. Click "Save Entry"
6. See weekly summary

### Test Fall Risk:
1. Go to Fall Risk Assessment
2. Answer all 10 questions (Yes/No)
3. Click "Submit Assessment"
4. See risk level and recommendations

### Test Emergency Alert:
1. Click red "🆘 EMERGENCY" button
2. Confirm the alert
3. Open dashboard in another tab
4. See alert in "Active Alerts" section

---

## 🔧 Troubleshooting

### Server won't start?
- Check Python is installed: `python3 --version`
- Install dependencies: `pip install -r requirements.txt`
- Check port 5000 is not in use

### Page not loading?
- Make sure server is running (see terminal output)
- Try: `http://127.0.0.1:5000` instead
- Clear browser cache

### Database errors?
- Delete `data/samarasa.db`
- Restart server (it will recreate database)

---

## 📊 Default Test Data

The system comes with pre-loaded test data:

**User:**
- Name: Ahmad bin Abdullah
- Age: 72 years
- Language: English

**Medications:**
- Blood Pressure Medicine (08:00 daily)
- Diabetes Medicine (20:00 daily)

**Caregiver:**
- Name: Siti (Daughter)
- Phone: +60123456789

---

## 🌐 Browser Compatibility

✅ Google Chrome (Recommended)
✅ Mozilla Firefox
✅ Safari
✅ Microsoft Edge

---

## 💡 Tips

1. **Large Screen**: Best viewed on tablet or desktop for elderly users
2. **Touch Friendly**: All buttons are large (60px minimum)
3. **Language**: Switch anytime using top-right toggle
4. **Auto-Reminders**: System checks medications every 5 minutes
5. **Dashboard**: Keep open in another tab for monitoring

---

## 📚 Need More Help?

- Full documentation: See `README.md`
- Requirements: See `requirements.md`
- API docs: Check README API section
- Issues: Contact development team

---

## 🎉 You're Ready!

SamaRasa is now running. Try all the features and explore!

**Main URLs:**
- 👴 Elderly: http://localhost:5000
- 👨‍👩‍👧 Dashboard: http://localhost:5000/dashboard

**Stop Server:** Press `Ctrl+C` in terminal

---

**SamaRasa** - Making elderly care accessible and dignified 🤝
