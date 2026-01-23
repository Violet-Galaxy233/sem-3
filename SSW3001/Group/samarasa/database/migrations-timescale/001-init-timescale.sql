-- SMAMRASA IoT Time-Series Database Schema
-- TimescaleDB optimized for vital signs and sensor data

-- Enable TimescaleDB extension
CREATE EXTENSION IF NOT EXISTS timescaledb;

-- IoT Devices table
CREATE TABLE IF NOT EXISTS iot_devices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    device_id VARCHAR(100) UNIQUE NOT NULL,
    type VARCHAR(50) NOT NULL, -- blood_pressure, pulse_oximeter, thermometer, heart_rate, glucose
    manufacturer VARCHAR(100),
    model VARCHAR(100),
    firmware_version VARCHAR(50),
    patient_id UUID,
    paired_at TIMESTAMP,
    last_seen TIMESTAMP,
    is_active BOOLEAN DEFAULT true,
    metadata JSONB,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_iot_devices_device_id ON iot_devices(device_id);
CREATE INDEX idx_iot_devices_patient ON iot_devices(patient_id);
CREATE INDEX idx_iot_devices_type ON iot_devices(type);

-- Vital Signs Time-Series Table (Hypertable)
CREATE TABLE vital_signs (
    time TIMESTAMPTZ NOT NULL,
    patient_id UUID NOT NULL,
    device_id VARCHAR(100),
    metric VARCHAR(50) NOT NULL, -- heart_rate, bp_systolic, bp_diastolic, spo2, temperature, glucose
    value DECIMAL(10,2) NOT NULL,
    unit VARCHAR(20),
    alert_triggered BOOLEAN DEFAULT false,
    metadata JSONB
);

-- Convert to hypertable
SELECT create_hypertable('vital_signs', 'time',
    chunk_time_interval => INTERVAL '1 day');

-- Indexes for hypertable
CREATE INDEX idx_vitals_patient_time ON vital_signs (patient_id, time DESC);
CREATE INDEX idx_vitals_metric ON vital_signs (metric);
CREATE INDEX idx_vitals_device ON vital_signs (device_id);

-- Continuous aggregates for real-time monitoring
-- 5-minute averages
CREATE MATERIALIZED VIEW vital_signs_5min
WITH (timescaledb.continuous) AS
SELECT
    time_bucket('5 minutes', time) AS bucket,
    patient_id,
    metric,
    AVG(value) as avg_value,
    MIN(value) as min_value,
    MAX(value) as max_value,
    COUNT(*) as readings_count
FROM vital_signs
GROUP BY bucket, patient_id, metric;

-- Hourly aggregates
CREATE MATERIALIZED VIEW vital_signs_hourly
WITH (timescaledb.continuous) AS
SELECT
    time_bucket('1 hour', time) AS bucket,
    patient_id,
    metric,
    AVG(value) as avg_value,
    MIN(value) as min_value,
    MAX(value) as max_value,
    STDDEV(value) as std_dev,
    COUNT(*) as readings_count
FROM vital_signs
GROUP BY bucket, patient_id, metric;

-- Daily aggregates
CREATE MATERIALIZED VIEW vital_signs_daily
WITH (timescaledb.continuous) AS
SELECT
    time_bucket('1 day', time) AS bucket,
    patient_id,
    metric,
    AVG(value) as avg_value,
    MIN(value) as min_value,
    MAX(value) as max_value,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY value) as median,
    COUNT(*) as readings_count
FROM vital_signs
GROUP BY bucket, patient_id, metric;

-- Refresh policies for continuous aggregates
SELECT add_continuous_aggregate_policy('vital_signs_5min',
    start_offset => INTERVAL '1 hour',
    end_offset => INTERVAL '5 minutes',
    schedule_interval => INTERVAL '5 minutes');

SELECT add_continuous_aggregate_policy('vital_signs_hourly',
    start_offset => INTERVAL '1 day',
    end_offset => INTERVAL '1 hour',
    schedule_interval => INTERVAL '1 hour');

SELECT add_continuous_aggregate_policy('vital_signs_daily',
    start_offset => INTERVAL '1 week',
    end_offset => INTERVAL '1 day',
    schedule_interval => INTERVAL '1 day');

