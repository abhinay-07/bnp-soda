# Multi-stage Dockerfile for complete SODA-V3 KYC Platform
FROM python:3.11-slim as base

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    postgresql-client \
    curl \
    git \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /app

# Copy all project files
COPY . /app/

# Install Python dependencies
RUN pip install --upgrade pip && \
    pip install -r dashboard/requirements.txt && \
    pip install soda-core-postgres==3.3.2 && \
    pip install supervisor

# Create supervisor config for running multiple services
RUN mkdir -p /var/log/supervisor

# Expose ports
EXPOSE 8501

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8501/_stcore/health || exit 1

# Default command - run dashboard
CMD ["streamlit", "run", "dashboard/app/app.py", "--server.address", "0.0.0.0"]
