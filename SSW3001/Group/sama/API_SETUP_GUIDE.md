# SamaRasa - API Integration Setup Guide

Complete guide to set up all external API integrations for full functionality.

---

## 📋 Quick Overview

SamaRasa now integrates with:

| API Service | Purpose | Status |
|-------------|---------|--------|
| 🤖 OpenAI GPT | Intelligent chat responses | Optional |
| 📱 Twilio | SMS & voice call notifications | Optional |
| 📧 SendGrid | Email notifications | Optional |
| 🗣️ Web Speech API | Voice recognition & TTS | Built-in (free) |
| 📍 Geolocation | Emergency location tracking | Built-in (free) |
| 🌐 Google Translate | Enhanced translations | Optional |

**Note:** Built-in APIs (Web Speech, Geolocation) work without any setup!

---

## 🚀 Quick Start (Without API Keys)

The system works perfectly without any API keys! You can test:

✅ Voice recognition (Chrome/Edge required)
✅ Text-to-speech responses
✅ Emergency location detection
✅ Rule-based AI chat
✅ All core modules

**To enable advanced features**, continue with the setup below.

---

## 1️⃣ OpenAI GPT API Setup

### Why?
- Much smarter, natural conversations
- Context-aware responses
- Better understanding of elderly concerns

### How to Get API Key:

1. **Create OpenAI Account**
   - Visit: https://platform.openai.com/signup
   - Sign up with email

2. **Get API Key**
   - Go to: https://platform.openai.com/api-keys
   - Click "Create new secret key"
   - Copy the key (starts with `sk-...`)

3. **Add Credits** (if needed)
   - Go to: https://platform.openai.com/account/billing
   - Add minimum $5 credit

### Configuration:

Open `.env` file and update:

```bash
ENABLE_OPENAI=true
OPENAI_API_KEY=sk-your-actual-key-here
OPENAI_MODEL=gpt-4o-mini  # Or gpt-4o for better quality
```

### Pricing:
- **gpt-4o-mini**: $0.15 per 1M tokens (~$0.01 per 100 conversations)
- **gpt-4o**: $2.50 per 1M tokens (~$0.15 per 100 conversations)

**For this project**: ~$1-2/month with light usage

---

## 2️⃣ Twilio API Setup (SMS & Calls)

### Why?
- Send real SMS to caregivers
- Make emergency phone calls
- Critical for actual deployment

### How to Get Credentials:

1. **Create Twilio Account**
   - Visit: https://www.twilio.com/try-twilio
   - Sign up (free trial includes $15 credit)

2. **Get Phone Number**
   - Dashboard → Phone Numbers → Buy a Number
   - Choose a number ($1/month)

3. **Get Credentials**
   - Dashboard → Account → API Keys
   - Copy:
     - Account SID
     - Auth Token

4. **Verify Emergency Contacts** (Free Trial)
   - Console → Verified Caller IDs
   - Add and verify caregiver phone numbers

### Configuration:

```bash
ENABLE_TWILIO=true
TWILIO_ACCOUNT_SID=ACxxxxxxxxxxxxxxxxxxxxxxxxxx
TWILIO_AUTH_TOKEN=your_auth_token_here
TWILIO_PHONE_NUMBER=+1234567890

# Caregiver phone numbers (comma-separated)
EMERGENCY_CONTACTS=+60123456789,+60198765432
```

### Pricing:
- **SMS**: $0.0075 per message in Malaysia
- **Voice Call**: $0.013 per minute
- **Monthly Number**: $1.00

**For this project**: ~$2-5/month with typical usage

**⚠️ Free Trial Limits:**
- Can only call/SMS verified numbers
- $15 credit included
- Perfect for testing!

---

## 3️⃣ SendGrid API Setup (Email)

### Why?
- Send detailed emergency emails
- Include health data in alerts
- Professional email delivery

### How to Get API Key:

1. **Create SendGrid Account**
   - Visit: https://signup.sendgrid.com/
   - Free plan: 100 emails/day forever!

2. **Verify Sender Email**
   - Settings → Sender Authentication
   - Verify your sending email address

3. **Create API Key**
   - Settings → API Keys → Create API Key
   - Give it "Full Access"
   - Copy the key (starts with `SG.`)

