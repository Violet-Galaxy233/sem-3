// SamaRasa Voice & Geolocation Services
// Web Speech API Integration for Voice Recognition and Text-to-Speech

class VoiceServices {
    constructor() {
        this.recognition = null;
        this.synthesis = window.speechSynthesis;
        this.isListening = false;
        this.initSpeechRecognition();
    }

    // ============= Speech Recognition (Voice Input) =============

    initSpeechRecognition() {
        /**
         * Initialize Web Speech Recognition API
         * Supports: Chrome, Edge, Safari (limited)
         */
        if ('webkitSpeechRecognition' in window || 'SpeechRecognition' in window) {
            const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
            this.recognition = new SpeechRecognition();

            // Configure recognition
            this.recognition.continuous = false;  // Stop after one phrase
            this.recognition.interimResults = false;  // Only final results
            this.recognition.maxAlternatives = 1;

            // Set language based on current selection
            this.updateRecognitionLanguage(currentLanguage || 'en');
        } else {
            console.warn('Speech Recognition not supported in this browser');
        }
    }

    updateRecognitionLanguage(language) {
        /**
         * Update recognition language
         * en = English (UK/US)
         * bm/ms = Bahasa Malaysia
         */
        if (!this.recognition) return;

        const languageMap = {
            'en': 'en-US',
            'bm': 'ms-MY'  // Bahasa Malaysia
        };

        this.recognition.lang = languageMap[language] || 'en-US';
    }

    startListening(onResult, onError) {
        /**
         * Start voice recognition
         * @param {Function} onResult - Callback with recognized text
         * @param {Function} onError - Callback for errors
         */
        if (!this.recognition) {
            if (onError) onError('Speech recognition not supported');
            return;
        }

        if (this.isListening) {
            console.log('Already listening');
            return;
        }

        this.isListening = true;

        // Set language before starting
        this.updateRecognitionLanguage(currentLanguage || 'en');

        // Handle results
        this.recognition.onresult = (event) => {
            const transcript = event.results[0][0].transcript;
            const confidence = event.results[0][0].confidence;

            console.log(`Recognized: ${transcript} (confidence: ${confidence})`);

            if (onResult) {
                onResult(transcript, confidence);
            }

            this.isListening = false;
        };

        // Handle errors
        this.recognition.onerror = (event) => {
            console.error('Speech recognition error:', event.error);

            let errorMessage = 'Voice recognition error';

            switch (event.error) {
                case 'no-speech':
                    errorMessage = 'No speech detected. Please try again.';
                    break;
                case 'audio-capture':
                    errorMessage = 'No microphone found. Please check your device.';
                    break;
                case 'not-allowed':
                    errorMessage = 'Microphone permission denied. Please allow access.';
                    break;
                case 'network':
                    errorMessage = 'Network error. Please check your connection.';
                    break;
            }

            if (onError) {
                onError(errorMessage);
            }

            this.isListening = false;
        };

        // Handle end
        this.recognition.onend = () => {
            this.isListening = false;
        };

        // Start recognition
        try {
            this.recognition.start();
            console.log('Voice recognition started');
        } catch (error) {
            console.error('Failed to start recognition:', error);
            this.isListening = false;
            if (onError) onError('Failed to start voice recognition');
        }
    }

    stopListening() {
        /**
         * Stop voice recognition
         */
        if (this.recognition && this.isListening) {
            this.recognition.stop();
            this.isListening = false;
        }
    }

    // ============= Text-to-Speech (Voice Output) =============

    speak(text, language = 'en', callback = null) {
        /**
         * Speak text using Web Speech Synthesis API
         * @param {string} text - Text to speak
         * @param {string} language - Language code (en/bm)
         * @param {Function} callback - Called when speech ends
         */
        if (!this.synthesis) {
            console.warn('Speech synthesis not supported');
            return;
        }

        // Cancel any ongoing speech
        this.synthesis.cancel();

        const utterance = new SpeechSynthesisUtterance(text);

        // Set language
        const languageMap = {
            'en': 'en-US',
            'bm': 'ms-MY'
        };
        utterance.lang = languageMap[language] || 'en-US';

        // Configure voice parameters
        utterance.rate = 0.9;  // Slightly slower for elderly users
        utterance.pitch = 1.0;
        utterance.volume = 1.0;

        // Try to find appropriate voice
        const voices = this.synthesis.getVoices();
        const preferredVoice = voices.find(voice =>
            voice.lang.startsWith(languageMap[language])
        );

        if (preferredVoice) {
            utterance.voice = preferredVoice;
        }

        // Handle events
        utterance.onend = () => {
            console.log('Speech finished');
            if (callback) callback();
        };

        utterance.onerror = (event) => {
            console.error('Speech error:', event);
        };

        // Speak
        this.synthesis.speak(utterance);
    }

