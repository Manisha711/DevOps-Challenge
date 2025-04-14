FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create non-root user
RUN useradd -r -u 1000 -g root appuser && \
    chown -R appuser:root /app

# Switch to non-root user
USER appuser

# Expose port
EXPOSE 8888

# Run application
CMD ["python", "hello.py"]