### Configuration:

```bash
ENABLE_SENDGRID=true
SENDGRID_API_KEY=SG.your-actual-key-here
SENDGRID_FROM_EMAIL=samarasa@yourdomain.com

# Caregiver emails (comma-separated)
EMERGENCY_EMAILS=caregiver1@example.com,caregiver2@example.com
```

### Pricing:
- **Free Plan**: 100 emails/day (3,000/month)
- **Essentials**: $19.95/month for 50,000 emails

**For this project**: FREE forever with Free plan!

---

## 4️⃣ Google Cloud Translation API (Optional)

### Why?
- Better English ↔ Bahasa Malaysia translation
- More accurate than rule-based

### How to Get API Key:

1. **Create Google Cloud Project**
   - Visit: https://console.cloud.google.com/
   - Create new project

2. **Enable Translation API**
   - APIs & Services → Library
   - Search "Cloud Translation API"
   - Enable it

3. **Create API Key**
   - APIs & Services → Credentials
   - Create Credentials → API Key
   - Copy the key

4. **Enable Billing** (if needed)
   - First $200 credit free
   - Then: $20 per 1M characters

### Configuration:

```bash
ENABLE_GOOGLE_TRANSLATE=true
GOOGLE_CLOUD_API_KEY=AIzaSyxxxxxxxxxxxxxxxxxxxxxxxxxx
```

### Pricing:
- **Free tier**: $200 credit
- **After**: $20 per 1M characters

**For this project**: FREE for most usage

---

## 🔧 Complete Configuration File

Edit `/Users/y/Desktop/sama/.env`:

```bash
# ==========================================
# OpenAI API
# ==========================================
ENABLE_OPENAI=true
OPENAI_API_KEY=sk-your-key-here
OPENAI_MODEL=gpt-4o-mini

# ==========================================
# Twilio API
# ==========================================
ENABLE_TWILIO=true
TWILIO_ACCOUNT_SID=ACxxxxxxxxxxxxxxxxxxxxx
TWILIO_AUTH_TOKEN=your_token_here
TWILIO_PHONE_NUMBER=+1234567890
EMERGENCY_CONTACTS=+60123456789,+60198765432

# ==========================================
# SendGrid API
# ==========================================
ENABLE_SENDGRID=true
SENDGRID_API_KEY=SG.your-key-here
SENDGRID_FROM_EMAIL=samarasa@yourdomain.com
EMERGENCY_EMAILS=caregiver@example.com

# ==========================================
# Google Translate API (Optional)
# ==========================================
ENABLE_GOOGLE_TRANSLATE=false
GOOGLE_CLOUD_API_KEY=AIzaSyxxxxxxxxxxxxx

# ==========================================
# Built-in Features (Always On)
# ==========================================
ENABLE_VOICE_SYNTHESIS=true
ENABLE_GEOLOCATION=true
```

---

## ✅ Testing Your Setup

### Test API Status:

```bash
curl http://localhost:5001/api/status
```

Expected response:
```json
{
  "success": true,
  "api_services": {
    "openai": {
      "enabled": true,
      "configured": true
    },
    "twilio": {
      "enabled": true,
      "configured": true
    },
    "sendgrid": {
      "enabled": true,
      "configured": true
    }
  }
}
```

### Test Individual Features:

**1. Test OpenAI Chat:**
```bash
curl -X POST http://localhost:5001/api/chat \
  -H "Content-Type: application/json" \
  -d '{"user_id": 1, "message": "How are you feeling today?", "language": "en"}'
```

Should return intelligent, contextual response.

**2. Test Emergency Alert:**
- Open: http://localhost:5001
- Click red "🆘 EMERGENCY" button
- Check if SMS/Email sent (if configured)

**3. Test Voice Recognition:**
- Open: http://localhost:5001
- Go to Chat section
- Click "🎤 Voice" button
- Speak clearly
- Should recognize and transcribe

**4. Test Text-to-Speech:**
- Chat with AI
- Response should be spoken aloud automatically

**5. Test Location:**
- Click "🆘 EMERGENCY"
- Browser will ask for location permission
- Allow it
- Location will be shared with caregivers

---

## 💰 Total Cost Estimate

