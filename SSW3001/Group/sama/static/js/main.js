// SamaRasa Main JavaScript - Elderly User Interface

const API_BASE = 'http://localhost:5001/api';
const USER_ID = 1; // Default user for prototype
let currentLanguage = 'en';
let selectedMood = null;
let fallAnswers = {};

// Initialize app
document.addEventListener('DOMContentLoaded', () => {
    loadGreeting();
    showSection('home');
    checkForReminders();
});

// Language switching
function switchLanguage(lang) {
    currentLanguage = lang;

    // Update button states
    document.getElementById('langEN').classList.toggle('active', lang === 'en');
    document.getElementById('langBM').classList.toggle('active', lang === 'bm');

    // Update translations
    updateTranslations();

    // Reload greeting
    loadGreeting();
}

// Section navigation
function showSection(sectionName) {
    // Hide all sections
    document.querySelectorAll('.section').forEach(section => {
        section.classList.add('hidden');
    });

    // Show requested section
    if (sectionName === 'home') {
        // Show menu only
        return;
    }

    const sectionId = sectionName + 'Section';
    const section = document.getElementById(sectionId);
    if (section) {
        section.classList.remove('hidden');

        // Load section data
        switch(sectionName) {
            case 'chat':
                loadChatHistory();
                break;
            case 'medication':
                loadMedications();
                break;
            case 'diary':
                loadDiarySummary();
                break;
            case 'fall':
                loadFallAssessment();
                break;
            case 'dashboard':
                window.location.href = '/dashboard';
                break;
        }
    }
}

// Greeting
async function loadGreeting() {
    try {
        const response = await fetch(`${API_BASE}/chat/greeting/${USER_ID}`);
        const data = await response.json();
        if (data.success) {
            document.getElementById('greeting').textContent = data.greeting;
        }
    } catch (error) {
        console.error('Error loading greeting:', error);
    }
}

// ============= CHAT MODULE =============

async function loadChatHistory() {
    try {
        const response = await fetch(`${API_BASE}/chat/history/${USER_ID}?limit=10`);
        const data = await response.json();

        const chatMessages = document.getElementById('chatMessages');
        chatMessages.innerHTML = '';

        if (data.success && data.history.length > 0) {
            data.history.forEach(chat => {
                addMessageToChat(chat.message, 'user');
                addMessageToChat(chat.response, 'bot');
            });
        } else {
            addMessageToChat(
                currentLanguage === 'en' ?
                    'Hello! How can I help you today?' :
                    'Helo! Apa yang boleh saya bantu hari ini?',
                'bot'
            );
        }

        // Scroll to bottom
        chatMessages.scrollTop = chatMessages.scrollHeight;
    } catch (error) {
        console.error('Error loading chat history:', error);
    }
}

function addMessageToChat(message, sender) {
    const chatMessages = document.getElementById('chatMessages');
    const messageDiv = document.createElement('div');
    messageDiv.className = `message ${sender}`;
    messageDiv.textContent = message;
    chatMessages.appendChild(messageDiv);
    chatMessages.scrollTop = chatMessages.scrollHeight;
}

async function sendMessage() {
    const input = document.getElementById('chatInput');
    const message = input.value.trim();

    if (!message) return;

    // Add user message to chat
    addMessageToChat(message, 'user');
    input.value = '';

    try {
        const response = await fetch(`${API_BASE}/chat`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                user_id: USER_ID,
                message: message,
                language: currentLanguage
            })
        });

        const data = await response.json();

        if (data.success) {
            addMessageToChat(data.response, 'bot');

            // Speak the response using text-to-speech
            if (voiceServices && voiceServices.isSupported().synthesis) {
                voiceServices.speak(data.response, currentLanguage);
            }

            // Handle special actions
            if (data.intent === 'emergency') {
                triggerSOS();
            }
        }
    } catch (error) {
        console.error('Error sending message:', error);
        addMessageToChat(
            currentLanguage === 'en' ?
                'Sorry, there was an error.' :
                'Maaf, ada masalah.',
            'bot'
        );
    }
}

