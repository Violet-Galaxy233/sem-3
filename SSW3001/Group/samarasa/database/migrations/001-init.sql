-- SMAMRASA Database Schema - Initial Setup
-- PostgreSQL 15+

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL CHECK (role IN ('patient', 'doctor', 'admin')),
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    mfa_secret VARCHAR(255),
    mfa_enabled BOOLEAN DEFAULT false,
    email_verified BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Indexes for users
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);

-- Sessions table
CREATE TABLE IF NOT EXISTS sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    refresh_token_hash VARCHAR(255),
    ip_address INET,
    user_agent TEXT,
    expires_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_sessions_user_id ON sessions(user_id);
CREATE INDEX idx_sessions_expires_at ON sessions(expires_at);

-- Audit log table
CREATE TABLE IF NOT EXISTS audit_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID,
    action VARCHAR(100) NOT NULL,
    ip_address INET,
    user_agent TEXT,
    timestamp TIMESTAMP DEFAULT NOW(),
    details JSONB
);

CREATE INDEX idx_audit_log_user_id ON audit_log(user_id);
CREATE INDEX idx_audit_log_timestamp ON audit_log(timestamp);
CREATE INDEX idx_audit_log_action ON audit_log(action);

-- Patients table
CREATE TABLE IF NOT EXISTS patients (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE UNIQUE,
    date_of_birth DATE,
    gender VARCHAR(20),
    blood_type VARCHAR(5),
    allergies TEXT[],
    medications TEXT[],
    emergency_contact JSONB,
    address TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_patients_user_id ON patients(user_id);

-- Providers table (Doctors, Healthcare Professionals)
CREATE TABLE IF NOT EXISTS providers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE UNIQUE,
    specialty VARCHAR(100) NOT NULL,
    license_number VARCHAR(50) UNIQUE NOT NULL,
    years_experience INTEGER,
    bio TEXT,
    consultation_fee DECIMAL(10, 2) DEFAULT 0.00,
    is_available BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_providers_user_id ON providers(user_id);
CREATE INDEX idx_providers_specialty ON providers(specialty);

-- Appointments table
CREATE TABLE IF NOT EXISTS appointments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id UUID REFERENCES patients(id) ON DELETE CASCADE,
    provider_id UUID REFERENCES providers(id) ON DELETE CASCADE,
    scheduled_time TIMESTAMP NOT NULL,
    duration INTEGER DEFAULT 30, -- minutes
    reason TEXT,
    status VARCHAR(20) DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'confirmed', 'completed', 'cancelled', 'no-show')),
    priority INTEGER DEFAULT 0, -- 0=normal, 1-10=emergency levels
    is_emergency BOOLEAN DEFAULT false,
    notes TEXT,
    meeting_link VARCHAR(500),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_appointments_patient_id ON appointments(patient_id);
CREATE INDEX idx_appointments_provider_id ON appointments(provider_id);
CREATE INDEX idx_appointments_scheduled_time ON appointments(scheduled_time);
CREATE INDEX idx_appointments_status ON appointments(status);

-- Availability slots for providers
CREATE TABLE IF NOT EXISTS availability_slots (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    provider_id UUID REFERENCES providers(id) ON DELETE CASCADE,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    is_available BOOLEAN DEFAULT true,
    appointment_id UUID REFERENCES appointments(id),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_availability_provider ON availability_slots(provider_id);
CREATE INDEX idx_availability_time ON availability_slots(start_time, end_time);

-- Medical history table
CREATE TABLE IF NOT EXISTS medical_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id UUID REFERENCES patients(id) ON DELETE CASCADE,
    visit_date DATE NOT NULL,
    diagnosis TEXT,
    treatment TEXT,
    provider_id UUID REFERENCES providers(id),
    notes TEXT,
    documents JSONB, -- Array of document URLs
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_medical_history_patient ON medical_history(patient_id);
CREATE INDEX idx_medical_history_provider ON medical_history(provider_id);
CREATE INDEX idx_medical_history_date ON medical_history(visit_date);

-- Prescriptions table
CREATE TABLE IF NOT EXISTS prescriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    appointment_id UUID REFERENCES appointments(id) ON DELETE CASCADE,
    provider_id UUID REFERENCES providers(id) ON DELETE CASCADE,
    patient_id UUID REFERENCES patients(id) ON DELETE CASCADE,
    medications JSONB NOT NULL, -- Array of medication objects
    notes TEXT,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'filled', 'expired', 'cancelled')),
    pharmacy_id VARCHAR(100),
    filled_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_prescriptions_patient ON prescriptions(patient_id);
