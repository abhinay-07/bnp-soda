# 🚀 SODA-V3 Complete Start-to-Finish Guide for New System

**Follow this step-by-step from beginning to end**

---

## 📝 Summary: What You Need to Do

1. ✅ Install Docker
2. ✅ Clone the project
3. ✅ Create configuration file
4. ✅ Start all services
5. ✅ Load sample data
6. ✅ Run data quality scan
7. ✅ Access dashboard
8. ✅ Done! Everything working

**Total Time: 15-20 minutes**

---

# ⭐ STEP-BY-STEP INSTRUCTIONS

## PART 1: BEFORE YOU START

### Check Your System
- 🖥️ **RAM:** At least 8GB (Docker needs 4GB minimum)
- 💾 **Disk Space:** At least 5GB free
- 🌐 **Ports:** 5432 (database) and 8501 (dashboard) available
- 📡 **Internet:** Good connection (downloading ~2GB Docker images)

### Check if You Have These Installed
**Windows:** Open PowerShell and run:
```powershell
docker --version
git --version
```

**Mac/Linux:** Open Terminal and run:
```bash
docker --version
git --version
```

**Expected Output:**
```
Docker version 24.0.0 (or newer)
git version 2.x.x (or newer)
```

**If you don't see these:**
- Download and install Docker Desktop: https://www.docker.com/products/docker-desktop
- Download and install Git: https://git-scm.com/downloads

---

## PART 2: GET THE PROJECT

### Step 1A: Open Terminal/PowerShell

**Windows:**
- Press `Win + R`
- Type `powershell`
- Press Enter

**Mac:**
- Press `Cmd + Space`
- Type `terminal`
- Press Enter

**Linux:**
- Press `Ctrl + Alt + T`

### Step 1B: Navigate to Where You Want the Project

**Windows PowerShell:**
```powershell
# Go to your Documents folder
cd Documents

# Or go to any folder you prefer
cd C:\Users\YourName\MyProjects
```

**Mac/Linux Terminal:**
```bash
# Go to home folder
cd ~

# Or specific folder
cd ~/projects
```

### Step 1C: Clone the Project

**Copy this EXACT command and paste in your terminal:**

```bash
git clone https://github.com/yourusername/SODA-V3.git
```

**If you don't have GitHub access yet:**
Download as ZIP from the source and extract it to a folder called `SODA-V3`

### Step 1D: Enter the Project Folder

```bash
cd SODA-V3
```

**Verify you're in the right place** - You should see:
```
COMPLETE_PROJECT_GUIDE.md
docker-compose.yml
dashboard/
database/
soda/
SETUP_COMMANDS.md
```

**Windows PowerShell:**
```powershell
dir
```

**Mac/Linux:**
```bash
ls -la
```

---

## PART 3: PREPARE DOCKER

### Step 2A: Start Docker Desktop

**Windows:**
- Open Windows Start Menu
- Search for "Docker Desktop"
- Click to launch it
- Wait 2-3 minutes for Docker icon to appear in system tray (bottom right)

**Mac:**
- Open Applications folder
- Double-click "Docker.app"
- Wait for "Docker is running" notification

**Linux:**
Already running, no action needed.

### Step 2B: Verify Docker is Working

**Windows PowerShell:**
```powershell
docker ps
```

**Mac/Linux Terminal:**
```bash
docker ps
```

**Expected Output:**
```
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```
(Empty list is OK - you just need no errors)

---

## PART 4: CREATE CONFIGURATION FILE

### Step 3: Create .env File

The project needs a configuration file called `.env`

**Windows PowerShell:**

Copy this ENTIRE block and paste into PowerShell:

```powershell
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

$envContent | Out-File -FilePath .env -Encoding UTF8 -NoNewline
Write-Host ".env file created successfully!"
```

**Mac/Linux Terminal:**

Copy this ENTIRE block and paste into Terminal:

```bash
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

echo ".env file created successfully!"
```

**Verify it worked:**

**Windows:**
```powershell
Get-Content .env
```

**Mac/Linux:**
```bash
cat .env
```

---

## PART 5: START EVERYTHING

### Step 4A: Download Docker Images

This downloads ~2GB of images. Takes 3-5 minutes depending on internet speed.

