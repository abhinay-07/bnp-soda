# 🚀 SODA-V3 Complete Setup & Deployment Guide

**Complete step-by-step commands to run the project on any system**

---

## 📋 Prerequisites

Before starting, ensure you have installed:

### Windows Systems
```powershell
# Check if Docker is installed
docker --version

# Check if Docker Compose is installed
docker-compose --version

# Check if Git is installed
git --version
```

### Mac/Linux Systems
```bash
# Check if Docker is installed
docker --version

# Check if Docker Compose is installed
docker-compose --version

# Check if Git is installed
git --version
```

**Required Software:**
- Docker Desktop (with Docker Compose included)
- Git
- A terminal/PowerShell
- At least 8GB RAM available
- 5GB free disk space

---

## 🔽 Step 1: Clone the Project

### On Windows (PowerShell)
```powershell
# Navigate to your projects directory
cd C:\Users\YourUsername\Documents

# Clone the repository
git clone https://github.com/yourusername/SODA-V3.git

# Navigate into the project
cd SODA-V3

# List the project structure to verify
dir
```

### On Mac/Linux
```bash
# Navigate to your projects directory
cd ~/projects

# Clone the repository
git clone https://github.com/yourusername/SODA-V3.git

# Navigate into the project
cd SODA-V3

# List the project structure to verify
ls -la
```

**Expected Output:**
```
ARCHITECTURE.md
docker-compose.yml
COMPLETE_PROJECT_GUIDE.md
dashboard/
database/
soda/
quick-start.ps1
README.md
```

---

## 🐳 Step 2: Install Docker & Docker Compose

### For Windows
```powershell
# Download and install Docker Desktop from:
# https://www.docker.com/products/docker-desktop

# After installation, verify:
docker --version
# Expected: Docker version 24.0.0 or higher

docker-compose --version
# Expected: Docker Compose version 2.x.x or higher

# Start Docker Desktop
# Open Windows Start menu → Search for "Docker Desktop" → Click to launch
# Wait for Docker icon to appear in system tray (2-3 minutes)

# Verify Docker is running
docker ps
# Should show: CONTAINER ID IMAGE COMMAND CREATED STATUS PORTS NAMES
# (empty list is OK on first run)
```

### For Mac
```bash
# Download and install Docker Desktop from:
# https://www.docker.com/products/docker-desktop

# After installation, verify:
docker --version
docker-compose --version

# Start Docker Desktop
# Open Applications → Docker.app → Wait for "Docker is running" notification

# Verify Docker is running
docker ps
```

### For Linux (Ubuntu/Debian)
```bash
# Install Docker
sudo apt-get update
sudo apt-get install -y docker.io docker-compose

# Add your user to docker group
sudo usermod -aG docker $USER

# Apply group changes
newgrp docker

# Verify installation
docker --version
docker-compose --version
docker ps
```

---

## 📁 Step 3: Verify Project Structure

### Windows PowerShell
```powershell
# Navigate to project root
cd SODA-V3

# Check main files exist
Test-Path COMPLETE_PROJECT_GUIDE.md
Test-Path docker-compose.yml
Test-Path quick-start.ps1

# Check directories exist
Test-Path database
Test-Path soda
Test-Path dashboard

# View full structure
tree /F
```

### Mac/Linux
```bash
# Navigate to project root
cd SODA-V3

# Check main files exist
ls -la COMPLETE_PROJECT_GUIDE.md
ls -la docker-compose.yml

# Check directories exist
ls -la database/
ls -la soda/
ls -la dashboard/

# View full structure
tree -L 3
```

---

## ⚙️ Step 4: Environment Configuration

### Windows PowerShell
```powershell
# Navigate to project root
cd SODA-V3

# Create .env file with configuration
$envContent = @"
# PostgreSQL Configuration
POSTGRES_HOST=postgres
POSTGRES_PORT=5432
POSTGRES_DB=kyc_platform
POSTGRES_USER=kyc_admin
POSTGRES_PASSWORD=kyc_secure_pass_2024

# Streamlit Configuration
STREAMLIT_PORT=8501
STREAMLIT_SERVER_HEADLESS=true

# SODA Configuration
SODA_SCAN_SCHEDULE=0 */6 * * *
LOG_LEVEL=INFO

# Environment
ENVIRONMENT=development
"@

# Write to file
$envContent | Out-File -FilePath .env -Encoding UTF8 -NoNewline

# Verify file created
Get-Content .env
```