// Handle Enter key in chat
document.addEventListener('DOMContentLoaded', () => {
    const chatInput = document.getElementById('chatInput');
    if (chatInput) {
        chatInput.addEventListener('keypress', (e) => {
            if (e.key === 'Enter') {
                sendMessage();
            }
        });
    }
});

function startVoiceInput() {
    // Real voice input using Web Speech API
    const voiceIndicator = document.getElementById('voiceIndicator');
    const voiceText = document.getElementById('voiceText');

    // Check if voice services are supported
    if (!voiceServices || !voiceServices.isSupported().recognition) {
        showAlert(
            currentLanguage === 'en' ?
                'Voice input not supported in this browser' :
                'Input suara tidak disokong dalam pelayar ini',
            'warning'
        );
        return;
    }

    // Show listening indicator
    voiceIndicator.classList.remove('hidden');
    voiceText.textContent = currentLanguage === 'en' ? 'Listening...' : 'Mendengar...';

    // Update language for recognition
    voiceServices.updateRecognitionLanguage(currentLanguage);

    // Start listening
    voiceServices.startListening(
        // On success
        (transcript, confidence) => {
            voiceIndicator.classList.add('hidden');
            document.getElementById('chatInput').value = transcript;

            // Automatically send if confident
            if (confidence > 0.7) {
                sendMessage();
            } else {
                showAlert(
                    currentLanguage === 'en' ?
                        'Please check if the text is correct and send' :
                        'Sila semak jika teks betul dan hantar',
                    'info'
                );
            }
        },
        // On error
        (error) => {
            voiceIndicator.classList.add('hidden');
            showAlert(error, 'danger');
        }
    );
}

// ============= MEDICATION MODULE =============

async function loadMedications() {
    try {
        const response = await fetch(`${API_BASE}/medications/${USER_ID}`);
        const data = await response.json();

        const medicationList = document.getElementById('medicationList');
        medicationList.innerHTML = '';

        if (data.success && data.medications.length > 0) {
            data.medications.forEach(med => {
                const medDiv = document.createElement('div');
                medDiv.className = 'medication-item';
                medDiv.innerHTML = `
                    <div class="medication-info">
                        <div class="medication-name">${med.medication_name}</div>
                        <div class="medication-details">
                            ${med.dosage} at ${med.time} - ${med.frequency}
                        </div>
                    </div>
                    <div class="medication-actions">
                        <button class="btn btn-success" onclick="confirmMedication(${med.id})">
                            ✓ ${currentLanguage === 'en' ? 'Taken' : 'Sudah'}
                        </button>
                    </div>
                `;
                medicationList.appendChild(medDiv);
            });
        } else {
            medicationList.innerHTML = `<p>${currentLanguage === 'en' ?
                'No medications scheduled.' :
                'Tiada ubat dijadualkan.'}</p>`;
        }
    } catch (error) {
        console.error('Error loading medications:', error);
    }
}

async function confirmMedication(medId) {
    try {
        const response = await fetch(`${API_BASE}/medications/${medId}/confirm`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ status: 'taken' })
        });

        const data = await response.json();

        if (data.success) {
            showAlert(
                currentLanguage === 'en' ?
                    'Medication marked as taken!' :
                    'Ubat ditanda sudah diambil!',
                'success'
            );
        }
    } catch (error) {
        console.error('Error confirming medication:', error);
    }
}

async function checkReminders() {
    try {
        const response = await fetch(`${API_BASE}/medications/reminder/${USER_ID}`);
        const data = await response.json();

        if (data.success && data.due_medications.length > 0) {
            data.due_medications.forEach(med => {
                showAlert(med.reminder_message, 'warning');
            });
        } else {
            showAlert(
                currentLanguage === 'en' ?
                    'No medications due right now.' :
                    'Tiada ubat perlu diambil sekarang.',
                'info'
            );
        }
    } catch (error) {
        console.error('Error checking reminders:', error);
    }
}