### Development/Testing (Monthly):
- OpenAI: $1-2
- Twilio: $2-5 (or free trial)
- SendGrid: $0 (free forever)
- Google Translate: $0 (within free tier)

**Total: $3-7/month** (or $0 with free tiers!)

### Production (Monthly, ~100 elderly users):
- OpenAI: $10-20
- Twilio: $20-50
- SendGrid: $0 (or $19.95 for more)
- Google Translate: $5-10

**Total: $35-100/month** for 100 users

---

## 🔒 Security Best Practices

1. **Never commit `.env` file**
   ```bash
   echo ".env" >> .gitignore
   ```

2. **Use environment variables in production**
   - Don't hardcode API keys
   - Use server environment variables

3. **Rotate API keys regularly**
   - Change keys every 3-6 months
   - Immediately if compromised

4. **Restrict API key permissions**
   - Only grant necessary permissions
   - Use separate keys for dev/prod

5. **Monitor API usage**
   - Set up billing alerts
   - Watch for unusual activity

---

## 🐛 Troubleshooting

### OpenAI Not Working?

**Error: "OpenAI API error"**
- Check API key is correct
- Verify billing is set up
- Check `ENABLE_OPENAI=true`

**Check in browser console:**
```javascript
// Should show OpenAI configured
fetch('http://localhost:5001/api/status').then(r=>r.json()).then(console.log)
```

### Twilio Not Sending SMS?

**Common issues:**
- Phone numbers not verified (free trial)
- Wrong phone number format (use +country code)
- Insufficient balance
- Check Twilio console for errors

### SendGrid Emails Not Arriving?

**Common issues:**
- Sender email not verified
- Check spam folder
- Wrong API key
- Domain authentication needed (for production)

### Voice Recognition Not Working?

**Requirements:**
- Must use HTTPS (or localhost)
- Chrome/Edge browser (Safari limited)
- Microphone permission granted
- Stable internet connection

**Check support:**
```javascript
console.log(voiceServices.isSupported());
// Should show: { recognition: true, synthesis: true }
```

### Geolocation Not Working?

**Common issues:**
- Permission denied by user
- Not using HTTPS (except localhost)
- Browser doesn't support geolocation

---

## 📊 API Usage Monitoring

### OpenAI Usage:
- Dashboard: https://platform.openai.com/usage
- Set budget limits to avoid overspending

### Twilio Usage:
- Console: https://console.twilio.com/
- Monitor SMS/call costs

### SendGrid Usage:
- Dashboard: https://app.sendgrid.com/statistics
- Track email delivery rates

---

## 🎯 Recommended Setup for Testing

Start with this minimal setup:

```bash
# Minimal setup - All free!
ENABLE_OPENAI=false          # Use rule-based chat
ENABLE_TWILIO=false          # Simulate notifications
ENABLE_SENDGRID=false        # Simulate emails
ENABLE_VOICE_SYNTHESIS=true  # Built-in, free
ENABLE_GEOLOCATION=true      # Built-in, free
```

Then gradually add:
1. ✅ OpenAI (best ROI for quality)
2. ✅ SendGrid (free forever)
3. ✅ Twilio (when ready for real SMS)

---

## 🚀 Next Steps

1. **Copy `.env.example` to `.env`**
   ```bash
   cp .env.example .env
   ```

2. **Add your API keys** (optional)
   - Start with free options
   - Add premium APIs as needed

3. **Restart server**
   ```bash
   cd backend
   python app.py
   ```

4. **Test in browser**
   - http://localhost:5001
   - Try all features!

5. **Monitor usage**
   - Check API dashboards
   - Set billing alerts

---

## 📚 Additional Resources

- **OpenAI Docs**: https://platform.openai.com/docs
- **Twilio Docs**: https://www.twilio.com/docs
- **SendGrid Docs**: https://docs.sendgrid.com/
- **Web Speech API**: https://developer.mozilla.org/en-US/docs/Web/API/Web_Speech_API
- **Geolocation API**: https://developer.mozilla.org/en-US/docs/Web/API/Geolocation_API

---

## 💬 Support

Having issues? Check:
1. This guide
2. API provider documentation
3. Browser console for errors
4. API status pages

---

**SamaRasa** - Making elderly care smart and connected! 🤝

Last Updated: November 2025
