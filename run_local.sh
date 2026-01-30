#!/bin/bash

# Exit on error
set -e

echo "Running npm build..."
npm run build

echo "Starting Laravel server..."
# Start server in background
php artisan serve &
SERVER_PID=$!

# Function to clean up background process on exit
cleanup() {
    echo "Stopping Laravel server..."
    kill $SERVER_PID
}

# Trap SIGINT (Ctrl+C) and call cleanup
trap cleanup SIGINT

echo "Waiting for server to start..."
sleep 2

echo "Opening browser..."
open http://127.0.0.1:8000

# Wait for the server process to finish
wait $SERVER_PID
