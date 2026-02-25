# Project Structure

```
D:\BNP Projects\SODA-V3\
│
├── .github/
│   └── workflows/
│       └── ci-cd.yml                 # GitHub Actions CI/CD pipeline
│
├── database/
│   ├── init/
│   │   ├── 01_schema.sql            # PostgreSQL schema definition
│   │   └── 02_sample_data.sql       # Sample KYC data with issues
│   └── backups/                     # Database backup location
│
├── soda/
│   ├── config/
│   │   └── data_source.yml          # Soda data source configuration
│   ├── checks/
│   │   └── checks.yml               # SodaCL data quality checks
│   ├── scripts/
│   │   └── run_scan.py              # Scan execution & result ingestion
│   ├── results/                     # Scan output JSON files
│   ├── logs/                        # Scan execution logs
│   └── Dockerfile                   # Soda container image
│
├── dashboard/
│   ├── app/
│   │   └── app.py                   # Enterprise Streamlit dashboard
│   ├── assets/                      # Dashboard assets (images, CSS)
│   ├── requirements.txt             # Python dependencies
│   └── Dockerfile                   # Dashboard container image
│
├── docker-compose.yml               # Container orchestration
├── .env.example                     # Environment variables template
├── .gitignore                       # Git ignore patterns
├── ARCHITECTURE.md                  # System architecture documentation
├── README.md                        # Deployment & execution guide
├── ENTERPRISE_ENHANCEMENTS.md       # Future enhancements roadmap
└── PROJECT_STRUCTURE.md             # This file
```

## File Descriptions

### Root Level
- **docker-compose.yml**: Orchestrates PostgreSQL, Soda, and Streamlit containers
- **.env.example**: Template for environment variables (copy to .env)
- **.gitignore**: Prevents sensitive files from being committed

### Database (`/database`)
- **01_schema.sql**: Creates tables, views, indexes, functions, and permissions
- **02_sample_data.sql**: Inserts 40 users and 30+ documents with intentional quality issues
- **backups/**: Location for automated database backups

### Soda (`/soda`)
- **data_source.yml**: PostgreSQL connection configuration
- **checks.yml**: 50+ comprehensive data quality checks covering:
  - Schema validation
  - Null/missing values
  - Duplicates
  - Format validation (regex)
  - Business rules (age >=18)
  - Referential integrity
  - Freshness checks
  - Anomaly detection
- **run_scan.py**: Python script that:
  - Executes Soda scans
  - Parses JSON results
  - Ingests into PostgreSQL
  - Returns exit code for CI/CD

### Dashboard (`/dashboard`)
- **app.py**: Multi-page Streamlit application with:
  - Overview page (metrics, charts)
  - Failed checks analysis
  - Historical trends
  - Fraud detection insights
  - System information
- **requirements.txt**: Python packages (Streamlit, Plotly, psycopg2, pandas)

### CI/CD (`/.github/workflows`)
- **ci-cd.yml**: GitHub Actions pipeline:
  - Database setup
  - Docker image builds
  - Automated scanning
  - Quality threshold enforcement (95%)
  - Security scanning
  - Staging/production deployment

### Documentation
- **ARCHITECTURE.md**: High-level system design, data flow, security best practices
- **README.md**: Complete deployment guide with troubleshooting
- **ENTERPRISE_ENHANCEMENTS.md**: Future features (RBAC, alerting, ML, cloud integration)

## Technology Stack

### Core Technologies
- **PostgreSQL 15**: Relational database
- **Soda Core 3.3.2**: Data quality framework
- **Streamlit 1.31.0**: Web dashboard framework
- **Python 3.11**: Programming language
- **Docker & Docker Compose**: Containerization

### Python Libraries
- **pandas**: Data manipulation
- **plotly**: Interactive charts
- **psycopg2**: PostgreSQL driver
- **sqlalchemy**: Database ORM

### Infrastructure
- **Docker**: Container runtime
- **GitHub Actions**: CI/CD automation
- **Prometheus** (future): Metrics collection
- **Grafana** (future): Visualization

## Quick Commands

```powershell
# Start platform
docker-compose up -d

# Run scan
docker-compose run --rm soda

# View dashboard
# http://localhost:8501

# Check logs
docker-compose logs -f streamlit

# Stop platform
docker-compose down

# Database access
docker-compose exec postgres psql -U kyc_admin -d kyc_platform
```

## Data Quality Checks Coverage

### Users Table (25+ checks)
- Schema validation
- Missing value detection
- Duplicate user IDs
- Email format validation (regex)
- Phone format validation (regex)
- Age >= 18 business rule
- Account status validation
- Risk level validation
- Freshness checks

### KYC Documents Table (20+ checks)
- Schema validation
- Referential integrity
- Document expiry validation
- Document type validation
- Verification status checks
- Duplicate document numbers

### Cross-Table Checks
- Users without documents
- Orphaned documents
- Document coverage ratios

### Advanced Checks
- Anomaly detection
- Fraud pattern identification
- Compliance validations

## Intentional Data Issues

The sample data includes these issues to test the system:

1. **Underage users** (3): USR011, USR012, USR013
2. **Invalid emails** (3): USR014, USR015, USR016
3. **Invalid phones** (3): USR017, USR018, USR019
4. **Duplicate user ID** (1): USR020 appears twice
5. **NULL critical fields** (3): USR021, USR022, USR023
6. **High-risk users** (2): USR031, USR032
7. **Expired documents** (3): For USR011, USR012, USR013
8. **Missing documents** (3): USR014, USR015, USR016

## Deployment Environments

### Development
- Local Docker Compose
- Sample data
- Debug logging enabled
- No authentication

### Staging
- Kubernetes cluster
- Replicated services
- SSL enabled
- OAuth authentication

### Production
- High availability setup
- Auto-scaling
- Encrypted storage
- Full monitoring
- Backup automation

## Maintenance

### Daily
- Review scan results
- Monitor failed checks
- Check disk space

### Weekly
- Archive old results (>90 days)
- Review trends

### Monthly
- Update quality rules
- Performance tuning
- Security patches

## Support

For issues or questions:
1. Check README.md troubleshooting section
2. Review logs: `docker-compose logs -f`
3. Contact Data Engineering team
