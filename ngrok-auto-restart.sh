#!/bin/bash

# Auto-restart ngrok every 2 hours to bypass free tier limitations
# This keeps the tunnel alive but URL will change every restart

echo -e "\033[32mStarting auto-restarting ngrok tunnel...\033[0m"
echo -e "\033[33mURL will change every 2 hours (free tier limitation)\033[0m"
echo -e "\033[31mPress Ctrl+C to stop\033[0m"
echo ""

# Check if ngrok is installed
if ! command -v ngrok >/dev/null 2>&1; then
    echo -e "\033[31mngrok not found! Please install ngrok first.\033[0m"
    echo -e "\033[36mRun: ./setup-ngrok.sh\033[0m"
    exit 1
fi

# Trap Ctrl+C to cleanup
cleanup() {
    echo ""
    echo -e "\033[33mStopping ngrok tunnel...\033[0m"
    if [ ! -z "$ngrok_pid" ]; then
        kill $ngrok_pid 2>/dev/null
    fi
    exit 0
}
trap cleanup INT TERM

restart_count=0

while true; do
    restart_count=$((restart_count + 1))
    echo -e "\033[36m=== Restart #$restart_count ===\033[0m"
    echo -e "\033[33mStarting ngrok tunnel for 1 hour 50 minutes...\033[0m"
    
    # Start ngrok in background
    ngrok http 80 >/dev/null 2>&1 &
    ngrok_pid=$!
    
    # Wait for ngrok to start
    sleep 5
    
    # Get tunnel URL
    if command -v curl >/dev/null 2>&1; then
        tunnel_info=$(curl -s http://localhost:4040/api/tunnels 2>/dev/null)
        if [ $? -eq 0 ] && [ ! -z "$tunnel_info" ]; then
            public_url=$(echo "$tunnel_info" | grep -o '"public_url":"https://[^"]*' | cut -d'"' -f4 | head -1)
            if [ ! -z "$public_url" ]; then
                echo -e "\033[32m✅ Tunnel active: $public_url\033[0m"
                echo -e "\033[36mShare this URL with others\033[0m"
            else
                echo -e "\033[33m⚠️ Could not get tunnel URL, check ngrok manually at http://localhost:4040\033[0m"
            fi
        else
            echo -e "\033[33m⚠️ Could not connect to ngrok API, tunnel may still be working\033[0m"
        fi
    else
        echo -e "\033[33m⚠️ curl not found, cannot get tunnel URL automatically\033[0m"
        echo -e "\033[36mCheck tunnel URL at: http://localhost:4040\033[0m"
    fi
    
    echo ""
    
    # Wait 1 hour 50 minutes (10 minutes before 2-hour limit)
    wait_minutes=110
    for ((i=wait_minutes; i>0; i--)); do
        printf "\r\033[33mTunnel running... %d minutes remaining\033[0m" $i
        sleep 60
    done
    
    echo ""
    echo -e "\033[33mRestarting tunnel...\033[0m"
    
    # Kill ngrok process
    kill $ngrok_pid 2>/dev/null
    wait $ngrok_pid 2>/dev/null
    sleep 3
done 