### Mac/Linux
```bash
# Navigate to project root
cd SODA-V3

# Create .env file with configuration
cat > .env << 'EOF'
# PostgreSQL Configuration
POSTGRES_HOST=postgres
POSTGRES_PORT=5432
POSTGRES_DB=kyc_platform
POSTGRES_USER=kyc_admin
POSTGRES_PASSWORD=kyc_secure_pass_2024

# Streamlit Configuration
STREAMLIT_PORT=8501
STREAMLIT_SERVER_HEADLESS=true

# SODA Configuration
SODA_SCAN_SCHEDULE=0 */6 * * *
LOG_LEVEL=INFO

# Environment
ENVIRONMENT=development
EOF

# Verify file created
cat .env
```

---

## 🏗️ Step 5: Start Docker Services

### Windows PowerShell

```powershell
# Navigate to project root (if not already there)
cd SODA-V3

# Pull latest images (first time only)
docker-compose pull

# Build custom Docker images
docker-compose build

# Start all services in background
docker-compose up -d

# Wait for services to initialize (2-3 minutes)
Start-Sleep -Seconds 30

# Check service status
docker-compose ps

# Expected output:
# CONTAINER ID IMAGE COMMAND CREATED STATUS PORTS NAMES
# xxxxx postgres:15-alpine ... Healthy 0.0.0.0:5432->5432/tcp kyc-postgres
# xxxxx soda-v3-soda ... Up ... kyc-soda-scheduler
# xxxxx soda-v3-streamlit ... Healthy 0.0.0.0:8501->8501/tcp kyc-streamlit-dashboard
```

### Mac/Linux
```bash
# Navigate to project root
cd SODA-V3

# Pull latest images
docker-compose pull

# Build custom images
docker-compose build

# Start all services
docker-compose up -d

# Wait for services
sleep 30

# Check service status
docker-compose ps

# Monitor logs while starting
docker-compose logs -f
# Press Ctrl+C to stop monitoring
```

---

## 📊 Step 6: Initialize Database

### Windows PowerShell

```powershell
# Wait for PostgreSQL to be healthy
Write-Host "Waiting for PostgreSQL to initialize..."
Start-Sleep -Seconds 20

# Verify database is running
docker-compose exec -T postgres psql -U kyc_admin -d kyc_platform -c "SELECT 1;"

# View database tables
docker-compose exec -T postgres psql -U kyc_admin -d kyc_platform -c "\dt"

# Expected tables:
# users, kyc_docs, soda_scan_results, soda_check_results, etc.

# Check sample data
docker-compose exec -T postgres psql -U kyc_admin -d kyc_platform -c "SELECT COUNT(*) as user_count FROM users;"

# If user_count is 0, insert sample data
Write-Host "Inserting sample data if needed..."
```

### Mac/Linux
```bash
# Wait for PostgreSQL
sleep 20

# Verify database connection
docker-compose exec -T postgres psql -U kyc_admin -d kyc_platform -c "SELECT 1;"

# View tables
docker-compose exec -T postgres psql -U kyc_admin -d kyc_platform -c "\dt"

# Check data
docker-compose exec -T postgres psql -U kyc_admin -d kyc_platform -c "SELECT COUNT(*) FROM users;"
```

---

## 👥 Step 7: Load Sample Data (If Needed)

### Windows PowerShell