// Auto-check reminders periodically
setInterval(checkForReminders, 300000); // Every 5 minutes

async function checkForReminders() {
    try {
        const response = await fetch(`${API_BASE}/medications/reminder/${USER_ID}`);
        const data = await response.json();

        if (data.success && data.due_medications.length > 0) {
            // Show prominent reminder
            data.due_medications.forEach(med => {
                showAlert(med.reminder_message, 'warning');
            });
        }
    } catch (error) {
        console.error('Error checking reminders:', error);
    }
}

// ============= HEALTH DIARY MODULE =============

function selectMood(mood) {
    selectedMood = mood;

    // Update UI
    document.querySelectorAll('.mood-option').forEach(option => {
        option.classList.remove('selected');
    });

    document.querySelector(`.mood-option[data-mood="${mood}"]`).classList.add('selected');
}

async function submitDiary(event) {
    event.preventDefault();

    if (!selectedMood) {
        showAlert(
            currentLanguage === 'en' ?
                'Please select your mood.' :
                'Sila pilih mood anda.',
            'warning'
        );
        return;
    }

    const sleepHours = parseFloat(document.getElementById('sleepHours').value);
    const exerciseMinutes = parseInt(document.getElementById('exerciseMinutes').value);
    const notes = document.getElementById('diaryNotes').value;

    try {
        const response = await fetch(`${API_BASE}/diary`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                user_id: USER_ID,
                mood: selectedMood,
                sleep_hours: sleepHours,
                exercise_minutes: exerciseMinutes,
                notes: notes
            })
        });

        const data = await response.json();

        if (data.success) {
            showAlert(
                currentLanguage === 'en' ?
                    'Diary entry saved successfully!' :
                    'Entri diari berjaya disimpan!',
                'success'
            );

            // Reset form
            document.getElementById('sleepHours').value = '';
            document.getElementById('exerciseMinutes').value = '';
            document.getElementById('diaryNotes').value = '';
            selectedMood = null;
            document.querySelectorAll('.mood-option').forEach(option => {
                option.classList.remove('selected');
            });

            // Reload summary
            loadDiarySummary();
        }
    } catch (error) {
        console.error('Error submitting diary:', error);
        showAlert('Error saving entry', 'danger');
    }
}

async function loadDiarySummary() {
    try {
        const response = await fetch(`${API_BASE}/diary/summary/${USER_ID}`);
        const data = await response.json();

        const summaryDiv = document.getElementById('weeklySummary');

        if (data.success && data.summary) {
            const summary = data.summary;
            summaryDiv.innerHTML = `
                <div class="grid grid-2">
                    <div class="stat-card">
                        <div class="stat-value">${summary.avg_sleep_hours}h</div>
                        <div class="stat-label">${currentLanguage === 'en' ? 'Avg Sleep' : 'Purata Tidur'}</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-value">${summary.avg_exercise_minutes}m</div>
                        <div class="stat-label">${currentLanguage === 'en' ? 'Avg Exercise' : 'Purata Senaman'}</div>
                    </div>
                </div>
            `;
        } else {
            summaryDiv.innerHTML = `<p>${currentLanguage === 'en' ?
                'No diary entries yet.' :
                'Belum ada entri diari.'}</p>`;
        }
    } catch (error) {
        console.error('Error loading diary summary:', error);
    }
}

// ============= FALL RISK ASSESSMENT MODULE =============

