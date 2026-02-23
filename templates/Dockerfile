# Use a slim base image
FROM node:20-slim

# Set working directory inside the container
WORKDIR /app

#######################################################
# Install necessary packages 
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ffmpeg \
    && apt-get clean && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*
    
# Copy package files and install dependencies
# COPY package*.json ./
# RUN npm install

#######################################################
# Copy application files into the container
COPY . /app

# Create non-root user
RUN adduser --disabled-password --gecos "" appuser && \
    chown -R appuser:appuser /app

# Switch to the non-root user
USER appuser

#######################################################
# Expose application port
EXPOSE 8888

# Command to run your script
CMD ["node", "index.js"]