**Windows PowerShell:**
```powershell
docker-compose pull
```

**Mac/Linux Terminal:**
```bash
docker-compose pull
```

Wait for it to finish. You'll see "Downloaded" and checkmarks.

### Step 4B: Build Docker Images

```bash
docker-compose build
```

Wait for it to say "Successfully tagged" or similar.

### Step 4C: Start All Services

```bash
docker-compose up -d
```

**Expected output:**
```
✔ Network kyc-network Created
✔ Container kyc-postgres Created
✔ Container kyc-streamlit-dashboard Created
✔ Container kyc-soda-scheduler Created
```

### Step 4D: Wait for Services to Start

Services need 2-3 minutes to fully initialize. 

**Windows PowerShell:**
```powershell
Start-Sleep -Seconds 30
docker-compose ps
```

**Mac/Linux:**
```bash
sleep 30
docker-compose ps
```

**Expected output - Look for "Healthy" status:**
```
CONTAINER ID   IMAGE          COMMAND              STATUS
xxx            postgres:15    postgres -c...       Healthy
xxx            streamlit      streamlit run...     Healthy
xxx            soda-v3-soda   sh -c 'while...      Up
```

If you see "Unhealthy" or "Restarting", wait another 30 seconds and check again.

---

## PART 6: ADD TEST DATA

### Step 5A: Create Sample Data File

**Windows PowerShell:**

```powershell
$sqlData = @"
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
"@

$sqlData | Out-File -FilePath "sample_data.sql" -Encoding UTF8
```

**Mac/Linux Terminal:**

```bash
cat > sample_data.sql << 'EOF'
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
```

### Step 5B: Copy and Execute

**Windows PowerShell:**
```powershell
docker cp "sample_data.sql" kyc-postgres:/tmp/sample_data.sql
docker-compose exec -T postgres psql -U kyc_admin -d kyc_platform -f /tmp/sample_data.sql
```

**Mac/Linux Terminal:**
```bash
docker cp "sample_data.sql" kyc-postgres:/tmp/sample_data.sql
docker-compose exec -T postgres psql -U kyc_admin -d kyc_platform -f /tmp/sample_data.sql
```

**Expected output:**
```
INSERT 0 10
INSERT 0 10
```

This means 10 users and 10 documents were inserted.

---

## PART 7: RUN DATA QUALITY SCAN

### Step 6: Execute SODA Scan

Run this command to check data quality:

```bash
docker-compose run --rm soda python /app/scripts/run_scan.py
```

This will:
- Run 60 quality checks
- Take about 2-3 minutes
- Show results in terminal

**Look for this output:**
```
60/60 checks completed:
50 PASSED
4 FAILED
6 NOT EVALUATED
```

**Your dashboard now has real data!** ✅

---

## PART 8: OPEN THE DASHBOARD

### Step 7A: Open in Browser

**Windows PowerShell:**
```powershell
Start-Process "http://localhost:8501"
```

**Mac Terminal:**
```bash
open http://localhost:8501
```

**Linux Terminal:**
```bash
xdg-open http://localhost:8501
```

**Manual:** 
Just copy-paste this into your browser address bar:
```
http://localhost:8501
```

### Step 7B: What You Should See

🎉 **You should see the Streamlit Dashboard with:**

- **Total Checks:** 60
- **Passed:** 50 (83%)
- **Failed:** 4
- **Success Rate:** 83.33%
- **Multiple Tabs:**
  - 📊 Overview (current view)
  - 🚨 Failed Checks
  - 📈 Scan History
  - 🔎 Fraud Detection
  - ⚙️ System Info

---

## PART 9: VERIFY EVERYTHING IS WORKING

### Step 8A: Check All Services Are Running

**Windows PowerShell:**
```powershell
docker-compose ps
```

**Mac/Linux:**
```bash
docker-compose ps
```

**You should see all 4 services with status "Healthy" or "Up":**
```
kyc-postgres                  Healthy
kyc-streamlit-dashboard       Healthy
kyc-soda-scheduler            Up
```

### Step 8B: Check Database Has Data

**Windows PowerShell:**
```powershell
docker-compose exec -T postgres psql -U kyc_admin -d kyc_platform -c "SELECT COUNT(*) as users FROM users;"
```