    stopSpeaking() {
        /**
         * Stop current speech
         */
        if (this.synthesis) {
            this.synthesis.cancel();
        }
    }

    getAvailableVoices() {
        /**
         * Get list of available voices
         * @returns {Array} List of voice objects
         */
        if (!this.synthesis) return [];
        return this.synthesis.getVoices();
    }

    // ============= Helper Methods =============

    isSupported() {
        /**
         * Check if voice services are supported
         * @returns {Object} Support status
         */
        return {
            recognition: !!this.recognition,
            synthesis: !!this.synthesis
        };
    }
}

// ============= Geolocation Services =============

class GeolocationService {
    constructor() {
        this.supported = 'geolocation' in navigator;
    }

    getCurrentLocation(onSuccess, onError) {
        /**
         * Get current device location
         * @param {Function} onSuccess - Callback with position
         * @param {Function} onError - Callback for errors
         */
        if (!this.supported) {
            if (onError) onError('Geolocation not supported in this browser');
            return;
        }

        const options = {
            enableHighAccuracy: true,
            timeout: 10000,
            maximumAge: 0
        };

        navigator.geolocation.getCurrentPosition(
            (position) => {
                const locationData = {
                    latitude: position.coords.latitude,
                    longitude: position.coords.longitude,
                    accuracy: position.coords.accuracy,
                    timestamp: position.timestamp,
                    formatted: `${position.coords.latitude.toFixed(6)}, ${position.coords.longitude.toFixed(6)}`
                };

                console.log('Location obtained:', locationData);

                if (onSuccess) {
                    onSuccess(locationData);
                }
            },
            (error) => {
                let errorMessage = 'Unable to get location';

                switch (error.code) {
                    case error.PERMISSION_DENIED:
                        errorMessage = 'Location permission denied';
                        break;
                    case error.POSITION_UNAVAILABLE:
                        errorMessage = 'Location information unavailable';
                        break;
                    case error.TIMEOUT:
                        errorMessage = 'Location request timed out';
                        break;
                }

                console.error('Geolocation error:', errorMessage);

                if (onError) {
                    onError(errorMessage);
                }
            },
            options
        );
    }

    watchLocation(onUpdate, onError) {
        /**
         * Continuously track location
         * @param {Function} onUpdate - Called with each position update
         * @param {Function} onError - Callback for errors
         * @returns {number} Watch ID (use to stop watching)
         */
        if (!this.supported) {
            if (onError) onError('Geolocation not supported');
            return null;
        }

        const options = {
            enableHighAccuracy: true,
            timeout: 10000,
            maximumAge: 30000
        };

        return navigator.geolocation.watchPosition(
            (position) => {
                const locationData = {
                    latitude: position.coords.latitude,
                    longitude: position.coords.longitude,
                    accuracy: position.coords.accuracy,
                    timestamp: position.timestamp,
                    formatted: `${position.coords.latitude.toFixed(6)}, ${position.coords.longitude.toFixed(6)}`
                };

                if (onUpdate) {
                    onUpdate(locationData);
                }
            },
            (error) => {
                if (onError) {
                    onError(error.message);
                }
            },
            options
        );
    }

    stopWatching(watchId) {
        /**
         * Stop watching location
         * @param {number} watchId - ID returned by watchLocation
         */
        if (this.supported && watchId) {
            navigator.geolocation.clearWatch(watchId);
        }
    }

    isSupported() {
        /**
         * Check if geolocation is supported
         * @returns {boolean}
         */
        return this.supported;
    }
}

// ============= Global Instances =============

// Initialize services
const voiceServices = new VoiceServices();
const geolocationService = new GeolocationService();

// Load voices when available
if (window.speechSynthesis) {
    window.speechSynthesis.onvoiceschanged = () => {
        console.log('Voices loaded:', voiceServices.getAvailableVoices().length);
    };
}

console.log('Voice Services:', voiceServices.isSupported());
console.log('Geolocation:', geolocationService.isSupported());