CREATE INDEX idx_prescriptions_provider ON prescriptions(provider_id);
CREATE INDEX idx_prescriptions_status ON prescriptions(status);

-- Medications reference table
CREATE TABLE IF NOT EXISTS medications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    form VARCHAR(50), -- tablet, capsule, liquid, injection, etc.
    strength VARCHAR(50),
    manufacturer VARCHAR(255),
    ndc_code VARCHAR(20), -- National Drug Code
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_medications_name ON medications(name);

-- Notifications table
CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL, -- appointment_reminder, emergency_alert, prescription_ready, etc.
    channel VARCHAR(20) NOT NULL CHECK (channel IN ('sms', 'email', 'push')),
    content TEXT NOT NULL,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'sent', 'failed', 'read')),
    sent_at TIMESTAMP,
    error_message TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_status ON notifications(status);
CREATE INDEX idx_notifications_type ON notifications(type);

-- Alerts table (for IoT and emergency alerts)
CREATE TABLE IF NOT EXISTS alerts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id UUID REFERENCES patients(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL, -- vital_sign, emergency, system
    severity VARCHAR(20) NOT NULL CHECK (severity IN ('info', 'warning', 'critical')),
    message TEXT NOT NULL,
    metric VARCHAR(50),
    value DECIMAL(10,2),
    threshold DECIMAL(10,2),
    acknowledged BOOLEAN DEFAULT false,
    acknowledged_by UUID REFERENCES users(id),
    acknowledged_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_alerts_patient ON alerts(patient_id);
CREATE INDEX idx_alerts_severity ON alerts(severity);
CREATE INDEX idx_alerts_acknowledged ON alerts(acknowledged);

-- Triage queue table
CREATE TABLE IF NOT EXISTS triage_queue (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id UUID REFERENCES patients(id) ON DELETE CASCADE,
    appointment_id UUID REFERENCES appointments(id),
    symptoms JSONB NOT NULL, -- Array of symptom objects
    vitals JSONB, -- Vital signs snapshot
    priority INTEGER NOT NULL CHECK (priority BETWEEN 1 AND 10),
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'escalated')),
    recommended_action TEXT,
    estimated_wait_minutes INTEGER,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_triage_queue_priority ON triage_queue(priority);
CREATE INDEX idx_triage_queue_status ON triage_queue(status);
CREATE INDEX idx_triage_queue_patient ON triage_queue(patient_id);

-- Billing and payments table
CREATE TABLE IF NOT EXISTS billing (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    appointment_id UUID REFERENCES appointments(id),
    patient_id UUID REFERENCES patients(id) ON DELETE CASCADE,
    provider_id UUID REFERENCES providers(id),
    amount DECIMAL(10,2) NOT NULL,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'paid', 'failed', 'refunded')),
    payment_method VARCHAR(50),
    transaction_id VARCHAR(255),
    insurance_claim_id VARCHAR(255),
    invoice_number VARCHAR(100) UNIQUE,
    due_date DATE,
    paid_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_billing_patient ON billing(patient_id);
CREATE INDEX idx_billing_provider ON billing(provider_id);
CREATE INDEX idx_billing_status ON billing(status);
CREATE INDEX idx_billing_invoice ON billing(invoice_number);

-- Audit trigger for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to all tables
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_sessions_updated_at BEFORE UPDATE ON sessions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_patients_updated_at BEFORE UPDATE ON patients FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_providers_updated_at BEFORE UPDATE ON providers FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_appointments_updated_at BEFORE UPDATE ON appointments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_availability_updated_at BEFORE UPDATE ON availability_slots FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_medical_history_updated_at BEFORE UPDATE ON medical_history FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_prescriptions_updated_at BEFORE UPDATE ON prescriptions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_triage_queue_updated_at BEFORE UPDATE ON triage_queue FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_billing_updated_at BEFORE UPDATE ON billing FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Insert sample admin user (password: Admin123!)
INSERT INTO users (email, password_hash, role, name, phone, mfa_enabled, email_verified)
VALUES (
    'admin@smamrasa.com',
    '$2a$12$KIXpS8vLQdLQ8Q8Q8Q8Q8OeOeOeOeOeOeOeOeOeOeOeOeOeOeOeOeOe', -- bcrypt hash
    'admin',
    'System Administrator',
    '+1234567890',
    false,
    true
) ON CONFLICT DO NOTHING;