```powershell
# Create temporary SQL file with sample data
$sampleDataSQL = @"
-- Insert sample users if table is empty
INSERT INTO users (user_id, first_name, last_name, email, phone, date_of_birth, country_code, account_status, risk_level) 
SELECT 'USR001', 'John', 'Doe', 'john.doe@example.com', '+14155552671', '1990-01-15', 'USA', 'ACTIVE', 'LOW'
WHERE NOT EXISTS (SELECT 1 FROM users WHERE user_id = 'USR001')
UNION ALL
SELECT 'USR002', 'Jane', 'Smith', 'jane.smith@example.com', '+441632960000', '1985-06-20', 'GBR', 'ACTIVE', 'MEDIUM'
WHERE NOT EXISTS (SELECT 1 FROM users WHERE user_id = 'USR002')
UNION ALL
SELECT 'USR003', 'Bob', 'Johnson', 'bob.johnson@example.com', '+61299999999', '1992-03-10', 'AUS', 'SUSPENDED', 'HIGH'
WHERE NOT EXISTS (SELECT 1 FROM users WHERE user_id = 'USR003')
UNION ALL
SELECT 'USR004', 'Alice', 'Williams', 'alice.williams@example.com', '+33123456789', '1988-11-25', 'FRA', 'ACTIVE', 'LOW'
WHERE NOT EXISTS (SELECT 1 FROM users WHERE user_id = 'USR004')
UNION ALL
SELECT 'USR005', 'Charlie', 'Brown', 'charlie.brown@example.com', '+49123456789', '1995-07-30', 'DEU', 'PENDING', 'UNKNOWN'
WHERE NOT EXISTS (SELECT 1 FROM users WHERE user_id = 'USR005')
UNION ALL
SELECT 'USR006', 'Diana', 'Davis', 'diana.davis@example.com', '+34912345678', '1980-02-14', 'ESP', 'ACTIVE', 'MEDIUM'
WHERE NOT EXISTS (SELECT 1 FROM users WHERE user_id = 'USR006')
UNION ALL
SELECT 'USR007', 'Eve', 'Wilson', 'eve.wilson@example.com', '+39123456789', '1993-09-05', 'ITA', 'CLOSED', 'LOW'
WHERE NOT EXISTS (SELECT 1 FROM users WHERE user_id = 'USR007')
UNION ALL
SELECT 'USR008', 'Frank', 'Miller', 'frank.miller@example.com', '+16175550123', '1987-04-22', 'USA', 'ACTIVE', 'MEDIUM'
WHERE NOT EXISTS (SELECT 1 FROM users WHERE user_id = 'USR008')
UNION ALL
SELECT 'USR009', 'Grace', 'Taylor', 'grace.taylor@example.com', '+12025550173', '1991-12-11', 'USA', 'ACTIVE', 'LOW'
WHERE NOT EXISTS (SELECT 1 FROM users WHERE user_id = 'USR009')
UNION ALL
SELECT 'USR010', 'Henry', 'Anderson', 'henry.anderson@example.com', '+18005550174', '1989-08-30', 'USA', 'SUSPENDED', 'HIGH'
WHERE NOT EXISTS (SELECT 1 FROM users WHERE user_id = 'USR010');

-- Insert sample documents
INSERT INTO kyc_docs (user_id, document_type, document_number, issue_date, expiry_date, issuing_country, verification_status) 
SELECT 'USR001', 'PASSPORT', 'GB123456789', '2020-01-15', '2030-01-15', 'GBR', 'VERIFIED'
WHERE NOT EXISTS (SELECT 1 FROM kyc_docs WHERE document_number = 'GB123456789')
UNION ALL
SELECT 'USR002', 'NATIONAL_ID', 'ID987654321', '2021-06-20', '2031-06-20', 'GBR', 'VERIFIED'
WHERE NOT EXISTS (SELECT 1 FROM kyc_docs WHERE document_number = 'ID987654321')
UNION ALL
SELECT 'USR003', 'DRIVERS_LICENSE', 'DL456789012', '2019-03-10', '2029-03-10', 'GBR', 'VERIFIED'
WHERE NOT EXISTS (SELECT 1 FROM kyc_docs WHERE document_number = 'DL456789012')
UNION ALL
SELECT 'USR004', 'PASSPORT', 'GB234567890', '2022-05-12', '2032-05-12', 'GBR', 'VERIFIED'
WHERE NOT EXISTS (SELECT 1 FROM kyc_docs WHERE document_number = 'GB234567890')
UNION ALL
SELECT 'USR005', 'NATIONAL_ID', 'ID123456789', '2020-11-08', '2030-11-08', 'GBR', 'VERIFIED'
WHERE NOT EXISTS (SELECT 1 FROM kyc_docs WHERE document_number = 'ID123456789')
UNION ALL
SELECT 'USR006', 'PASSPORT', 'ES234567890', '2021-02-14', '2031-02-14', 'ESP', 'VERIFIED'
WHERE NOT EXISTS (SELECT 1 FROM kyc_docs WHERE document_number = 'ES234567890')
UNION ALL
SELECT 'USR007', 'NATIONAL_ID', 'FR987654321', '2020-09-25', '2030-09-25', 'FRA', 'VERIFIED'
WHERE NOT EXISTS (SELECT 1 FROM kyc_docs WHERE document_number = 'FR987654321')
UNION ALL
SELECT 'USR008', 'PASSPORT', 'GB345678901', '2023-01-18', '2033-01-18', 'GBR', 'VERIFIED'
WHERE NOT EXISTS (SELECT 1 FROM kyc_docs WHERE document_number = 'GB345678901')
UNION ALL
SELECT 'USR009', 'DRIVERS_LICENSE', 'DL567890123', '2021-07-22', '2031-07-22', 'GBR', 'VERIFIED'
WHERE NOT EXISTS (SELECT 1 FROM kyc_docs WHERE document_number = 'DL567890123')
UNION ALL
SELECT 'USR010', 'PASSPORT', 'GB456789012', '2022-11-30', '2032-11-30', 'GBR', 'PENDING'
WHERE NOT EXISTS (SELECT 1 FROM kyc_docs WHERE document_number = 'GB456789012');
"@

# Save to temporary file
$sampleDataSQL | Out-File -FilePath "temp_sample_data.sql" -Encoding UTF8

# Copy to PostgreSQL container
docker cp "temp_sample_data.sql" kyc-postgres:/tmp/sample_data.sql

# Execute in database
docker-compose exec -T postgres psql -U kyc_admin -d kyc_platform -f /tmp/sample_data.sql

# Verify data was inserted
docker-compose exec -T postgres psql -U kyc_admin -d kyc_platform -c "SELECT COUNT(*) as total_users FROM users;"
docker-compose exec -T postgres psql -U kyc_admin -d kyc_platform -c "SELECT COUNT(*) as total_docs FROM kyc_docs;"

# Clean up
Remove-Item "temp_sample_data.sql" -Force
```

