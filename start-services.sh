#!/bin/bash
# start-services.sh - Clean shutdown version

# Function to handle cleanup
cleanup() {
    echo "Shutting down services..."
    kill "$PYTHON_PID"
    exit 0
}

# Trap SIGTERM and SIGINT to run the cleanup function
trap cleanup SIGTERM SIGINT

# Activate virtual environment
source /app/venv/bin/activate

# Start Python RAG service
echo "Starting Python RAG service..."
# Note: Using 127.0.0.1 is perfect for internal container comms
python main.py --host 127.0.0.1 --port 8000 --initialize &
PYTHON_PID=$!

# Wait for Python to be ready
sleep 2
echo "Python RAG service started with PID: $PYTHON_PID"

# Start Node.js via PM2
echo "Starting Node.js Paperless-AI service..."
# We use & to run PM2 in the background so the script can stay alive to catch signals
pm2-runtime ecosystem.config.js &
PM2_PID=$!

# Wait for the processes
wait "$PM2_PID"