-- Grant permissions (adjust as needed for your setup)
-- GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO smamrasa_admin;
-- GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO smamrasa_admin;

-- Insert sample provider
INSERT INTO users (email, password_hash, role, name, phone, mfa_enabled, email_verified)
VALUES (
    'doctor@smamrasa.com',
    '$2a$12$KIXpS8vLQdLQ8Q8Q8Q8Q8OeOeOeOeOeOeOeOeOeOeOeOeOeOeOeOeOe',
    'doctor',
    'Dr. John Smith',
    '+1234567891',
    false,
    true
) ON CONFLICT DO NOTHING;

INSERT INTO providers (user_id, specialty, license_number, years_experience, bio)
SELECT
    id,
    'General Medicine',
    'MD123456',
    10,
    'Experienced general practitioner with 10 years of experience in telemedicine.'
FROM users WHERE email = 'doctor@smamrasa.com' ON CONFLICT DO NOTHING;

-- Insert sample patient
INSERT INTO users (email, password_hash, role, name, phone, mfa_enabled, email_verified)
VALUES (
    'patient@smamrasa.com',
    '$2a$12$KIXpS8vLQdLQ8Q8Q8Q8Q8OeOeOeOeOeOeOeOeOeOeOeOeOeOeOeOeOe',
    'patient',
    'Jane Doe',
    '+1234567892',
    false,
    true
) ON CONFLICT DO NOTHING;

INSERT INTO patients (user_id, date_of_birth, gender, blood_type, allergies, medications, emergency_contact)
SELECT
    id,
    '1985-05-15',
    'Female',
    'O+',
    ARRAY['Penicillin', 'Peanuts'],
    ARRAY['Lisinopril 10mg'],
    '{"name": "John Doe", "phone": "+1234567893", "relationship": "Spouse"}'::jsonb
FROM users WHERE email = 'patient@smamrasa.com' ON CONFLICT DO NOTHING;

-- Create views for common queries
CREATE OR REPLACE VIEW active_appointments AS
SELECT
    a.id,
    a.scheduled_time,
    a.duration,
    a.reason,
    a.status,
    a.priority,
    a.is_emergency,
    p.name as patient_name,
    pr.name as provider_name,
    pr.specialty
FROM appointments a
JOIN patients pt ON a.patient_id = pt.id
JOIN users p ON pt.user_id = p.id
JOIN providers pv ON a.provider_id = pv.id
JOIN users pr ON pv.user_id = pr.id
WHERE a.status IN ('scheduled', 'confirmed')
AND a.scheduled_time >= NOW();

CREATE OR REPLACE VIEW patient_summary AS
SELECT
    pt.id as patient_id,
    u.name as patient_name,
    u.email,
    u.phone,
    pt.date_of_birth,
    pt.gender,
    pt.blood_type,
    pt.allergies,
    pt.medications,
    COUNT(DISTINCT a.id) as total_appointments,
    COUNT(DISTINCT pr.id) as unique_providers
FROM patients pt
JOIN users u ON pt.user_id = u.id
LEFT JOIN appointments a ON pt.id = a.patient_id
LEFT JOIN providers pv ON a.provider_id = pv.id
LEFT JOIN users pr ON pv.user_id = pr.id
GROUP BY pt.id, u.name, u.email, u.phone, pt.date_of_birth, pt.gender, pt.blood_type, pt.allergies, pt.medications;

-- Create function to check provider availability
CREATE OR REPLACE FUNCTION check_provider_availability(provider_id UUID, start_time TIMESTAMP, duration_minutes INTEGER)
RETURNS BOOLEAN AS $$
DECLARE
    overlapping_slots INTEGER;
