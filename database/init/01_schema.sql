-- ============================================
-- KYC Data Quality Platform - Database Schema
-- PostgreSQL 15+
-- ============================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================
-- 1. KYC CORE TABLES
-- ============================================

-- Users table (main KYC data)
CREATE TABLE IF NOT EXISTS users (
    user_id VARCHAR(50) PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    date_of_birth DATE NOT NULL,
    country_code VARCHAR(3) NOT NULL,
    address_line1 VARCHAR(255),
    address_line2 VARCHAR(255),
    city VARCHAR(100),
    postal_code VARCHAR(20),
    account_status VARCHAR(20) DEFAULT 'PENDING' CHECK (account_status IN ('PENDING', 'ACTIVE', 'SUSPENDED', 'CLOSED')),
    risk_level VARCHAR(20) DEFAULT 'UNKNOWN' CHECK (risk_level IN ('LOW', 'MEDIUM', 'HIGH', 'UNKNOWN')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_verified_at TIMESTAMP,
    CONSTRAINT email_format CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT phone_format CHECK (phone IS NULL OR phone ~ '^\+?[0-9]{10,15}$')
);

-- KYC Documents table
CREATE TABLE IF NOT EXISTS kyc_docs (
    doc_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id VARCHAR(50) NOT NULL,
    document_type VARCHAR(50) NOT NULL CHECK (document_type IN ('PASSPORT', 'NATIONAL_ID', 'DRIVERS_LICENSE', 'UTILITY_BILL', 'BANK_STATEMENT')),
    document_number VARCHAR(100) NOT NULL,
    issue_date DATE,
    expiry_date DATE,
    issuing_country VARCHAR(3),
    verification_status VARCHAR(20) DEFAULT 'PENDING' CHECK (verification_status IN ('PENDING', 'VERIFIED', 'REJECTED', 'EXPIRED')),
    verification_date TIMESTAMP,
    document_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT valid_dates CHECK (expiry_date IS NULL OR expiry_date > issue_date)
);

-- ============================================
-- 2. SODA SCAN RESULTS TABLES
-- ============================================

-- Scan execution metadata
CREATE TABLE IF NOT EXISTS soda_scan_results (
    scan_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    scan_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    scan_type VARCHAR(50) DEFAULT 'SCHEDULED',
    data_source VARCHAR(100) NOT NULL,
    total_checks INTEGER NOT NULL DEFAULT 0,
    checks_passed INTEGER NOT NULL DEFAULT 0,
    checks_failed INTEGER NOT NULL DEFAULT 0,
    checks_warned INTEGER NOT NULL DEFAULT 0,
    checks_not_evaluated INTEGER NOT NULL DEFAULT 0,
    scan_duration_seconds NUMERIC(10, 2),
    scan_status VARCHAR(20) DEFAULT 'COMPLETED' CHECK (scan_status IN ('RUNNING', 'COMPLETED', 'FAILED', 'CANCELLED')),
    error_message TEXT,
    soda_version VARCHAR(50),
    scan_definition TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT valid_check_counts CHECK (
        total_checks = checks_passed + checks_failed + checks_warned + checks_not_evaluated
    )
);

-- Individual check results
CREATE TABLE IF NOT EXISTS soda_check_results (
    check_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    scan_id UUID NOT NULL,
    check_name VARCHAR(255) NOT NULL,
    check_type VARCHAR(100) NOT NULL,
    table_name VARCHAR(255),
    column_name VARCHAR(255),
    check_outcome VARCHAR(20) NOT NULL CHECK (check_outcome IN ('PASS', 'FAIL', 'WARN', 'NOT_EVALUATED')),
    metric_value NUMERIC,
    expected_value VARCHAR(255),
    actual_value VARCHAR(255),
    check_definition TEXT,
    failure_message TEXT,
    execution_time_ms NUMERIC(10, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_scan FOREIGN KEY (scan_id) REFERENCES soda_scan_results(scan_id) ON DELETE CASCADE
);

-- Failed rows details
CREATE TABLE IF NOT EXISTS soda_failed_rows (
    failed_row_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    check_id UUID NOT NULL,
    scan_id UUID NOT NULL,
    table_name VARCHAR(255) NOT NULL,
    row_identifier VARCHAR(255),
    row_data JSONB NOT NULL,
    failure_reason TEXT,
    detected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    remediation_status VARCHAR(20) DEFAULT 'OPEN' CHECK (remediation_status IN ('OPEN', 'IN_PROGRESS', 'RESOLVED', 'IGNORED')),
    remediated_at TIMESTAMP,
    remediated_by VARCHAR(100),
    CONSTRAINT fk_check FOREIGN KEY (check_id) REFERENCES soda_check_results(check_id) ON DELETE CASCADE,
    CONSTRAINT fk_scan_failed FOREIGN KEY (scan_id) REFERENCES soda_scan_results(scan_id) ON DELETE CASCADE
);

-- ============================================
-- 3. AUDIT AND MONITORING TABLES
-- ============================================

-- Data quality metrics over time
CREATE TABLE IF NOT EXISTS dq_metrics_history (
    metric_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    metric_date DATE NOT NULL,
    table_name VARCHAR(255) NOT NULL,
    metric_type VARCHAR(100) NOT NULL,
    metric_value NUMERIC NOT NULL,
    threshold_lower NUMERIC,
    threshold_upper NUMERIC,
    is_anomaly BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_metric_per_day UNIQUE (metric_date, table_name, metric_type)
);

-- User activity audit log
CREATE TABLE IF NOT EXISTS audit_log (
    audit_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    event_type VARCHAR(50) NOT NULL,
    user_id VARCHAR(50),
    affected_table VARCHAR(255),
    affected_record_id VARCHAR(255),
    old_values JSONB,
    new_values JSONB,
    ip_address INET,
    user_agent TEXT,
    session_id VARCHAR(255)
);

-- ============================================
-- 4. INDEXES FOR PERFORMANCE
-- ============================================

-- Users table indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_created_at ON users(created_at);
CREATE INDEX idx_users_account_status ON users(account_status);
CREATE INDEX idx_users_risk_level ON users(risk_level);
CREATE INDEX idx_users_dob ON users(date_of_birth);
CREATE INDEX idx_users_country ON users(country_code);

-- KYC Documents indexes
CREATE INDEX idx_kyc_docs_user_id ON kyc_docs(user_id);
CREATE INDEX idx_kyc_docs_type ON kyc_docs(document_type);
CREATE INDEX idx_kyc_docs_status ON kyc_docs(verification_status);
CREATE INDEX idx_kyc_docs_expiry ON kyc_docs(expiry_date);
CREATE INDEX idx_kyc_docs_created_at ON kyc_docs(created_at);

-- Scan results indexes
CREATE INDEX idx_scan_timestamp ON soda_scan_results(scan_timestamp DESC);
CREATE INDEX idx_scan_status ON soda_scan_results(scan_status);
CREATE INDEX idx_scan_data_source ON soda_scan_results(data_source);

-- Check results indexes
CREATE INDEX idx_check_scan_id ON soda_check_results(scan_id);
CREATE INDEX idx_check_outcome ON soda_check_results(check_outcome);
CREATE INDEX idx_check_table ON soda_check_results(table_name);
CREATE INDEX idx_check_name ON soda_check_results(check_name);
CREATE INDEX idx_check_created_at ON soda_check_results(created_at DESC);

-- Failed rows indexes
CREATE INDEX idx_failed_check_id ON soda_failed_rows(check_id);
CREATE INDEX idx_failed_scan_id ON soda_failed_rows(scan_id);
CREATE INDEX idx_failed_table ON soda_failed_rows(table_name);
CREATE INDEX idx_failed_status ON soda_failed_rows(remediation_status);
CREATE INDEX idx_failed_detected_at ON soda_failed_rows(detected_at DESC);

-- Metrics history indexes
CREATE INDEX idx_metrics_date ON dq_metrics_history(metric_date DESC);
CREATE INDEX idx_metrics_table ON dq_metrics_history(table_name);
CREATE INDEX idx_metrics_type ON dq_metrics_history(metric_type);
CREATE INDEX idx_metrics_anomaly ON dq_metrics_history(is_anomaly) WHERE is_anomaly = TRUE;

-- Audit log indexes
CREATE INDEX idx_audit_timestamp ON audit_log(event_timestamp DESC);
CREATE INDEX idx_audit_user ON audit_log(user_id);
CREATE INDEX idx_audit_event_type ON audit_log(event_type);
CREATE INDEX idx_audit_table ON audit_log(affected_table);

-- ============================================
-- 5. PARTITIONING FOR SCALABILITY
-- ============================================

-- Partition scan results by month (for large-scale deployments)
-- Uncomment and adjust if needed:
-- 
-- CREATE TABLE soda_scan_results_2024_01 PARTITION OF soda_scan_results
--     FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');
-- 
-- CREATE TABLE soda_scan_results_2024_02 PARTITION OF soda_scan_results
--     FOR VALUES FROM ('2024-02-01') TO ('2024-03-01');

-- ============================================
-- 6. VIEWS FOR ANALYTICS
-- ============================================

-- Latest scan summary
CREATE OR REPLACE VIEW v_latest_scan_summary AS
SELECT 
    sr.scan_id,
    sr.scan_timestamp,
    sr.data_source,
    sr.total_checks,
    sr.checks_passed,
    sr.checks_failed,
    sr.checks_warned,
    sr.checks_not_evaluated,
    ROUND((sr.checks_passed::NUMERIC / NULLIF(sr.total_checks, 0) * 100), 2) AS success_rate,
    sr.scan_duration_seconds,
    sr.scan_status
FROM soda_scan_results sr
WHERE sr.scan_timestamp = (SELECT MAX(scan_timestamp) FROM soda_scan_results);

-- Failed checks summary by table
CREATE OR REPLACE VIEW v_failed_checks_by_table AS
SELECT 
    scr.table_name,
    COUNT(*) AS failed_checks_count,
    COUNT(DISTINCT scr.scan_id) AS scans_with_failures,
    MAX(sr.scan_timestamp) AS last_failure_timestamp,
    ARRAY_AGG(DISTINCT scr.check_type) AS failed_check_types
FROM soda_check_results scr
JOIN soda_scan_results sr ON scr.scan_id = sr.scan_id
WHERE scr.check_outcome = 'FAIL'
GROUP BY scr.table_name
ORDER BY failed_checks_count DESC;

-- Data quality trend (last 30 days)
CREATE OR REPLACE VIEW v_dq_trend_30d AS
SELECT 
    DATE(sr.scan_timestamp) AS scan_date,
    COUNT(DISTINCT sr.scan_id) AS total_scans,
    SUM(sr.checks_passed) AS total_passed,
    SUM(sr.checks_failed) AS total_failed,
    ROUND(AVG(sr.checks_passed::NUMERIC / NULLIF(sr.total_checks, 0) * 100), 2) AS avg_success_rate
FROM soda_scan_results sr
WHERE sr.scan_timestamp >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY DATE(sr.scan_timestamp)
ORDER BY scan_date DESC;

-- High-risk users with failed checks
CREATE OR REPLACE VIEW v_high_risk_users AS
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.risk_level,
    u.account_status,
    COUNT(DISTINCT sfr.failed_row_id) AS failed_checks_count,
    MAX(sfr.detected_at) AS last_issue_detected,
    ARRAY_AGG(DISTINCT sfr.failure_reason) AS failure_reasons
FROM users u
LEFT JOIN soda_failed_rows sfr ON u.user_id = sfr.row_data->>'user_id'
WHERE u.risk_level IN ('HIGH', 'MEDIUM')
GROUP BY u.user_id, u.first_name, u.last_name, u.email, u.risk_level, u.account_status
HAVING COUNT(DISTINCT sfr.failed_row_id) > 0
ORDER BY failed_checks_count DESC;

-- Document expiry monitoring
CREATE OR REPLACE VIEW v_expiring_documents AS
SELECT 
    kd.doc_id,
    kd.user_id,
    u.first_name,
    u.last_name,
    u.email,
    kd.document_type,
    kd.document_number,
    kd.expiry_date,
    (kd.expiry_date - CURRENT_DATE) AS days_until_expiry,
    kd.verification_status
FROM kyc_docs kd
JOIN users u ON kd.user_id = u.user_id
WHERE kd.expiry_date IS NOT NULL
  AND kd.expiry_date <= CURRENT_DATE + INTERVAL '90 days'
  AND kd.verification_status = 'VERIFIED'
ORDER BY kd.expiry_date ASC;

-- ============================================
-- 7. FUNCTIONS AND TRIGGERS
-- ============================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for users table
CREATE TRIGGER trigger_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger for kyc_docs table
CREATE TRIGGER trigger_kyc_docs_updated_at
    BEFORE UPDATE ON kyc_docs
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Function to calculate age from date of birth
CREATE OR REPLACE FUNCTION calculate_age(dob DATE)
RETURNS INTEGER AS $$
BEGIN
    RETURN DATE_PART('year', AGE(CURRENT_DATE, dob));
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Function to validate KYC completeness
CREATE OR REPLACE FUNCTION is_kyc_complete(p_user_id VARCHAR)
RETURNS BOOLEAN AS $$
DECLARE
    doc_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO doc_count
    FROM kyc_docs
    WHERE user_id = p_user_id
      AND verification_status = 'VERIFIED'
      AND document_type IN ('PASSPORT', 'NATIONAL_ID', 'DRIVERS_LICENSE');
    
    RETURN doc_count >= 1;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 8. ROLES AND PERMISSIONS
-- ============================================

-- Create read-only user for Streamlit dashboard
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'dashboard_readonly') THEN
        CREATE ROLE dashboard_readonly WITH LOGIN PASSWORD 'dashboard_readonly_pass';
    END IF;
END
$$;

GRANT CONNECT ON DATABASE kyc_platform TO dashboard_readonly;
GRANT USAGE ON SCHEMA public TO dashboard_readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO dashboard_readonly;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO dashboard_readonly;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO dashboard_readonly;

-- Create scanner user for Soda Core
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'soda_scanner') THEN
        CREATE ROLE soda_scanner WITH LOGIN PASSWORD 'soda_scanner_pass';
    END IF;