### Mac/Linux
```bash
# Create temporary SQL file
cat > temp_sample_data.sql << 'EOF'
-- Insert sample users
INSERT INTO users (user_id, first_name, last_name, email, phone, date_of_birth, country_code, account_status, risk_level) 
VALUES
('USR001', 'John', 'Doe', 'john.doe@example.com', '+14155552671', '1990-01-15', 'USA', 'ACTIVE', 'LOW'),
('USR002', 'Jane', 'Smith', 'jane.smith@example.com', '+441632960000', '1985-06-20', 'GBR', 'ACTIVE', 'MEDIUM'),
('USR003', 'Bob', 'Johnson', 'bob.johnson@example.com', '+61299999999', '1992-03-10', 'AUS', 'SUSPENDED', 'HIGH'),
('USR004', 'Alice', 'Williams', 'alice.williams@example.com', '+33123456789', '1988-11-25', 'FRA', 'ACTIVE', 'LOW'),
('USR005', 'Charlie', 'Brown', 'charlie.brown@example.com', '+49123456789', '1995-07-30', 'DEU', 'PENDING', 'UNKNOWN'),
('USR006', 'Diana', 'Davis', 'diana.davis@example.com', '+34912345678', '1980-02-14', 'ESP', 'ACTIVE', 'MEDIUM'),
('USR007', 'Eve', 'Wilson', 'eve.wilson@example.com', '+39123456789', '1993-09-05', 'ITA', 'CLOSED', 'LOW'),
('USR008', 'Frank', 'Miller', 'frank.miller@example.com', '+16175550123', '1987-04-22', 'USA', 'ACTIVE', 'MEDIUM'),
('USR009', 'Grace', 'Taylor', 'grace.taylor@example.com', '+12025550173', '1991-12-11', 'USA', 'ACTIVE', 'LOW'),
('USR010', 'Henry', 'Anderson', 'henry.anderson@example.com', '+18005550174', '1989-08-30', 'USA', 'SUSPENDED', 'HIGH')
ON CONFLICT DO NOTHING;

-- Insert sample documents
INSERT INTO kyc_docs (user_id, document_type, document_number, issue_date, expiry_date, issuing_country, verification_status) 
VALUES
('USR001', 'PASSPORT', 'GB123456789', '2020-01-15', '2030-01-15', 'GBR', 'VERIFIED'),
('USR002', 'NATIONAL_ID', 'ID987654321', '2021-06-20', '2031-06-20', 'GBR', 'VERIFIED'),
('USR003', 'DRIVERS_LICENSE', 'DL456789012', '2019-03-10', '2029-03-10', 'GBR', 'VERIFIED'),
('USR004', 'PASSPORT', 'GB234567890', '2022-05-12', '2032-05-12', 'GBR', 'VERIFIED'),
('USR005', 'NATIONAL_ID', 'ID123456789', '2020-11-08', '2030-11-08', 'GBR', 'VERIFIED'),
('USR006', 'PASSPORT', 'ES234567890', '2021-02-14', '2031-02-14', 'ESP', 'VERIFIED'),
('USR007', 'NATIONAL_ID', 'FR987654321', '2020-09-25', '2030-09-25', 'FRA', 'VERIFIED'),
('USR008', 'PASSPORT', 'GB345678901', '2023-01-18', '2033-01-18', 'GBR', 'VERIFIED'),
('USR009', 'DRIVERS_LICENSE', 'DL567890123', '2021-07-22', '2031-07-22', 'GBR', 'VERIFIED'),
('USR010', 'PASSPORT', 'GB456789012', '2022-11-30', '2032-11-30', 'GBR', 'PENDING')
ON CONFLICT DO NOTHING;
EOF

# Copy and execute
docker cp temp_sample_data.sql kyc-postgres:/tmp/sample_data.sql
docker-compose exec -T postgres psql -U kyc_admin -d kyc_platform -f /tmp/sample_data.sql

# Verify
docker-compose exec -T postgres psql -U kyc_admin -d kyc_platform -c "SELECT COUNT(*) as total_users FROM users;"
docker-compose exec -T postgres psql -U kyc_admin -d kyc_platform -c "SELECT COUNT(*) as total_docs FROM kyc_docs;"

# Clean up
rm temp_sample_data.sql
```

