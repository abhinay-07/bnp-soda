# ============================================
# KYC Data Quality Platform - Quick Start
# Windows PowerShell Script
# ============================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "KYC Data Quality Platform - Quick Start" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Function to check if command exists
function Test-Command {
    param($Command)
    $null = Get-Command $Command -ErrorAction SilentlyContinue
    return $?
}

# Check prerequisites
Write-Host "Checking prerequisites..." -ForegroundColor Yellow

if (-not (Test-Command "docker")) {
    Write-Host "❌ Docker is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install Docker Desktop from: https://www.docker.com/products/docker-desktop" -ForegroundColor Red
    exit 1
}

if (-not (Test-Command "docker-compose")) {
    Write-Host "❌ Docker Compose is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Docker Compose usually comes with Docker Desktop" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Docker is installed" -ForegroundColor Green
Write-Host "✅ Docker Compose is installed" -ForegroundColor Green
Write-Host ""

# Check if Docker is running
try {
    docker ps | Out-Null
    Write-Host "✅ Docker daemon is running" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker daemon is not running" -ForegroundColor Red
    Write-Host "Please start Docker Desktop" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Setup environment
Write-Host "Setting up environment..." -ForegroundColor Yellow

if (-not (Test-Path ".env")) {
    Write-Host "Creating .env file from template..." -ForegroundColor Cyan
    Copy-Item ".env.example" ".env"
    Write-Host "✅ .env file created" -ForegroundColor Green
} else {
    Write-Host "✅ .env file already exists" -ForegroundColor Green
}

Write-Host ""

# Build and start containers
Write-Host "Building and starting containers..." -ForegroundColor Yellow
Write-Host "This may take a few minutes on first run..." -ForegroundColor Gray
Write-Host ""

docker-compose up -d --build

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to start containers" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "✅ Containers started successfully" -ForegroundColor Green
Write-Host ""

# Wait for PostgreSQL to be ready
Write-Host "Waiting for PostgreSQL to be ready..." -ForegroundColor Yellow

$maxAttempts = 30
$attempt = 0

while ($attempt -lt $maxAttempts) {
    $attempt++
    
    docker-compose exec -T postgres pg_isready -U kyc_admin -d kyc_platform 2>&1 | Out-Null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ PostgreSQL is ready" -ForegroundColor Green
        break
    }
    
    Write-Host "⏳ Waiting... ($attempt/$maxAttempts)" -ForegroundColor Gray
    Start-Sleep -Seconds 2
}

if ($attempt -eq $maxAttempts) {
    Write-Host "❌ PostgreSQL failed to start in time" -ForegroundColor Red
    Write-Host "Check logs with: docker-compose logs postgres" -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# Verify database setup
Write-Host "Verifying database setup..." -ForegroundColor Yellow

$userCount = docker-compose exec -T postgres psql -U kyc_admin -d kyc_platform -t -c "SELECT COUNT(*) FROM users;" 2>&1
if ($userCount -is [string]) {
    $userCount = $userCount.Trim()
    if ($userCount -match '\d+' -and [int]$matches[0] -gt 0) {
        Write-Host "✅ Database initialized with $($matches[0]) users" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Database may not be fully initialized" -ForegroundColor Yellow
        Write-Host "Sample data should load automatically on first start" -ForegroundColor Gray
    }
} else {
    Write-Host "⚠️  Could not verify database setup" -ForegroundColor Yellow
}

Write-Host ""

# Run initial scan
Write-Host "Running initial data quality scan..." -ForegroundColor Yellow
Write-Host ""

docker-compose run --rm soda

Write-Host ""

# Display access information
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "🎉 Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📊 Dashboard URL: http://localhost:8501" -ForegroundColor Cyan
Write-Host ""
Write-Host "Useful Commands:" -ForegroundColor Yellow
Write-Host "  • View dashboard:     start http://localhost:8501" -ForegroundColor Gray
Write-Host "  • Run scan:           docker-compose run --rm soda" -ForegroundColor Gray
Write-Host "  • View logs:          docker-compose logs -f streamlit" -ForegroundColor Gray
Write-Host "  • Access database:    docker-compose exec postgres psql -U kyc_admin -d kyc_platform" -ForegroundColor Gray
Write-Host "  • Stop platform:      docker-compose down" -ForegroundColor Gray
Write-Host "  • Restart services:   docker-compose restart" -ForegroundColor Gray
Write-Host ""
Write-Host "📚 Documentation:" -ForegroundColor Yellow
Write-Host "  • README.md - Complete deployment guide" -ForegroundColor Gray
Write-Host "  • ARCHITECTURE.md - System architecture" -ForegroundColor Gray
Write-Host "  • ENTERPRISE_ENHANCEMENTS.md - Future features" -ForegroundColor Gray
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan

# Offer to open dashboard
Write-Host ""
$openBrowser = Read-Host "Would you like to open the dashboard in your browser? (Y/N)"

if ($openBrowser -eq 'Y' -or $openBrowser -eq 'y') {
    Write-Host "Opening dashboard..." -ForegroundColor Cyan
    Start-Process "http://localhost:8501"
}

Write-Host ""
Write-Host "✅ All done! Happy data quality monitoring! 🚀" -ForegroundColor Green