**Mac/Linux:**
```bash
docker-compose exec -T postgres psql -U kyc_admin -d kyc_platform -c "SELECT COUNT(*) as users FROM users;"
```

**Expected output:**
```
 users
-------
    10
(1 row)
```

### Step 8C: Check Scan Results

**Windows PowerShell:**
```powershell
docker-compose exec -T postgres psql -U kyc_admin -d kyc_platform -c "SELECT total_checks, checks_passed, checks_failed FROM soda_scan_results ORDER BY scan_timestamp DESC LIMIT 1;"
```

**Mac/Linux:**
```bash
docker-compose exec -T postgres psql -U kyc_admin -d kyc_platform -c "SELECT total_checks, checks_passed, checks_failed FROM soda_scan_results ORDER BY scan_timestamp DESC LIMIT 1;"
```

**Expected output:**
```
 total_checks | checks_passed | checks_failed
--------------+---------------+---------------
           60 |            50 |             4
(1 row)
```

✅ **ALL DONE! Everything is working!**

---

# 🎉 SUCCESS! You're All Set

Your SODA-V3 KYC Data Quality Platform is now **fully operational** on your new system!

## What You Have Running:

✅ **PostgreSQL Database** - Stores all KYC data  
✅ **SODA Scanner** - Runs 60 quality checks  
✅ **Streamlit Dashboard** - Beautiful real-time visualization  
✅ **Auto Scheduler** - Runs scans every 6 hours  

## What You Can Do Now:

1. **View Dashboard:** http://localhost:8501
2. **Check Failed Checks:** Click "🚨 Failed Checks" tab
3. **See Fraud Alerts:** Click "🔎 Fraud Detection" tab
4. **Monitor History:** Click "📈 Scan History" tab
5. **Run Manual Scan:** Run the `docker-compose run --rm soda python /app/scripts/run_scan.py` command

---

# 🛑 WHEN YOU WANT TO STOP

### Stop Services (Keep Data)
```bash
docker-compose down
```

### Stop Everything (Delete Data)
```bash
docker-compose down -v
```

### Restart Everything
```bash
docker-compose up -d
```

---

# 🆘 TROUBLESHOOTING

## Problem: "Cannot connect to Docker daemon"
**Solution:** Start Docker Desktop and wait 2-3 minutes

## Problem: "Port 8501 already in use"
**Windows:**
```powershell
netstat -ano | findstr ":8501"
taskkill /PID <NUMBER> /F
```

**Mac/Linux:**
```bash
lsof -i :8501
kill -9 <PID>
```

## Problem: Dashboard shows "No data"
**Solution:** Run the SODA scan again:
```bash
docker-compose run --rm soda python /app/scripts/run_scan.py
```

## Problem: Can't see dashboard
**Solution:** Check status:
```bash
docker-compose logs streamlit
```

## Problem: Database connection error
**Solution:** Restart database:
```bash
docker-compose restart postgres
Start-Sleep -Seconds 10
docker-compose ps
```

---

# 📞 Need Help?

Look at these files in your project folder:

1. **COMPLETE_PROJECT_GUIDE.md** - Detailed explanation of everything
2. **SETUP_COMMANDS.md** - All advanced commands
3. **README.md** - Quick reference

---

## 📊 Key Information to Remember

**Database Credentials:**
```
Host: localhost
Port: 5432
Database: kyc_platform
Username: kyc_admin
Password: kyc_secure_pass_2024
```

**Dashboard:**
```
URL: http://localhost:8501
Ports: 8501 (frontend), 5432 (database)
```

**Project Structure:**
```
SODA-V3/
├── dashboard/      (Streamlit app)
├── database/       (PostgreSQL init scripts)
├── soda/           (Quality checks)
├── docker-compose.yml  (Services config)
└── .env            (Your config)
```

---

## ✨ You're Ready to Impress Everyone!

Your SODA-V3 platform is now running perfectly. You can:

✅ Demo the dashboard to stakeholders  
✅ Show real data quality metrics  
✅ Explain the 60 automated checks  
✅ Demonstrate fraud detection  
✅ Display compliance capabilities  

**Enjoy! 🚀**

---

*Last Updated: February 26, 2026*  
*Version: 1.0.0*