---

## ▶️ Step 8: Run SODA Data Quality Scan

### Windows PowerShell

```powershell
# Option 1: Run manual scan (takes ~2 minutes)
docker-compose run --rm soda python /app/scripts/run_scan.py

# Wait for scan to complete
# Expected output will show:
# - 60 total checks
# - ~50 passed
# - ~4 failed
# - Scan duration in seconds

# Option 2: Check scan status without running
docker-compose exec -T postgres psql -U kyc_admin -d kyc_platform -c "SELECT total_checks, checks_passed, checks_failed FROM soda_scan_results ORDER BY scan_timestamp DESC LIMIT 1;"

# Option 3: View all recent scans
docker-compose exec -T postgres psql -U kyc_admin -d kyc_platform -c "SELECT scan_id, scan_timestamp, total_checks, checks_passed, checks_failed FROM soda_scan_results ORDER BY scan_timestamp DESC LIMIT 5;"
```

### Mac/Linux
```bash
# Run manual scan
docker-compose run --rm soda python /app/scripts/run_scan.py

# Wait for completion...

# Check results in database
docker-compose exec -T postgres psql -U kyc_admin -d kyc_platform -c "SELECT total_checks, checks_passed, checks_failed FROM soda_scan_results ORDER BY scan_timestamp DESC LIMIT 1;"

# View all scans
docker-compose exec -T postgres psql -U kyc_admin -d kyc_platform -c "SELECT scan_id, scan_timestamp, total_checks, checks_passed, checks_failed FROM soda_scan_results ORDER BY scan_timestamp DESC LIMIT 5;"
```