-- Compression policy (compress data older than 7 days)
SELECT add_compression_policy('vital_signs', INTERVAL '7 days');

-- Retention policy (keep data for 1 year)
SELECT add_retention_policy('vital_signs', INTERVAL '1 year');

-- Alert history table
CREATE TABLE IF NOT EXISTS alert_history (
    time TIMESTAMPTZ NOT NULL,
    patient_id UUID NOT NULL,
    metric VARCHAR(50),
    value DECIMAL(10,2),
    threshold DECIMAL(10,2),
    severity VARCHAR(20), -- warning, critical
    message TEXT,
    acknowledged BOOLEAN DEFAULT false,
    metadata JSONB
);

SELECT create_hypertable('alert_history', 'time',
    chunk_time_interval => INTERVAL '1 day');

CREATE INDEX idx_alerts_patient_time ON alert_history (patient_id, time DESC);
CREATE INDEX idx_alerts_severity ON alert_history (severity);

-- Device session tracking
CREATE TABLE IF NOT EXISTS device_sessions (
    time TIMESTAMPTZ NOT NULL,
    device_id VARCHAR(100) NOT NULL,
    patient_id UUID,
    session_id UUID,
    status VARCHAR(20), -- connected, disconnected, error
    message TEXT,
    metadata JSONB
);

SELECT create_hypertable('device_sessions', 'time',
    chunk_time_interval => INTERVAL '1 day');

CREATE INDEX idx_sessions_device ON device_sessions (device_id, time DESC);
CREATE INDEX idx_sessions_patient ON device_sessions (patient_id);

-- Create function to check vital sign thresholds
CREATE OR REPLACE FUNCTION check_vital_threshold(
    p_patient_id UUID,
    p_metric VARCHAR(50),
    p_value DECIMAL
)
RETURNS TABLE (
    alert_needed BOOLEAN,
    severity VARCHAR(20),
    message TEXT
) AS $$
DECLARE
    threshold RECORD;
BEGIN
    -- Define thresholds (could be moved to a config table)
    SELECT
        CASE p_metric
            WHEN 'heart_rate' THEN (60, 100, 50, 120)
            WHEN 'bp_systolic' THEN (90, 140, 90, 180)
            WHEN 'bp_diastolic' THEN (60, 90, 60, 110)
            WHEN 'spo2' THEN (95, 100, 90, 95)
            WHEN 'temperature' THEN (36.5, 37.5, 35.0, 39.0)
            WHEN 'glucose' THEN (70, 100, 50, 180)
            ELSE (NULL, NULL, NULL, NULL)
        END INTO threshold;

    IF threshold IS NULL THEN
        RETURN QUERY SELECT FALSE, NULL::VARCHAR, NULL::TEXT;
    ELSIF p_value < threshold.column3 OR p_value > threshold.column4 THEN
        RETURN QUERY SELECT TRUE, 'critical',
            format('Critical %s reading: %s', p_metric, p_value);
    ELSIF p_value < threshold.column1 OR p_value > threshold.column2 THEN
        RETURN QUERY SELECT TRUE, 'warning',
            format('Abnormal %s reading: %s', p_metric, p_value);
    ELSE
        RETURN QUERY SELECT FALSE, NULL::VARCHAR, NULL::TEXT;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Create trigger function for automatic alert generation
CREATE OR REPLACE FUNCTION create_vital_alert()
RETURNS TRIGGER AS $$
DECLARE
    alert_check RECORD;
    alert_id UUID;
BEGIN
    -- Check if alert is needed
    SELECT * INTO alert_check
    FROM check_vital_threshold(NEW.patient_id, NEW.metric, NEW.value);

    IF alert_check.alert_needed THEN
        -- Insert into alert history
        INSERT INTO alert_history (
            time, patient_id, metric, value, threshold,
            severity, message, acknowledged, metadata
        ) VALUES (
            NEW.time, NEW.patient_id, NEW.metric, NEW.value,
            CASE alert_check.severity
                WHEN 'critical' THEN 1.5
                ELSE 1.0
            END,
            alert_check.severity, alert_check.message, FALSE, NEW.metadata
        ) RETURNING time INTO alert_id;

        -- Mark the vital sign as having triggered an alert
        NEW.alert_triggered := TRUE;

        -- Also insert into main alerts table (for real-time notification)
        -- This would be picked up by the notification service
        PERFORM pg_notify('vital_alerts', alert_id::TEXT);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Attach trigger to vital_signs table
