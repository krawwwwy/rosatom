#!/bin/bash

# Script to setup ngrok tunnel for external access
# Download and run ngrok to expose the application to internet

echo -e "\033[32mSetting up ngrok tunnel for external access...\033[0m"

# Check if ngrok is installed
if ! command -v ngrok >/dev/null 2>&1; then
    echo -e "\033[33mngrok not found. Installing ngrok...\033[0m"
    
    # Detect architecture
    ARCH=$(uname -m)
    case $ARCH in
        x86_64)
            NGROK_ARCH="amd64"
            ;;
        aarch64|arm64)
            NGROK_ARCH="arm64"
            ;;
        armv7l)
            NGROK_ARCH="arm"
            ;;
        i386|i686)
            NGROK_ARCH="386"
            ;;
        *)
            echo -e "\033[31mUnsupported architecture: $ARCH\033[0m"
            exit 1
            ;;
    esac
    
    echo -e "\033[36mDetected architecture: $ARCH -> $NGROK_ARCH\033[0m"
    
    # Download ngrok
    NGROK_URL="https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-${NGROK_ARCH}.tgz"
    echo -e "\033[33mDownloading ngrok from: $NGROK_URL\033[0m"
    
    curl -L "$NGROK_URL" -o ngrok.tgz
    if [ $? -ne 0 ]; then
        echo -e "\033[31mFailed to download ngrok!\033[0m"
        echo -e "\033[33mPlease install manually:\033[0m"
        echo -e "\033[36m1. Go to https://ngrok.com/\033[0m"
        echo -e "\033[36m2. Sign up for free account\033[0m"
        echo -e "\033[36m3. Download ngrok for Linux\033[0m"
        echo -e "\033[36m4. Extract and place in PATH\033[0m"
        echo -e "\033[36m5. Run: ngrok config add-authtoken YOUR_TOKEN\033[0m"
        exit 1
    fi
    
    # Extract ngrok
    tar -xzf ngrok.tgz
    chmod +x ngrok
    sudo mv ngrok /usr/local/bin/
    rm ngrok.tgz
    
    echo -e "\033[32mngrok installed successfully!\033[0m"
    echo -e "\033[33mNow you need to setup your authtoken:\033[0m"
    echo -e "\033[36m1. Go to https://dashboard.ngrok.com/get-started/your-authtoken\033[0m"
    echo -e "\033[36m2. Copy your authtoken\033[0m"
    echo -e "\033[36m3. Run: ngrok config add-authtoken YOUR_TOKEN\033[0m"
    echo ""
    echo -e "\033[35mAfter setting up authtoken, run this script again\033[0m"
    exit 0
fi

# Check if authtoken is configured
if ! ngrok config check >/dev/null 2>&1; then
    echo -e "\033[33mngrok authtoken not configured!\033[0m"
    echo -e "\033[36m1. Go to https://dashboard.ngrok.com/get-started/your-authtoken\033[0m"
    echo -e "\033[36m2. Copy your authtoken\033[0m"
    echo -e "\033[36m3. Run: ngrok config add-authtoken YOUR_TOKEN\033[0m"
    exit 1
fi

echo -e "\033[33mStarting ngrok tunnel on port 80...\033[0m"
echo -e "\033[33mThis will create a public URL that anyone can access\033[0m"
echo ""
echo -e "\033[31mPress Ctrl+C to stop the tunnel\033[0m"
echo ""

# Start ngrok tunnel
ngrok http 80 