const fallQuestions = {
    en: [
        "Have you fallen in the past year?",
        "Do you use or have you been advised to use a walking aid?",
        "Do you sometimes feel unsteady when walking?",
        "Do you use your arms to push up from a chair?",
        "Are you sometimes afraid you might fall?",
        "Do you have difficulty climbing stairs?",
        "Do you have problems with balance?",
        "Do you take medication that makes you dizzy?",
        "Do you have weakness in your legs?",
        "Do you have problems with your vision?"
    ],
    bm: [
        "Adakah anda pernah jatuh dalam tahun lepas?",
        "Adakah anda guna atau disarankan guna alat bantuan berjalan?",
        "Adakah anda kadang-kadang rasa tidak stabil semasa berjalan?",
        "Adakah anda guna tangan untuk bangun dari kerusi?",
        "Adakah anda kadang-kadang takut akan jatuh?",
        "Adakah anda ada masalah naik tangga?",
        "Adakah anda ada masalah keseimbangan?",
        "Adakah anda ambil ubat yang buat pening?",
        "Adakah anda rasa lemah di kaki?",
        "Adakah anda ada masalah penglihatan?"
    ]
};

function loadFallAssessment() {
    const questionsDiv = document.getElementById('fallQuestions');
    const questions = fallQuestions[currentLanguage];

    questionsDiv.innerHTML = '';
    fallAnswers = {};

    questions.forEach((question, index) => {
        const questionDiv = document.createElement('div');
        questionDiv.className = 'form-group';
        questionDiv.innerHTML = `
            <label style="font-size: 20px;">${index + 1}. ${question}</label>
            <div style="display: flex; gap: 20px; margin-top: 12px;">
                <button type="button" class="btn btn-outline"
                    onclick="answerFallQuestion(${index}, 'yes')"
                    id="fall-${index}-yes">
                    ${currentLanguage === 'en' ? 'Yes' : 'Ya'}
                </button>
                <button type="button" class="btn btn-outline"
                    onclick="answerFallQuestion(${index}, 'no')"
                    id="fall-${index}-no">
                    ${currentLanguage === 'en' ? 'No' : 'Tidak'}
                </button>
            </div>
        `;
        questionsDiv.appendChild(questionDiv);
    });
}

function answerFallQuestion(questionIndex, answer) {
    fallAnswers[questionIndex] = answer;

    // Update button states
    document.getElementById(`fall-${questionIndex}-yes`).classList.toggle('active', answer === 'yes');
    document.getElementById(`fall-${questionIndex}-no`).classList.toggle('active', answer === 'no');
}

async function submitFallAssessment() {
    // Check if all questions answered
    if (Object.keys(fallAnswers).length < 10) {
        showAlert(
            currentLanguage === 'en' ?
                'Please answer all questions.' :
                'Sila jawab semua soalan.',
            'warning'
        );
        return;
    }

    try {
        const response = await fetch(`${API_BASE}/fall-assessment`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                user_id: USER_ID,
                answers: fallAnswers,
                language: currentLanguage
            })
        });

        const data = await response.json();

        if (data.success) {
            displayFallResults(data);
        }
    } catch (error) {
        console.error('Error submitting fall assessment:', error);
        showAlert('Error submitting assessment', 'danger');
    }
}

function displayFallResults(data) {
    const resultsDiv = document.getElementById('fallResults');
    const contentDiv = document.getElementById('fallResultsContent');

    resultsDiv.classList.remove('hidden');

    const riskColor = data.risk_level === 'Low' ? 'success' :
                     data.risk_level === 'Medium' ? 'warning' : 'danger';

    contentDiv.innerHTML = `
        <div class="alert alert-${riskColor}">
            <h3 style="margin-bottom: 12px;">
                ${currentLanguage === 'en' ? 'Risk Level' : 'Tahap Risiko'}: ${data.risk_level}
            </h3>
            <p style="font-size: 20px;">
                ${currentLanguage === 'en' ? 'Score' : 'Skor'}: ${data.score}/10
            </p>
        </div>

        <h3 style="margin: 20px 0;">${currentLanguage === 'en' ? 'Recommendations' : 'Cadangan'}</h3>
        <ul style="font-size: 18px; line-height: 1.8;">
            ${data.recommendations.map(rec => `<li>${rec}</li>`).join('')}
        </ul>
    `;

    // Scroll to results
    resultsDiv.scrollIntoView({ behavior: 'smooth' });
}