---

## 🌐 Step 9: Access the Dashboard

### Windows PowerShell

```powershell
# Option 1: Open dashboard automatically
Start-Process "http://localhost:8501"

# Option 2: Manual URL
# Copy and paste this into your browser:
# http://localhost:8501

# Option 3: View dashboard logs
docker-compose logs -f streamlit

# Expected to see:
# Streamlit running at http://localhost:8501
# Multiple GET requests as you interact with the dashboard
```

### Mac/Linux
```bash
# Option 1: Open dashboard
open http://localhost:8501

# Option 2: Linux - open with default browser
xdg-open http://localhost:8501

# Option 3: View logs
docker-compose logs -f streamlit
```

**What you should see:**
- Dashboard with real-time metrics
- Total Checks: 60
- Success Rate: ~83%
- Failed Checks: 4
- Multiple pages: Overview, Failed Checks, Scan History, Fraud Detection

---

## 📋 Step 10: Verify All Services Are Running

### Windows PowerShell

```powershell
# Check all containers are healthy
docker-compose ps

# Expected output:
# NAME                    STATUS
# kyc-postgres           Healthy
# kyc-streamlit-dashboard Healthy
# kyc-soda-scheduler     Up
# kyc-soda-scanner       (may not be running, that's OK)

# Check database is accessible
docker-compose exec -T postgres psql -U kyc_admin -d kyc_platform -c "SELECT NOW();"

# Check all tables exist
docker-compose exec -T postgres psql -U kyc_admin -d kyc_platform -c "\dt"

# Check views exist
docker-compose exec -T postgres psql -U kyc_admin -d kyc_platform -c "\dv"

# View service logs
docker-compose logs

# View specific service logs
docker-compose logs postgres
docker-compose logs streamlit
docker-compose logs kyc-soda-scheduler
```

### Mac/Linux
```bash
# Check status
docker-compose ps

# Test database
docker-compose exec -T postgres psql -U kyc_admin -d kyc_platform -c "SELECT NOW();"

# List tables
docker-compose exec -T postgres psql -U kyc_admin -d kyc_platform -c "\dt"

# View logs
docker-compose logs -f
```

---

## 🛠️ Common Troubleshooting Commands

### Windows PowerShell

```powershell
# Problem: Port 8501 already in use
netstat -ano | findstr ":8501"
# Kill the process (replace PID with actual process ID)
taskkill /PID <PID> /F

# Problem: Docker daemon not running
# Solution: Open Docker Desktop application

# Problem: Database connection error
# Check PostgreSQL is running
docker-compose exec -T postgres psql -U kyc_admin -c "SELECT 1;"

# Problem: Streamlit not loading
docker-compose logs streamlit | tail -50

# Problem: Clean restart of everything
docker-compose down -v  # WARNING: This deletes all data!
docker system prune -a
docker-compose up -d

# Problem: See detailed logs for debugging
docker-compose logs --tail=100 --follow

# Problem: Check disk space
Get-Volume

# Problem: Restart specific service
docker-compose restart streamlit
docker-compose restart postgres
```

### Mac/Linux
```bash
# Check port usage
lsof -i :8501

# Kill process on port
kill -9 $(lsof -ti :8501)

# Full restart
docker-compose down -v
docker system prune -a
docker-compose up -d

# View logs
docker-compose logs -f --tail=100

# Check disk space
df -h

# Restart specific service
docker-compose restart streamlit
```

---

## 📊 Step 11: Monitor and Maintain

### Windows PowerShell

```powershell
# Monitor in real-time
docker-compose logs -f

# Check for errors
docker-compose logs | findstr "ERROR"

# View resource usage
docker stats

# Backup database
docker-compose exec -T postgres pg_dump -U kyc_admin kyc_platform > backup_$(Get-Date -Format "yyyy-MM-dd").sql

# List all backups
Get-ChildItem backup_*.sql | Sort-Object LastWriteTime -Descending

# Restore from backup (replace filename)
Get-Content "backup_2026-02-26.sql" | docker-compose exec -T postgres psql -U kyc_admin -d kyc_platform
```

