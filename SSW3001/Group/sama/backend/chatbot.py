"""
SamaRasa AI Chat Companion
Rule-based conversational system with empathy dialogue
Bilingual support: English (EN) and Bahasa Malaysia (BM)
Enhanced with OpenAI GPT API integration
"""

import random
from datetime import datetime

class ChatBot:
    def __init__(self, api_services=None):
        self.context = {}
        self.api_services = api_services
        self.load_responses()

    def load_responses(self):
        """Load bilingual response patterns"""
        self.responses = {
            'en': {
                'greeting': [
                    "Hello! How are you feeling today?",
                    "Good day! I'm here to help you.",
                    "Hi there! How can I assist you today?",
                ],
                'health': [
                    "It's important to take care of your health. Have you taken your medication today?",
                    "Remember to stay hydrated and take your medicines on time.",
                    "How are you feeling? Any pain or discomfort?",
                ],
                'medication': [
                    "Let me check your medication schedule for you.",
                    "It's time to take your medication. Would you like me to remind you?",
                    "Remember to take your medicine as prescribed by your doctor.",
                ],
                'mood': [
                    "I'm glad to hear that! Keep up the positive spirit.",
                    "I understand. Sometimes we all feel down. Would you like to talk about it?",
                    "Your feelings are valid. I'm here to listen.",
                ],
                'exercise': [
                    "Light exercise is great for your health! Have you done any walking today?",
                    "Regular movement helps keep you strong. Try some gentle stretching.",
                    "Even a short walk can improve your mood and health.",
                ],
                'companionship': [
                    "I'm always here to chat with you.",
                    "You're not alone. I'm here whenever you need company.",
                    "Tell me about your day. I'd love to hear.",
                ],
                'emergency': [
                    "Are you in danger? Let me alert your caregiver immediately!",
                    "I'm activating the emergency alert for you right now.",
                ],
                'default': [
                    "I'm here to help you. Could you tell me more?",
                    "I understand. How else can I assist you?",
                    "Thank you for sharing. What would you like to do next?",
                ],
                'fallback': "I'm sorry, I didn't quite understand. Could you rephrase that?",
            },
            'bm': {  # Bahasa Malaysia
                'greeting': [
                    "Helo! Apa khabar hari ini?",
                    "Selamat sejahtera! Saya di sini untuk membantu anda.",
                    "Hai! Apa yang boleh saya bantu hari ini?",
                ],
                'health': [
                    "Penting untuk menjaga kesihatan anda. Sudah makan ubat hari ini?",
                    "Ingat untuk minum air dan ambil ubat mengikut masa.",
                    "Apa khabar? Ada sakit atau rasa tidak selesa?",
                ],
                'medication': [
                    "Mari saya semak jadual ubat anda.",
                    "Masa untuk ambil ubat. Perlukan peringatan?",
                    "Ingat untuk makan ubat seperti yang doktor cadangkan.",
                ],
                'mood': [
                    "Saya gembira mendengar itu! Teruskan semangat positif.",
                    "Saya faham. Kadang-kadang kita semua rasa sedih. Nak berkongsi?",
                    "Perasaan anda adalah sah. Saya di sini untuk mendengar.",
                ],
                'exercise': [
                    "Senaman ringan baik untuk kesihatan! Sudah berjalan hari ini?",
                    "Pergerakan kerap membantu anda kekal kuat. Cuba regangan lembut.",
                    "Walaupun berjalan sebentar boleh tingkatkan mood dan kesihatan.",
                ],
                'companionship': [
                    "Saya sentiasa di sini untuk berbual dengan anda.",
                    "Anda tidak keseorangan. Saya di sini bila-bila masa.",
                    "Ceritakan tentang hari anda. Saya ingin dengar.",
                ],
                'emergency': [
                    "Adakah anda dalam bahaya? Saya akan maklumkan penjaga anda sekarang!",
                    "Saya mengaktifkan amaran kecemasan untuk anda sekarang.",
                ],
                'default': [
                    "Saya di sini untuk membantu. Boleh beritahu lebih lanjut?",
                    "Saya faham. Apa lagi yang boleh saya bantu?",
                    "Terima kasih berkongsi. Apa yang anda ingin lakukan seterusnya?",
                ],
                'fallback': "Maaf, saya tidak faham. Boleh ulang semula?",
            }
        }

        # Keywords for intent detection (multilingual)
        self.keywords = {
            'greeting': ['hello', 'hi', 'hey', 'good morning', 'good afternoon', 'good evening',
                        'helo', 'hai', 'selamat pagi', 'selamat petang', 'apa khabar'],
            'health': ['health', 'feel', 'pain', 'sick', 'doctor', 'hospital',
                      'kesihatan', 'sakit', 'doktor', 'hospital', 'rasa'],
            'medication': ['medicine', 'medication', 'pill', 'drug', 'dose',
                          'ubat', 'pil', 'dos'],
            'mood': ['happy', 'sad', 'tired', 'lonely', 'angry', 'worried', 'anxious',
                    'gembira', 'sedih', 'penat', 'risau', 'marah', 'keseorangan'],
            'exercise': ['exercise', 'walk', 'move', 'stretch', 'activity',
                        'senaman', 'jalan', 'regangan', 'aktiviti'],
            'companionship': ['talk', 'chat', 'company', 'alone', 'lonely',
                             'berbual', 'bercakap', 'keseorangan'],
            'emergency': ['help', 'emergency', 'sos', 'danger', 'fall', 'hurt',
                         'tolong', 'kecemasan', 'bahaya', 'jatuh', 'cedera'],
        }

    def detect_intent(self, message):
        """Detect user intent from message"""
        message_lower = message.lower()

        # Check for keywords
        for intent, keywords in self.keywords.items():
            for keyword in keywords:
                if keyword in message_lower:
                    return intent

        return 'default'

    def get_response(self, message, language='en', user_context=None):
        """Generate appropriate response based on message and context"""
        intent = self.detect_intent(message)

        # Handle emergency immediately
        if intent == 'emergency':
            return {
                'response': random.choice(self.responses[language]['emergency']),
                'intent': 'emergency',
                'action': 'trigger_sos'
            }

        # Try using OpenAI if available (better responses)
        if self.api_services and hasattr(self.api_services, 'openai_client') and self.api_services.openai_client:
            try:
                gpt_response = self.api_services.chat_with_gpt(message, language, user_context)
                if gpt_response:
                    # Add contextual information
                    action = None
                    if intent == 'medication':
                        action = 'check_medication'
                    elif intent == 'health':
                        action = 'check_health_diary'

                    return {
                        'response': gpt_response,
                        'intent': intent,
                        'action': action,
                        'source': 'openai'
                    }
            except Exception as e:
                print(f"OpenAI error, falling back to rule-based: {e}")

        # Fall back to rule-based response
        if intent in self.responses[language]:
            response_text = random.choice(self.responses[language][intent])
        else:
            response_text = random.choice(self.responses[language]['default'])

        # Add contextual information
        action = None
        if intent == 'medication':
            action = 'check_medication'
        elif intent == 'health':
            action = 'check_health_diary'

        return {
            'response': response_text,
            'intent': intent,
            'action': action,
            'source': 'rule-based'
        }

    def get_empathy_response(self, emotion, language='en'):
        """Generate empathetic response based on detected emotion"""
        empathy_responses = {
            'en': {
                'happy': "That's wonderful! I'm so glad you're feeling happy today.",
                'sad': "I hear you. It's okay to feel sad sometimes. I'm here for you.",
                'worried': "I understand your concerns. Let's take things one step at a time.",
                'tired': "Rest is important. Make sure you're getting enough sleep.",
                'lonely': "I'm here to keep you company. You're never alone.",
            },
            'bm': {
                'happy': "Bagus sekali! Saya gembira anda rasa bahagia hari ini.",
                'sad': "Saya faham. Tidak mengapa rasa sedih kadang-kadang. Saya di sini.",
                'worried': "Saya faham kebimbangan anda. Mari ambil langkah satu persatu.",
                'tired': "Rehat itu penting. Pastikan anda tidur yang cukup.",
                'lonely': "Saya di sini menemani anda. Anda tidak keseorangan.",
            }
        }

        return empathy_responses.get(language, {}).get(emotion,
            empathy_responses[language].get('default',
            self.responses[language]['fallback']))

    def get_medication_reminder_message(self, medication_name, language='en'):
        """Generate medication reminder message"""
        messages = {
            'en': f"It's time to take your {medication_name}. Please don't forget!",
            'bm': f"Masa untuk ambil ubat {medication_name}. Jangan lupa!"
        }
        return messages.get(language, messages['en'])

    def get_daily_greeting(self, name, language='en'):
        """Generate personalized daily greeting"""
        hour = datetime.now().hour

        if language == 'en':
            if hour < 12:
                greeting = f"Good morning, {name}!"
            elif hour < 18:
                greeting = f"Good afternoon, {name}!"
            else:
                greeting = f"Good evening, {name}!"
            greeting += " How are you feeling today?"
        else:  # Bahasa Malaysia
            if hour < 12:
                greeting = f"Selamat pagi, {name}!"
            elif hour < 18:
                greeting = f"Selamat petang, {name}!"
            else:
                greeting = f"Selamat malam, {name}!"
            greeting += " Apa khabar hari ini?"

        return greeting

    def get_encouragement(self, language='en'):
        """Generate random encouragement message"""
        encouragements = {
            'en': [
                "You're doing great! Keep up the good work.",
                "Every day is a new opportunity to take care of yourself.",
                "Remember, small steps lead to big improvements.",
                "I'm proud of you for taking care of your health!",
            ],
            'bm': [
                "Anda hebat! Teruskan usaha yang baik.",
                "Setiap hari adalah peluang baru untuk jaga diri.",
                "Ingat, langkah kecil membawa perubahan besar.",
                "Saya bangga dengan anda kerana jaga kesihatan!",
            ]
        }
        return random.choice(encouragements.get(language, encouragements['en']))
