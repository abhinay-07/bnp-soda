FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    postgresql-client \
    libpq-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
RUN pip install --no-cache-dir \
    soda-core-postgres==3.3.2 \
    psycopg2-binary==2.9.9 \
    python-dotenv==1.0.0 \
    pyyaml==6.0.1

# Create necessary directories
RUN mkdir -p /app/config /app/checks /app/scripts /app/results /app/logs

# Copy configuration files
COPY config/ /app/config/
COPY checks/ /app/checks/
COPY scripts/ /app/scripts/

# Set permissions
RUN chmod +x /app/scripts/*.py

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV SODA_CONFIG_DIR=/app/config
ENV SODA_CHECKS_DIR=/app/checks

# Health check
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD python -c "import sys; sys.exit(0)"

# Default command
CMD ["python", "/app/scripts/run_scan.py"]