### Mac/Linux
```bash
# Monitor logs
docker-compose logs -f

# Find errors
docker-compose logs | grep ERROR

# Resource usage
docker stats

# Backup database
docker-compose exec -T postgres pg_dump -U kyc_admin kyc_platform > backup_$(date +%Y-%m-%d).sql

# Restore backup
cat backup_2026-02-26.sql | docker-compose exec -T postgres psql -U kyc_admin -d kyc_platform
```

---

## 🔄 Step 12: Common Operations

### Run Scheduled Scan
```bash
# Windows PowerShell
docker-compose run --rm soda python /app/scripts/run_scan.py

# Mac/Linux
docker-compose run --rm soda python /app/scripts/run_scan.py
```

### Stop All Services (Keep Data)
```bash
docker-compose down
```

### Stop and Delete Everything (Data Loss!)
```bash
docker-compose down -v
```

### View Database Contents
```bash
# Windows PowerShell
docker-compose exec -T postgres psql -U kyc_admin -d kyc_platform -c "SELECT * FROM soda_scan_results LIMIT 5;"

# Mac/Linux
docker-compose exec -T postgres psql -U kyc_admin -d kyc_platform -c "SELECT * FROM soda_scan_results LIMIT 5;"
```

### Update Configuration
```bash
# 1. Edit .env file
# 2. Restart services
docker-compose down
docker-compose up -d
```

### View Application Logs
```bash
# Windows PowerShell
docker-compose logs streamlit --tail=100

# Mac/Linux
docker-compose logs streamlit --tail=100
```

### Execute Direct SQL Query
```bash
# Windows PowerShell
docker-compose exec -T postgres psql -U kyc_admin -d kyc_platform -c "SELECT COUNT(*) as user_count FROM users;"

# Mac/Linux
docker-compose exec -T postgres psql -U kyc_admin -d kyc_platform -c "SELECT COUNT(*) as user_count FROM users;"
```

---

## 📱 Quick Access URLs & Credentials

### Dashboard Access
```
URL: http://localhost:8501
Refresh: Auto-refreshes every 30 seconds
Browser: Chrome, Firefox, Safari, Edge (all supported)
```

### Database Access (for Advanced Users)
```bash
# Using psql command line
docker-compose exec postgres psql -U kyc_admin -d kyc_platform

# Connection details:
Host: localhost
Port: 5432
Database: kyc_platform
Username: kyc_admin
Password: kyc_secure_pass_2024
```

### Using Database GUI Tools (DBeaver, pgAdmin)
```
Host: localhost
Port: 5432
Database: kyc_platform
Username: kyc_admin
Password: kyc_secure_pass_2024
SSL: Not required for local
```

---

## 🔐 Security Notes

### For Development (Current Setup)
- Password stored in .env file (OK for local development)
- No SSL/TLS encryption needed locally
- All containers on isolated network

### For Production
```bash
# You MUST:
# 1. Change database password
# 2. Enable SSL/TLS
# 3. Use environment-specific configs
# 4. Add authentication to Streamlit
# 5. Set up firewall rules
# 6. Use secrets management (AWS Secrets, Azure Key Vault, etc.)
# 7. Enable audit logging
# 8. Regular backups
```

---

## 📞 Quick Help Commands

### Windows PowerShell

```powershell
# Health check - are all services running?
docker-compose ps | findstr "Healthy"

# How many users in database?
docker-compose exec -T postgres psql -U kyc_admin -d kyc_platform -c "SELECT COUNT(*) FROM users;"

# When was last scan?
docker-compose exec -T postgres psql -U kyc_admin -d kyc_platform -c "SELECT MAX(scan_timestamp) FROM soda_scan_results;"

# What's the current data quality score?
docker-compose exec -T postgres psql -U kyc_admin -d kyc_platform -c "SELECT (checks_passed::float / total_checks * 100)::int as quality_score FROM soda_scan_results ORDER BY scan_timestamp DESC LIMIT 1;"

# Is the dashboard responsive?
curl http://localhost:8501 -s | findstr "html" > $null && Write-Host "✓ Dashboard is running" || Write-Host "✗ Dashboard is not responding"
```

