FROM python:3.9-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
  git \
  && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy dbt project files
COPY . .

# Create a script to run dbt commands
COPY run_dbt.sh /app/run_dbt.sh
RUN chmod +x /app/run_dbt.sh

# Set the entrypoint to the run script
ENTRYPOINT ["/app/run_dbt.sh"] 