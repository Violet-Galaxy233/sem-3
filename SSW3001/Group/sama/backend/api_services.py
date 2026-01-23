"""
SamaRasa API Services Integration
Integrates external APIs for enhanced functionality
"""

import os
from dotenv import load_dotenv
from openai import OpenAI
from twilio.rest import Client as TwilioClient
from sendgrid import SendGridAPIClient
from sendgrid.helpers.mail import Mail
import requests
from datetime import datetime

# Load environment variables
load_dotenv()

class APIServices:
    """Centralized API services manager"""

    def __init__(self):
        self.load_config()
        self.init_clients()

    def load_config(self):
        """Load API configuration from environment"""
        self.config = {
            'openai': {
                'enabled': os.getenv('ENABLE_OPENAI', 'false').lower() == 'true',
                'api_key': os.getenv('OPENAI_API_KEY'),
                'model': os.getenv('OPENAI_MODEL', 'gpt-4o-mini')
            },
            'twilio': {
                'enabled': os.getenv('ENABLE_TWILIO', 'false').lower() == 'true',
                'account_sid': os.getenv('TWILIO_ACCOUNT_SID'),
                'auth_token': os.getenv('TWILIO_AUTH_TOKEN'),
                'phone_number': os.getenv('TWILIO_PHONE_NUMBER'),
                'emergency_contacts': os.getenv('EMERGENCY_CONTACTS', '').split(',')
            },
            'sendgrid': {
                'enabled': os.getenv('ENABLE_SENDGRID', 'false').lower() == 'true',
                'api_key': os.getenv('SENDGRID_API_KEY'),
                'from_email': os.getenv('SENDGRID_FROM_EMAIL'),
                'emergency_emails': os.getenv('EMERGENCY_EMAILS', '').split(',')
            },
            'google_translate': {
                'enabled': os.getenv('ENABLE_GOOGLE_TRANSLATE', 'false').lower() == 'true',
                'api_key': os.getenv('GOOGLE_CLOUD_API_KEY')
            }
        }

    def init_clients(self):
        """Initialize API clients"""
        # OpenAI Client
        if self.config['openai']['enabled'] and self.config['openai']['api_key']:
            try:
                self.openai_client = OpenAI(api_key=self.config['openai']['api_key'])
            except Exception as e:
                print(f"OpenAI initialization failed: {e}")
                self.openai_client = None
        else:
            self.openai_client = None

        # Twilio Client
        if self.config['twilio']['enabled'] and self.config['twilio']['account_sid']:
            try:
                self.twilio_client = TwilioClient(
                    self.config['twilio']['account_sid'],
                    self.config['twilio']['auth_token']
                )
            except Exception as e:
                print(f"Twilio initialization failed: {e}")
                self.twilio_client = None
        else:
            self.twilio_client = None

        # SendGrid Client
        if self.config['sendgrid']['enabled'] and self.config['sendgrid']['api_key']:
            try:
                self.sendgrid_client = SendGridAPIClient(
                    self.config['sendgrid']['api_key']
                )
            except Exception as e:
                print(f"SendGrid initialization failed: {e}")
                self.sendgrid_client = None
        else:
            self.sendgrid_client = None

    # ============= OpenAI Integration =============

    def chat_with_gpt(self, message, language='en', context=None):
        """Enhanced chat using OpenAI GPT"""
        if not self.openai_client:
            return None

        try:
            system_prompt = self._get_system_prompt(language)

            messages = [
                {"role": "system", "content": system_prompt},
            ]

            # Add context if provided
            if context:
                messages.append({
                    "role": "system",
                    "content": f"User context: {context}"
                })

            messages.append({"role": "user", "content": message})

            response = self.openai_client.chat.completions.create(
                model=self.config['openai']['model'],
                messages=messages,
                max_tokens=200,
                temperature=0.7
            )

            return response.choices[0].message.content

        except Exception as e:
            print(f"OpenAI API error: {e}")
            return None

    def _get_system_prompt(self, language):
        """Get system prompt for chatbot based on language"""
        prompts = {
            'en': """You are SamaRasa, a compassionate AI assistant for elderly care in Malaysia.
Your role is to:
- Be empathetic, patient, and encouraging
- Speak simply and clearly
- Help with medication reminders, health tracking, and companionship
- Detect emergencies and urgent health concerns
- Be culturally sensitive to Malaysian elderly
Keep responses brief (2-3 sentences max) and warm.""",

            'bm': """Anda adalah SamaRasa, pembantu AI yang prihatin untuk penjagaan warga tua di Malaysia.
Peranan anda:
- Bersikap empati, sabar, dan menggalakkan
- Bercakap dengan mudah dan jelas
- Membantu dengan peringatan ubat, pemantauan kesihatan, dan persahabatan
- Mengesan kecemasan dan kebimbangan kesihatan yang mendesak
- Sensitif terhadap budaya warga tua Malaysia
Berikan respons yang ringkas (2-3 ayat maksimum) dan mesra."""
        }
        return prompts.get(language, prompts['en'])

    # ============= Twilio Integration (SMS/Calls) =============

    def send_sms_alert(self, message, phone_numbers=None):
        """Send SMS alert to caregivers"""
        if not self.twilio_client:
            return {'success': False, 'error': 'Twilio not configured'}

        if not phone_numbers:
            phone_numbers = self.config['twilio']['emergency_contacts']

        results = []
        for phone in phone_numbers:
            phone = phone.strip()
            if not phone:
                continue

            try:
                message_obj = self.twilio_client.messages.create(
                    body=message,
                    from_=self.config['twilio']['phone_number'],
                    to=phone
                )
                results.append({
                    'phone': phone,
                    'status': 'sent',
                    'sid': message_obj.sid
                })
            except Exception as e:
                results.append({
                    'phone': phone,
                    'status': 'failed',
                    'error': str(e)
                })

        return {'success': True, 'results': results}

    def make_emergency_call(self, phone_number, message):
        """Make emergency voice call"""
        if not self.twilio_client:
            return {'success': False, 'error': 'Twilio not configured'}

        try:
            # Create TwiML for voice message
            twiml = f"""
            <Response>
                <Say voice="alice" language="en-GB">{message}</Say>
                <Pause length="2"/>
                <Say voice="alice" language="en-GB">Please respond immediately.</Say>
            </Response>
            """

            call = self.twilio_client.calls.create(
                twiml=twiml,
                to=phone_number,
                from_=self.config['twilio']['phone_number']
            )

            return {
                'success': True,
                'call_sid': call.sid,
                'status': call.status
            }
        except Exception as e:
            return {'success': False, 'error': str(e)}

    # ============= SendGrid Integration (Email) =============

    def send_email_alert(self, subject, content, recipients=None):
        """Send email alert to caregivers"""
        if not self.sendgrid_client:
            return {'success': False, 'error': 'SendGrid not configured'}

        if not recipients:
            recipients = self.config['sendgrid']['emergency_emails']

        results = []
        for email in recipients:
            email = email.strip()
            if not email:
                continue

            try:
                message = Mail(
                    from_email=self.config['sendgrid']['from_email'],
                    to_emails=email,
                    subject=subject,
                    html_content=content
                )

                response = self.sendgrid_client.send(message)

                results.append({
                    'email': email,
                    'status': 'sent',
                    'status_code': response.status_code
                })
            except Exception as e:
                results.append({
                    'email': email,
                    'status': 'failed',
                    'error': str(e)
                })

        return {'success': True, 'results': results}

    def create_emergency_email_html(self, user_name, alert_type, location, timestamp):
        """Create formatted emergency email"""
        return f"""
        <html>
        <body style="font-family: Arial, sans-serif; padding: 20px;">
            <div style="background-color: #fee; border-left: 4px solid #f00; padding: 20px; margin-bottom: 20px;">
                <h1 style="color: #c00; margin: 0;">🆘 EMERGENCY ALERT</h1>
            </div>

            <h2>Emergency Details:</h2>
            <ul style="font-size: 18px; line-height: 1.8;">
                <li><strong>Person:</strong> {user_name}</li>
                <li><strong>Alert Type:</strong> {alert_type}</li>
                <li><strong>Time:</strong> {timestamp}</li>
                <li><strong>Location:</strong> {location or 'Location not available'}</li>
            </ul>

            <div style="background-color: #ffc; padding: 15px; margin-top: 20px; border-radius: 5px;">
                <p style="margin: 0; font-size: 16px;">
                    <strong>Action Required:</strong> Please contact the person immediately or visit them to ensure their safety.
                </p>
            </div>

            <hr style="margin: 30px 0;">

            <p style="color: #666; font-size: 14px;">
                This is an automated alert from SamaRasa Elderly Care System.<br>
                Generated at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
            </p>
        </body>
        </html>
        """

    # ============= Google Translate Integration =============

    def translate_text(self, text, target_language):
        """Translate text using Google Translate API"""
        if not self.config['google_translate']['enabled']:
            return None

        try:
            url = "https://translation.googleapis.com/language/translate/v2"
            params = {
                'key': self.config['google_translate']['api_key'],
                'q': text,
                'target': target_language
            }

            response = requests.post(url, params=params)
            result = response.json()

            if 'data' in result and 'translations' in result['data']:
                return result['data']['translations'][0]['translatedText']

            return None
        except Exception as e:
            print(f"Translation error: {e}")
            return None

    # ============= Emergency Alert System =============

    def send_emergency_alert(self, user_info, alert_type='SOS', location=None):
        """Send comprehensive emergency alert via all channels"""
        user_name = user_info.get('name', 'Unknown User')
        timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

        results = {
            'sms': None,
            'email': None,
            'call': None
        }

        # Prepare messages
        sms_message = f"🆘 EMERGENCY ALERT!\n{user_name} triggered an emergency alert.\nTime: {timestamp}\nLocation: {location or 'Not available'}\nPlease respond immediately!"

        email_subject = f"🆘 EMERGENCY: {user_name} needs immediate assistance"
        email_content = self.create_emergency_email_html(
            user_name, alert_type, location, timestamp
        )

        voice_message = f"Emergency alert from SamaRasa. {user_name} has triggered an S O S alert at {timestamp}. Please respond immediately."

        # Send SMS
        if self.twilio_client:
            results['sms'] = self.send_sms_alert(sms_message)

        # Send Email
        if self.sendgrid_client:
            results['email'] = self.send_email_alert(email_subject, email_content)

        # Make voice call to first emergency contact
        if self.twilio_client and self.config['twilio']['emergency_contacts']:
            first_contact = self.config['twilio']['emergency_contacts'][0].strip()
            if first_contact:
                results['call'] = self.make_emergency_call(first_contact, voice_message)

        return results

    # ============= Status Check =============

    def get_api_status(self):
        """Get status of all API integrations"""
        return {
            'openai': {
                'enabled': self.config['openai']['enabled'],
                'configured': self.openai_client is not None
            },
            'twilio': {
                'enabled': self.config['twilio']['enabled'],
                'configured': self.twilio_client is not None
            },
            'sendgrid': {
                'enabled': self.config['sendgrid']['enabled'],
                'configured': self.sendgrid_client is not None
            },
            'google_translate': {
                'enabled': self.config['google_translate']['enabled'],
                'configured': self.config['google_translate']['api_key'] is not None
            }
        }

# Global instance
api_services = APIServices()