### Mac/Linux

```bash
# Health check
docker-compose ps | grep Healthy

# User count
docker-compose exec -T postgres psql -U kyc_admin -d kyc_platform -c "SELECT COUNT(*) FROM users;"

# Last scan time
docker-compose exec -T postgres psql -U kyc_admin -d kyc_platform -c "SELECT MAX(scan_timestamp) FROM soda_scan_results;"

# Quality score
docker-compose exec -T postgres psql -U kyc_admin -d kyc_platform -c "SELECT (checks_passed::float / total_checks * 100)::int as quality_score FROM soda_scan_results ORDER BY scan_timestamp DESC LIMIT 1;"

# Dashboard health
curl -s http://localhost:8501 | grep -q "html" && echo "✓ Dashboard is running" || echo "✗ Dashboard is down"
```

---

## 🎯 Complete Setup Summary

### Minimal Setup (Quick Start) - 5 minutes
```bash
cd SODA-V3
docker-compose up -d
# Wait 2 minutes
open http://localhost:8501
```

### Full Setup (Production Ready) - 15 minutes
```bash
# 1. Clone
git clone https://github.com/yourusername/SODA-V3.git
cd SODA-V3

# 2. Configure
# Create .env file with credentials

# 3. Start
docker-compose up -d

# 4. Initialize
docker-compose run --rm soda python /app/scripts/run_scan.py

# 5. Access
open http://localhost:8501

# 6. Monitor
docker-compose logs -f
```

---

## ✅ Verification Checklist

Run this after setup to verify everything works:

### Windows PowerShell
```powershell
Write-Host "Checking Docker..."
docker --version
docker-compose --version

Write-Host "Checking containers..."
docker-compose ps

Write-Host "Checking database..."
docker-compose exec -T postgres psql -U kyc_admin -d kyc_platform -c "SELECT COUNT(*) FROM users;"

Write-Host "Checking dashboard..."
$response = curl -s http://localhost:8501
if ($response -match "html") { Write-Host "✓ Dashboard is running" } else { Write-Host "✗ Dashboard check failed" }

Write-Host "Checking SODA results..."
docker-compose exec -T postgres psql -U kyc_admin -d kyc_platform -c "SELECT COUNT(*) FROM soda_scan_results;"

Write-Host "All checks complete!"
```

### Mac/Linux
```bash
echo "Checking Docker..."
docker --version
docker-compose --version

echo "Checking containers..."
docker-compose ps

echo "Checking database..."
docker-compose exec -T postgres psql -U kyc_admin -d kyc_platform -c "SELECT COUNT(*) FROM users;"

echo "Checking dashboard..."
curl -s http://localhost:8501 | grep -q "html" && echo "✓ Dashboard is running" || echo "✗ Dashboard check failed"

echo "Checking SODA results..."
docker-compose exec -T postgres psql -U kyc_admin -d kyc_platform -c "SELECT COUNT(*) FROM soda_scan_results;"

echo "All checks complete!"
```

---

## 🆘 Need Help?

### Service Won't Start
```bash
# Check logs
docker-compose logs <service-name>

# Restart service
docker-compose restart <service-name>

# Full restart
docker-compose restart
```

### Database Issues
```bash
# Connect directly to database
docker-compose exec postgres psql -U kyc_admin -d kyc_platform

# Run SQL commands
\dt  # List tables
\dv  # List views
SELECT * FROM users LIMIT 1;
```

### Dashboard Not Loading
```bash
# Check Streamlit is running
docker-compose ps | grep streamlit

# View Streamlit logs
docker-compose logs streamlit

# Restart Streamlit
docker-compose restart streamlit

# Check port is available
netstat -an | grep 8501
```

### Memory/CPU Issues
```bash
# Check resource usage
docker stats

# Increase Docker resources in Settings
# Docker Desktop → Preferences → Resources
```

---

**Last Updated:** February 26, 2026  
**Status:** Production Ready  
**Version:** 1.0.0
