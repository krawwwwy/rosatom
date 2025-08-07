# Script to setup ngrok tunnel for external access
# Download and run ngrok to expose the application to internet

Write-Host "Setting up ngrok tunnel for external access..." -ForegroundColor Green

# Check if ngrok is installed
$ngrokPath = Get-Command ngrok -ErrorAction SilentlyContinue

if (-not $ngrokPath) {
    Write-Host "ngrok not found. Please install ngrok:" -ForegroundColor Yellow
    Write-Host "1. Go to https://ngrok.com/" -ForegroundColor Cyan
    Write-Host "2. Sign up for free account" -ForegroundColor Cyan
    Write-Host "3. Download ngrok.exe" -ForegroundColor Cyan
    Write-Host "4. Place ngrok.exe in PATH or current directory" -ForegroundColor Cyan
    Write-Host "5. Run: ngrok config add-authtoken YOUR_TOKEN" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "After installation, run this script again" -ForegroundColor Magenta
    exit 1
}

Write-Host "Starting ngrok tunnel on port 80..." -ForegroundColor Yellow
Write-Host "This will create a public URL that anyone can access" -ForegroundColor Yellow
Write-Host ""
Write-Host "Press Ctrl+C to stop the tunnel" -ForegroundColor Red
Write-Host ""

# Start ngrok tunnel
ngrok http 80 