# 🚀 Pull and Run SODA-V3 from Docker Hub

## ✅ What You Just Created

Your **entire SODA-V3 project** is now available as a Docker image on Docker Hub!

**Docker Hub URL:** https://hub.docker.com/r/abhinaymanikanti/bnp-soda

---

## 📦 Option 1: Pull and Run Instantly (Simplest)

Anyone on ANY system can now run your project with just 3 commands!

### Step 1: Pull the Image
```bash
docker pull abhinaymanikanti/bnp-soda:latest
```

### Step 2: Run PostgreSQL Database
```bash
docker run -d \
  --name kyc-postgres \
  -e POSTGRES_DB=kyc_platform \
  -e POSTGRES_USER=kyc_admin \
  -e POSTGRES_PASSWORD=secure_password_2024 \
  -p 5432:5432 \
  postgres:15-alpine
```

### Step 3: Run SODA Dashboard
```bash
docker run -d \
  --name kyc-dashboard \
  --link kyc-postgres:postgres \
  -e DB_HOST=postgres \
  -e DB_PORT=5432 \
  -e DB_NAME=kyc_platform \
  -e DB_USER=kyc_admin \
  -e DB_PASSWORD=secure_password_2024 \
  -p 8501:8501 \
  abhinaymanikanti/bnp-soda:latest
```

### Step 4: Open Dashboard
```bash
# Windows
start http://localhost:8501

# Mac/Linux
open http://localhost:8501
```

**Done! Dashboard is running! 🎉**

---

## 📋 Option 2: Use Docker Compose (Recommended)

### Step 1: Clone Your GitHub Repo
```bash
git clone https://github.com/abhinay-07/bnp-soda.git
cd bnp-soda
```

### Step 2: Use Production Compose File
```bash
docker-compose -f docker-compose.production.yml up -d
```

**That's it!** Everything automatically:
- ✅ Pulls the image from Docker Hub
- ✅ Starts PostgreSQL database
- ✅ Initializes schema and sample data
- ✅ Starts Streamlit dashboard
- ✅ Connects everything together

### Step 3: Access Dashboard
```
http://localhost:8501
```

---

## 🌍 Run on ANY System

### Windows
```powershell
# Install Docker Desktop first
# Download from: https://www.docker.com/products/docker-desktop

# Then run
docker pull abhinaymanikanti/bnp-soda:latest
docker-compose -f docker-compose.production.yml up -d
```

### Mac
```bash
# Install Docker Desktop first
# Download from: https://www.docker.com/products/docker-desktop

# Then run
docker pull abhinaymanikanti/bnp-soda:latest
docker-compose -f docker-compose.production.yml up -d
```

### Linux (Ubuntu/Debian)
```bash
# Install Docker
sudo apt-get update
sudo apt-get install docker.io docker-compose -y

# Pull and run
docker pull abhinaymanikanti/bnp-soda:latest
docker-compose -f docker-compose.production.yml up -d
```

### AWS EC2 / Azure VM / Google Cloud
```bash
# Same as Linux
sudo apt-get install docker.io docker-compose -y
docker pull abhinaymanikanti/bnp-soda:latest
docker-compose -f docker-compose.production.yml up -d

# Open port 8501 in security group/firewall
# Access via: http://<your-vm-ip>:8501
```

---

## 🎯 What's Included in the Image?

```
✅ Python 3.11
✅ Streamlit 1.31 (Dashboard)
✅ Soda Core 3.3.2 (Data Quality Checks)
✅ PostgreSQL client
✅ All Python dependencies
✅ All application code
✅ All SODA check configurations
✅ Database initialization scripts
```

**Image Size:** 1.51 GB
**Compressed:** 328 MB (faster download)

---

## 📊 Image Details

```
Repository: abhinaymanikanti/bnp-soda
Tags: latest, 1.0
Digest: sha256:094acd027aa00b2a4cc641b4954f28a5112e74dd1569a448b6270c6e7366d4fa
Architecture: linux/amd64
OS: Linux
```

---

## 🔄 Update Your Image

When you make changes and rebuild:

```bash
# On your development machine
docker build -t abhinaymanikanti/bnp-soda:latest .
docker push abhinaymanikanti/bnp-soda:latest

# On any other machine - pull latest
docker pull abhinaymanikanti/bnp-soda:latest
docker-compose -f docker-compose.production.yml up -d --force-recreate
```

---

## 🆘 Troubleshooting

### "Cannot connect to Docker daemon"
```bash
# Windows/Mac: Start Docker Desktop
# Linux: Start Docker service
sudo systemctl start docker
```

### "Port 8501 already in use"
```bash
# Stop existing containers
docker stop kyc-dashboard
docker rm kyc-dashboard

# Or use different port
docker run -p 8502:8501 abhinaymanikanti/bnp-soda:latest
```

### "Connection refused to database"
```bash
# Make sure PostgreSQL is running
docker ps | grep postgres

# Restart if needed
docker restart kyc-postgres
```

### Pull latest version
```bash
docker pull abhinaymanikanti/bnp-soda:latest --no-cache
```

---

## 🎁 Share with Your Team

Just share these 3 lines:

```bash
docker pull abhinaymanikanti/bnp-soda:latest
docker-compose -f docker-compose.production.yml up -d
# Open: http://localhost:8501
```

Or share the Docker Hub link:
```
https://hub.docker.com/r/abhinaymanikanti/bnp-soda
```

---

## 📈 Version Management

```bash
# Pull specific version
docker pull abhinaymanikanti/bnp-soda:1.0

# Pull latest
docker pull abhinaymanikanti/bnp-soda:latest

# List all versions
docker images abhinaymanikanti/bnp-soda
```

---

## 🔐 Security Notes

**⚠️ Important:** The production compose file has default passwords!

**For production use:**

1. Create `.env` file:
```env
DB_PASSWORD=your_super_secure_password_here
DB_USER=your_db_user
```

2. Update docker-compose.production.yml:
```yaml
environment:
  DB_PASSWORD: ${DB_PASSWORD}
  DB_USER: ${DB_USER}
```

---

## ✅ Complete Workflow Summary

### You (Developer):
1. ✅ Built Docker image
2. ✅ Pushed to Docker Hub
3. ✅ Pushed code to GitHub

### Others (Anyone):
1. `docker pull abhinaymanikanti/bnp-soda:latest`
2. `docker-compose up -d`
3. Open `http://localhost:8501`
4. **Done!**

---

## 🌟 Key Benefits

| Benefit | Description |
|---------|-------------|
| **No Installation** | No need to install Python, Soda, dependencies |
| **Cross-Platform** | Works on Windows, Mac, Linux, Cloud |
| **Consistent** | Same environment everywhere |
| **Fast Setup** | 2-3 minutes from zero to running |
| **Easy Updates** | Just pull new image version |
| **Portable** | Run anywhere Docker runs |

---

## 📞 Support Links

- **Docker Hub:** https://hub.docker.com/r/abhinaymanikanti/bnp-soda
- **GitHub Repo:** https://github.com/abhinay-07/bnp-soda
- **Documentation:** See COMPLETE_PROJECT_GUIDE.md in repo

---

**Your project is now 100% portable and production-ready! 🚀**

Anyone with Docker can run it in minutes!
