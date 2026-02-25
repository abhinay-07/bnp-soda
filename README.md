# 🚀 KYC Data Quality Platform - Deployment Guide

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Quick Start](#quick-start)
3. [Detailed Setup](#detailed-setup)
4. [Running Data Quality Scans](#running-scans)
5. [Accessing the Dashboard](#accessing-dashboard)
6. [Troubleshooting](#troubleshooting)
7. [Production Deployment](#production-deployment)
8. [Maintenance & Operations](#maintenance)

---

## 🔧 Prerequisites

### Required Software

- **Docker**: Version 20.10 or higher
- **Docker Compose**: Version 2.0 or higher
- **Git**: For cloning the repository
- **Minimum Resources**:
  - 4 GB RAM
  - 10 GB disk space
  - 2 CPU cores

### Verify Installation

```powershell
# Check Docker
docker --version
# Expected: Docker version 20.10+

# Check Docker Compose
docker-compose --version
# Expected: Docker Compose version 2.0+

# Check Docker is running
docker ps
```

---

## ⚡ Quick Start (5 Minutes)

### Step 1: Clone Repository

```powershell
cd "D:\BNP Projects"
git clone <your-repo-url> SODA-V3
cd SODA-V3
```

### Step 2: Configure Environment

```powershell
# Copy environment template
Copy-Item .env.example .env

# (Optional) Edit .env file to customize credentials
# notepad .env
```

### Step 3: Start All Services

```powershell
# Build and start all containers
docker-compose up -d

# Wait for services to be healthy (about 30 seconds)
docker-compose ps
```

### Step 4: Verify Database Setup

```powershell
# Check if database is ready
docker-compose exec postgres pg_isready -U kyc_admin -d kyc_platform

# Verify sample data loaded
docker-compose exec postgres psql -U kyc_admin -d kyc_platform -c "SELECT COUNT(*) FROM users;"
# Expected: 40 users
```

### Step 5: Run First Data Quality Scan

```powershell
# Execute Soda scan
docker-compose run --rm soda

# Expected output:
# - Scan summary with passed/failed checks
# - Results stored in database
```

### Step 6: Access Dashboard

```
Open browser: http://localhost:8501
```

**🎉 You're done! Your KYC Data Quality Platform is running!**

---

## 📚 Detailed Setup

### Directory Structure

```
SODA-V3/
├── .github/
│   └── workflows/
│       └── ci-cd.yml              # GitHub Actions pipeline
├── database/
│   ├── init/
│   │   ├── 01_schema.sql          # Database schema
│   │   └── 02_sample_data.sql     # Sample KYC data
│   └── backups/                   # Database backups
├── soda/
│   ├── config/
│   │   └── data_source.yml        # Soda connection config
│   ├── checks/
│   │   └── checks.yml             # Data quality checks (SodaCL)
│   ├── scripts/
│   │   └── run_scan.py            # Scan execution script
│   ├── results/                   # Scan output files
│   ├── logs/                      # Scan logs
│   └── Dockerfile                 # Soda container image
├── dashboard/
│   ├── app/
│   │   └── app.py                 # Streamlit dashboard
│   ├── assets/                    # Dashboard assets
│   ├── requirements.txt           # Python dependencies
│   └── Dockerfile                 # Dashboard container image
├── docker-compose.yml             # Container orchestration
├── .env.example                   # Environment template
├── .gitignore
├── ARCHITECTURE.md                # Architecture documentation
└── README.md                      # This file
```

### Environment Variables

Create `.env` file from template:

```bash
# Database Configuration
POSTGRES_DB=kyc_platform
POSTGRES_USER=kyc_admin
POSTGRES_PASSWORD=kyc_secure_pass_2024  # ⚠️ CHANGE IN PRODUCTION
POSTGRES_PORT=5432

# Streamlit Configuration
STREAMLIT_PORT=8501
ENVIRONMENT=production

# Soda Configuration
SODA_SCAN_SCHEDULE=0 */6 * * *  # Every 6 hours
LOG_LEVEL=INFO
```

**🔐 Security Note**: Never commit `.env` file to version control!

### Manual Database Setup (Optional)

If you need to manually set up the database:

```powershell
# Connect to PostgreSQL container
docker-compose exec postgres psql -U kyc_admin -d kyc_platform

# Run SQL commands
\i /docker-entrypoint-initdb.d/01_schema.sql
\i /docker-entrypoint-initdb.d/02_sample_data.sql

# Verify
SELECT COUNT(*) FROM users;
SELECT COUNT(*) FROM kyc_docs;
\q
```

---

## 🔍 Running Data Quality Scans

### Manual Scan Execution

```powershell
# Run scan once
docker-compose run --rm soda

# Run scan and view logs
docker-compose run --rm soda 2>&1 | Tee-Object scan_output.log
```

### Scheduled Scans

```powershell
# Start scheduled scanner (runs every 6 hours)
docker-compose up -d soda-scheduler

# View scheduler logs
docker-compose logs -f soda-scheduler

# Stop scheduler
docker-compose stop soda-scheduler
```

### Scan Output

Scans generate:

1. **Console Output**: Summary of passed/failed checks
2. **JSON Results**: Stored in `soda/results/`
3. **Database Records**: Inserted into `soda_scan_results` table
4. **Log Files**: Saved in `soda/logs/`

### Interpreting Scan Results

```
============================================================
SODA DATA QUALITY SCAN SUMMARY
============================================================
Scan ID: 123e4567-e89b-12d3-a456-426614174000
Timestamp: 2024-02-25 10:30:00
Duration: 45.23 seconds
------------------------------------------------------------
Total Checks: 50
✓ Passed: 42 (84.00%)
✗ Failed: 8 (16.00%)
⚠ Warned: 0 (0.00%)
? Not Evaluated: 0
------------------------------------------------------------

⚠️  DATA QUALITY ISSUES DETECTED!
Failed checks:
  ✗ Users must be at least 18 years old
  ✗ Email must be in valid format
  ✗ Phone must be in valid international format
  ...
============================================================
```

**Exit Codes**:
- `0`: All checks passed
- `1`: Some checks failed
- `2`: Scan execution error

---

## 📊 Accessing the Dashboard

### URL

```
http://localhost:8501
```

### Dashboard Pages

1. **📊 Overview**: Real-time metrics, charts, recent scans
2. **🚨 Failed Checks**: Detailed analysis of failing checks
3. **📈 Scan History**: Historical trends and patterns
4. **🔎 Fraud Detection**: High-risk users and suspicious patterns
5. **⚙️ System Info**: Database statistics and configuration

### Dashboard Features

- **Auto-refresh**: Enable 30-second auto-refresh
- **Date Filters**: Last 24h, 7 days, 30 days, All time
- **Interactive Charts**: Plotly-powered visualizations
- **Data Export**: Download tables as CSV
- **Drill-down**: Click charts to explore details

### Dashboard Screenshots

**Overview Page**:
- Total checks metric cards
- Success rate gauge
- Pass/Fail distribution pie chart
- Historical trend line chart

**Failed Checks Page**:
- Critical vs warning breakdown
- Failed checks by table
- Detailed failure messages
- Sample of failed rows

---

## 🐛 Troubleshooting

### Common Issues

#### 1. Database Connection Failed

**Symptom**: `could not connect to server`

**Solution**:
```powershell
# Check if PostgreSQL is running
docker-compose ps postgres

# Restart PostgreSQL
docker-compose restart postgres

# Check logs
docker-compose logs postgres
```

#### 2. Soda Scan Fails

**Symptom**: `ModuleNotFoundError: No module named 'soda'`

**Solution**:
```powershell
# Rebuild Soda container
docker-compose build soda

# Verify Python packages
docker-compose run --rm soda pip list | grep soda
```

#### 3. Dashboard Won't Load

**Symptom**: `ERR_CONNECTION_REFUSED` or blank page

**Solution**:
```powershell
# Check if Streamlit is running
docker-compose ps streamlit

# Restart dashboard
docker-compose restart streamlit

# Check logs
docker-compose logs streamlit

# Verify port is not in use
netstat -ano | findstr :8501
```

#### 4. No Data in Dashboard

**Symptom**: Dashboard shows "No scan results available"

**Solution**:
```powershell
# Run a scan first
docker-compose run --rm soda

# Verify scan results in database
docker-compose exec postgres psql -U kyc_admin -d kyc_platform -c "SELECT COUNT(*) FROM soda_scan_results;"

# Check if scan ingestion succeeded
docker-compose logs soda
```

#### 5. Permission Denied Errors

**Symptom**: `permission denied while trying to connect to the Docker daemon socket`

**Solution** (Windows):
```powershell
# Ensure Docker Desktop is running
# Restart Docker Desktop

# Or run PowerShell as Administrator
```

### Viewing Logs

```powershell
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f postgres
docker-compose logs -f soda
docker-compose logs -f streamlit

# Last 100 lines
docker-compose logs --tail=100 streamlit

# Since specific time
docker-compose logs --since 2024-02-25T10:00:00
```

### Health Checks

```powershell
# Check container health status
docker-compose ps

# Detailed health check
docker inspect --format='{{json .State.Health}}' kyc-postgres

# Manual health check
docker-compose exec postgres pg_isready -U kyc_admin
docker-compose exec streamlit curl -f http://localhost:8501/_stcore/health
```

---

## 🚀 Production Deployment

### Pre-Deployment Checklist

- [ ] Change all default passwords in `.env`
- [ ] Enable SSL/TLS for PostgreSQL connections
- [ ] Configure firewall rules (only expose Streamlit port)
- [ ] Set up regular backups
- [ ] Configure monitoring and alerting
- [ ] Review and adjust resource limits
- [ ] Enable container auto-restart policies
- [ ] Set up log rotation
- [ ] Configure reverse proxy (Nginx/Traefik)
- [ ] Enable authentication for dashboard

### Secure Configuration

**`.env` for Production**:

```bash
# Generate secure password
# Use: openssl rand -hex 32

POSTGRES_PASSWORD=<strong-random-password>
POSTGRES_PORT=5432  # Don't expose externally

STREAMLIT_PORT=8501  # Behind reverse proxy

ENVIRONMENT=production
LOG_LEVEL=WARNING

# Add monitoring
ENABLE_METRICS=true
METRICS_PORT=9090
```

### Resource Limits

Edit `docker-compose.yml`:

```yaml
services:
  postgres:
    deploy:
      resources:
        limits:
          cpus: '4'
          memory: 8G
        reservations:
          cpus: '2'
          memory: 2G
```

### Backup Strategy

**Automated Backups**:

```powershell
# Create backup script (backup.ps1)
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backup_file = "backup_$timestamp.sql"

docker-compose exec -T postgres pg_dump -U kyc_admin kyc_platform > "database/backups/$backup_file"

# Compress
Compress-Archive "database/backups/$backup_file" "database/backups/$backup_file.zip"

# Clean up old backups (keep last 30 days)
Get-ChildItem "database/backups" -Filter "*.zip" | Where-Object {$_.LastWriteTime -lt (Get-Date).AddDays(-30)} | Remove-Item
```

**Schedule with Task Scheduler**:
```powershell
# Run daily at 2 AM
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "D:\BNP Projects\SODA-V3\backup.ps1"
$trigger = New-ScheduledTaskTrigger -Daily -At 2am
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "KYC_DQ_Backup"
```

### Monitoring

**Prometheus Metrics** (Future Enhancement):

```yaml
# Add to docker-compose.yml
  prometheus:
    image: prom/prometheus:latest
    volumes:
      - ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml
    ports:
      - "9090:9090"

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    depends_on:
      - prometheus
```

### High Availability

**PostgreSQL Replication**:

```yaml
# Master-Slave setup
postgres-master:
  image: postgres:15-alpine
  environment:
    POSTGRES_REPLICATION_MODE: master
    POSTGRES_REPLICATION_USER: replicator
    POSTGRES_REPLICATION_PASSWORD: replicator_pass

postgres-slave:
  image: postgres:15-alpine
  environment:
    POSTGRES_REPLICATION_MODE: slave
    POSTGRES_MASTER_HOST: postgres-master
```

---

## 🔧 Maintenance & Operations

### Regular Maintenance Tasks

#### Daily
- Monitor dashboard for failed checks
- Review scan results
- Check disk space usage

#### Weekly
- Review failed check trends
- Archive old scan results (>90 days)
- Check log file sizes

#### Monthly
- Review and update data quality rules
- Performance tuning (query optimization)
- Security patches and updates

### Database Maintenance

**Vacuum & Analyze**:
```sql
-- Connect to database
docker-compose exec postgres psql -U kyc_admin -d kyc_platform

-- Vacuum all tables
VACUUM FULL ANALYZE;

-- Or specific tables
VACUUM FULL ANALYZE users;
VACUUM FULL ANALYZE soda_scan_results;

-- Check table sizes
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
```

**Archive Old Data**:
```sql
-- Archive scan results older than 90 days
SELECT archive_old_scan_results(90);

-- Or manually
DELETE FROM soda_scan_results
WHERE scan_timestamp < CURRENT_DATE - INTERVAL '90 days';
```

### Updating the Platform

**Update Docker Images**:
```powershell
# Pull latest images
docker-compose pull

# Rebuild custom images
docker-compose build --no-cache

# Restart with new images
docker-compose up -d
```

**Update Data Quality Checks**:
```powershell
# Edit checks
notepad soda\checks\checks.yml

# Restart Soda scanner
docker-compose restart soda-scheduler

# Test new checks
docker-compose run --rm soda
```

### Scaling

**Horizontal Scaling (Multiple Dashboard Instances)**:

```yaml
# docker-compose.scale.yml
services:
  streamlit:
    deploy:
      replicas: 3
  
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - streamlit
```

```powershell
# Scale dashboard
docker-compose -f docker-compose.yml -f docker-compose.scale.yml up -d --scale streamlit=3
```

### Disaster Recovery

**Full System Restore**:

```powershell
# 1. Stop all services
docker-compose down

# 2. Restore database from backup
$backup_file = "database/backups/backup_20240225_100000.sql"
docker-compose up -d postgres

Start-Sleep -Seconds 10

Get-Content $backup_file | docker-compose exec -T postgres psql -U kyc_admin -d kyc_platform

# 3. Start all services
docker-compose up -d

# 4. Verify
docker-compose ps
docker-compose exec postgres psql -U kyc_admin -d kyc_platform -c "SELECT COUNT(*) FROM users;"
```

---

## 📞 Support & Contact

### Getting Help

1. **Check Documentation**: Review this README and ARCHITECTURE.md
2. **View Logs**: `docker-compose logs -f`
3. **GitHub Issues**: Report bugs or request features
4. **Internal Support**: Contact Data Engineering team

### Useful Commands Cheat Sheet

```powershell
# Start everything
docker-compose up -d

# Stop everything
docker-compose down

# View all logs
docker-compose logs -f

# Run scan
docker-compose run --rm soda

# Access database
docker-compose exec postgres psql -U kyc_admin -d kyc_platform

# Restart service
docker-compose restart streamlit

# Rebuild service
docker-compose build soda
docker-compose up -d soda

# View resource usage
docker stats

# Clean up
docker-compose down -v  # ⚠️ Removes all data!
docker system prune -a  # Clean unused images
```

---

## 🎯 Next Steps

After successful deployment:

1. ✅ **Customize Checks**: Edit `soda/checks/checks.yml` for your use case
2. ✅ **Configure Alerts**: Set up Slack/email notifications
3. ✅ **Enable Authentication**: Secure the dashboard
4. ✅ **Schedule Backups**: Automate database backups
5. ✅ **Monitor Performance**: Set up Prometheus/Grafana
6. ✅ **Load Real Data**: Replace sample data with actual KYC data
7. ✅ **Integrate CI/CD**: Connect to your CI/CD pipeline
8. ✅ **Train Users**: Provide dashboard training to stakeholders

---

## 📝 License & Credits

**KYC Data Quality Monitoring Platform**  
Version 1.0.0  
© 2024 Your Organization

**Built with**:
- PostgreSQL 15
- Soda Core 3.3.2
- Streamlit 1.31.0
- Docker & Docker Compose
- Python 3.11

---

**🎉 Congratulations! Your enterprise-grade KYC Data Quality Platform is ready for production use!**