// ============= EMERGENCY ALERT MODULE =============

async function triggerSOS() {
    const confirmed = confirm(
        currentLanguage === 'en' ?
            'Are you in an emergency? This will alert your caregivers.' :
            'Adakah anda dalam kecemasan? Ini akan maklumkan penjaga anda.'
    );

    if (!confirmed) return;

    // Show loading message
    showAlert(
        currentLanguage === 'en' ?
            'Getting your location and sending alert...' :
            'Mendapatkan lokasi anda dan menghantar amaran...',
        'info'
    );

    // Try to get location (don't wait forever)
    let location = '';

    if (geolocationService && geolocationService.isSupported()) {
        await new Promise((resolve) => {
            const timeout = setTimeout(() => {
                console.log('Location timeout, sending without location');
                resolve();
            }, 5000);  // 5 second timeout

            geolocationService.getCurrentLocation(
                (locationData) => {
                    clearTimeout(timeout);
                    location = locationData.formatted;
                    console.log('Location obtained:', location);
                    resolve();
                },
                (error) => {
                    clearTimeout(timeout);
                    console.warn('Location error:', error);
                    resolve();  // Continue even if location fails
                }
            );
        });
    }

    try {
        const response = await fetch(`${API_BASE}/emergency/alert`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                user_id: USER_ID,
                alert_type: 'SOS',
                location: location
            })
        });

        const data = await response.json();

        if (data.success) {
            let message = currentLanguage === 'en' ?
                `🆘 Emergency alert sent! ${data.caregivers_notified} caregiver(s) notified.` :
                `🆘 Amaran kecemasan dihantar! ${data.caregivers_notified} penjaga dimaklumkan.`;

            // Add notification status
            if (data.notifications) {
                const methods = [];
                if (data.notifications.sms_sent) methods.push('SMS');
                if (data.notifications.email_sent) methods.push('Email');
                if (data.notifications.call_made) methods.push('Call');

                if (methods.length > 0) {
                    message += ` (${methods.join(', ')})`;
                }
            }

            if (location) {
                message += currentLanguage === 'en' ?
                    `\nYour location has been shared.` :
                    `\nLokasi anda telah dikongsi.`;
            }

            showAlert(message, 'success');

            // Speak emergency confirmation
            if (voiceServices && voiceServices.isSupported().synthesis) {
                const voiceMsg = currentLanguage === 'en' ?
                    'Emergency alert sent. Help is on the way.' :
                    'Amaran kecemasan dihantar. Bantuan sedang dalam perjalanan.';
                voiceServices.speak(voiceMsg, currentLanguage);
            }
        }
    } catch (error) {
        console.error('Error triggering SOS:', error);
        showAlert('Error sending alert', 'danger');
    }
}

// ============= UTILITY FUNCTIONS =============

function showAlert(message, type = 'info') {
    // Create alert element
    const alert = document.createElement('div');
    alert.className = `alert alert-${type}`;
    alert.textContent = message;
    alert.style.position = 'fixed';
    alert.style.top = '20px';
    alert.style.right = '20px';
    alert.style.zIndex = '9999';
    alert.style.minWidth = '300px';
    alert.style.fontSize = '20px';

    document.body.appendChild(alert);

    // Auto remove after 5 seconds
    setTimeout(() => {
        alert.remove();
    }, 5000);
}

function updateTranslations() {
    // This will be populated by translations.js
    if (typeof translations !== 'undefined' && translations[currentLanguage]) {
        const t = translations[currentLanguage];

        // Update all translatable elements
        Object.keys(t).forEach(key => {
            const element = document.getElementById(key);
            if (element) {
                element.textContent = t[key];
            }
        });
    }
}