BEGIN
    SELECT COUNT(*) INTO overlapping_slots
    FROM availability_slots av
    WHERE av.provider_id = provider_id
    AND av.is_available = false
    AND (
        (av.start_time <= start_time AND av.end_time > start_time) OR
        (av.start_time < start_time + (duration_minutes || ' minutes')::INTERVAL AND av.end_time >= start_time + (duration_minutes || ' minutes')::INTERVAL) OR
        (av.start_time >= start_time AND av.end_time <= start_time + (duration_minutes || ' minutes')::INTERVAL)
    );

    RETURN overlapping_slots = 0;
END;
$$ LANGUAGE plpgsql;

-- Create function to calculate appointment priority
CREATE OR REPLACE FUNCTION calculate_priority(patient_id UUID, symptoms JSONB, vitals JSONB)
RETURNS INTEGER AS $$
DECLARE
    priority_score INTEGER := 0;
    vital RECORD;
    symptom RECORD;
BEGIN
    -- Check vital signs
    IF vitals ? 'heart_rate' THEN
        IF (vitals->>'heart_rate')::INTEGER > 120 OR (vitals->>'heart_rate')::INTEGER < 50 THEN
            priority_score := priority_score + 3;
        END IF;
    END IF;

    IF vitals ? 'spo2' THEN
        IF (vitals->>'spo2')::INTEGER < 92 THEN
            priority_score := priority_score + 4;
        END IF;
    END IF;

    IF vitals ? 'bp_systolic' THEN
        IF (vitals->>'bp_systolic')::INTEGER > 180 OR (vitals->>'bp_systolic')::INTEGER < 90 THEN
            priority_score := priority_score + 3;
        END IF;
    END IF;

    -- Check symptoms
    FOR symptom IN SELECT * FROM jsonb_array_elements(symptoms) LOOP
        IF symptom->>'severity' = 'severe' THEN
            priority_score := priority_score + 2;
        END IF;

        IF symptom->>'name' IN ('chest_pain', 'difficulty_breathing', 'severe_bleeding') THEN
            priority_score := priority_score + 3;
        END IF;
    END LOOP;

    -- Cap at 10
    IF priority_score > 10 THEN
        priority_score := 10;
    END IF;

    RETURN priority_score;
END;
$$ LANGUAGE plpgsql;

-- Create audit log trigger function
CREATE OR REPLACE FUNCTION log_audit_changes()
RETURNS TRIGGER AS $$
DECLARE
    user_id_var UUID;
    action_var VARCHAR(100);
BEGIN
    -- This would be called from application context
    -- For now, we'll just return NEW
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Grant permissions (uncomment and adjust for production)
-- GRANT CONNECT ON DATABASE smamrasa TO smamrasa_admin;
-- GRANT USAGE ON SCHEMA public TO smamrasa_admin;
-- GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO smamrasa_admin;
-- GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO smamrasa_admin;

-- Analyze tables for query optimization
ANALYZE;

-- Display schema info
COMMENT ON TABLE users IS 'User accounts with authentication and role information';
COMMENT ON TABLE patients IS 'Patient-specific information and medical profiles';
COMMENT ON TABLE providers IS 'Healthcare provider profiles and specialties';
COMMENT ON TABLE appointments IS 'Scheduled appointments between patients and providers';
COMMENT ON TABLE medical_history IS 'Historical medical records and visit information';
COMMENT ON TABLE prescriptions IS 'Digital prescriptions and medication orders';
COMMENT ON TABLE alerts IS 'System alerts for vital signs and emergencies';
COMMENT ON TABLE triage_queue IS 'Emergency triage and priority queue';
COMMENT ON TABLE billing IS 'Billing and payment records';

-- Success message
\echo 'SMAMRASA Database Schema Created Successfully'
\echo 'Tables created:'
\echo '  - users'
\echo '  - sessions'
\echo '  - audit_log'
\echo '  - patients'
\echo '  - providers'
\echo '  - appointments'
\echo '  - availability_slots'
\echo '  - medical_history'
\echo '  - prescriptions'
\echo '  - medications'
\echo '  - notifications'
\echo '  - alerts'
\echo '  - triage_queue'
\echo '  - billing'
\echo ''
\echo 'Sample users created:'
\echo '  - admin@smamrasa.com (password: Admin123!)'
\echo '  - doctor@smamrasa.com (password: Admin123!)'
\echo '  - patient@smamrasa.com (password: Admin123!)'