CREATE TRIGGER vital_alert_trigger
    AFTER INSERT ON vital_signs
    FOR EACH ROW
    EXECUTE FUNCTION create_vital_alert();

-- Create view for current vital signs (latest reading per metric)
CREATE OR REPLACE VIEW current_vitals AS
SELECT DISTINCT ON (patient_id, metric)
    patient_id,
    metric,
    value,
    unit,
    time as last_updated,
    alert_triggered
FROM vital_signs
ORDER BY patient_id, metric, time DESC;

-- Create view for patient vital summary
CREATE OR REPLACE VIEW patient_vital_summary AS
SELECT
    patient_id,
    COUNT(DISTINCT metric) as metrics_tracked,
    MIN(time) as first_reading,
    MAX(time) as last_reading,
    COUNT(*) as total_readings,
    COUNT(CASE WHEN alert_triggered THEN 1 END) as total_alerts
FROM vital_signs
GROUP BY patient_id;

-- Create function to get vital trends
CREATE OR REPLACE FUNCTION get_vital_trend(
    p_patient_id UUID,
    p_metric VARCHAR(50),
    p_hours INTEGER
)
RETURNS TABLE (
    time_bucket TIMESTAMPTZ,
    avg_value DECIMAL,
    trend_direction VARCHAR(10)
) AS $$
BEGIN
    RETURN QUERY
    WITH hourly_avg AS (
        SELECT
            time_bucket('1 hour', time) as bucket,
            AVG(value) as avg_value
        FROM vital_signs
        WHERE patient_id = p_patient_id
        AND metric = p_metric
        AND time > NOW() - (p_hours || ' hours')::INTERVAL
        GROUP BY bucket
        ORDER BY bucket
    )
    SELECT
        bucket,
        avg_value,
        CASE
            WHEN LAG(avg_value) OVER (ORDER BY bucket) < avg_value THEN 'rising'
            WHEN LAG(avg_value) OVER (ORDER BY bucket) > avg_value THEN 'falling'
            ELSE 'stable'
        END as trend_direction
    FROM hourly_avg;
END;
$$ LANGUAGE plpgsql;

-- Create user permissions for IoT service
-- GRANT CONNECT ON DATABASE smamrasa_iot TO iot_admin;
-- GRANT USAGE ON SCHEMA public TO iot_admin;
-- GRANT SELECT, INSERT, UPDATE ON vital_signs TO iot_admin;
-- GRANT SELECT, INSERT, UPDATE ON iot_devices TO iot_admin;
-- GRANT SELECT ON current_vitals TO iot_admin;

-- Compression settings for optimal performance
ALTER TABLE vital_signs SET (
    timescaledb.compress,
    timescaledb.compress_segmentby = 'patient_id,metric'
);

ALTER TABLE alert_history SET (
    timescaledb.compress,
    timescaledb.compress_segmentby = 'patient_id'
);

ALTER TABLE device_sessions SET (
    timescaledb.compress,
    timescaledb.compress_segmentby = 'device_id'
);

-- Analyze for query optimization
ANALYZE;

-- Display schema info
\echo 'SMAMRASA IoT Time-Series Database Schema Created Successfully'
\echo 'Hypertables created:'
\echo '  - vital_signs (with compression and retention policies)'
\echo '  - alert_history'
\echo '  - device_sessions'
\echo ''
\echo 'Continuous Aggregates:'
\echo '  - vital_signs_5min (5-minute averages)'
\echo '  - vital_signs_hourly (hourly aggregates)'
\echo '  - vital_signs_daily (daily aggregates)'
\echo ''
\echo 'Triggers:'
\echo '  - Automatic alert generation on vital sign insertion'
\echo ''
\echo 'Functions:'
\echo '  - check_vital_threshold() - Check if vital exceeds thresholds'
\echo '  - get_vital_trend() - Get trend analysis for vitals'