END
$$;

GRANT CONNECT ON DATABASE kyc_platform TO soda_scanner;
GRANT USAGE ON SCHEMA public TO soda_scanner;
GRANT SELECT ON users, kyc_docs TO soda_scanner;
GRANT SELECT, INSERT, UPDATE ON soda_scan_results, soda_check_results, soda_failed_rows TO soda_scanner;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO soda_scanner;

-- ============================================
-- 9. INITIAL CONFIGURATION DATA
-- ============================================

-- Insert system configuration (if needed)
-- This can be used for application-level settings

-- ============================================
-- 10. MAINTENANCE PROCEDURES
-- ============================================

-- Function to archive old scan results
CREATE OR REPLACE FUNCTION archive_old_scan_results(days_to_keep INTEGER DEFAULT 90)
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    WITH deleted AS (
        DELETE FROM soda_scan_results
        WHERE scan_timestamp < CURRENT_DATE - (days_to_keep || ' days')::INTERVAL
        RETURNING scan_id
    )
    SELECT COUNT(*) INTO deleted_count FROM deleted;
    
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- Function to calculate table statistics
CREATE OR REPLACE FUNCTION refresh_table_statistics()
RETURNS VOID AS $$
BEGIN
    ANALYZE users;
    ANALYZE kyc_docs;
    ANALYZE soda_scan_results;
    ANALYZE soda_check_results;
    ANALYZE soda_failed_rows;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SCHEMA CREATION COMPLETE
-- ============================================

-- Grant all necessary permissions
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO kyc_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO kyc_admin;

-- Success message
DO $$
BEGIN
    RAISE NOTICE 'KYC Data Quality Platform schema created successfully!';
    RAISE NOTICE 'Total tables created: %', (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE');
    RAISE NOTICE 'Total views created: %', (SELECT COUNT(*) FROM information_schema.views WHERE table_schema = 'public');
    RAISE NOTICE 'Total indexes created: %', (SELECT COUNT(*) FROM pg_indexes WHERE schemaname = 'public');
END $$;
