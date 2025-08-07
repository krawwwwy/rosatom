# Auto-restart ngrok every 2 hours to bypass free tier limitations
# This keeps the tunnel alive but URL will change every restart

Write-Host "Starting auto-restarting ngrok tunnel..." -ForegroundColor Green
Write-Host "URL will change every 2 hours (free tier limitation)" -ForegroundColor Yellow
Write-Host "Press Ctrl+C to stop" -ForegroundColor Red
Write-Host ""

$restartCount = 0

while ($true) {
    $restartCount++
    Write-Host "=== Restart #$restartCount ===" -ForegroundColor Cyan
    Write-Host "Starting ngrok tunnel for 1 hour 50 minutes..." -ForegroundColor Yellow
    
    # Start ngrok in background
    $ngrokProcess = Start-Process -FilePath "ngrok" -ArgumentList "http", "80" -PassThru
    
    # Wait for ngrok to start and get URL
    Start-Sleep -Seconds 5
    
    try {
        $tunnels = Invoke-RestMethod -Uri "http://localhost:4040/api/tunnels" -ErrorAction Stop
        $publicUrl = $tunnels.tunnels[0].public_url
        Write-Host "✅ Tunnel active: $publicUrl" -ForegroundColor Green
        Write-Host "Share this URL with others" -ForegroundColor Cyan
    } catch {
        Write-Host "⚠️ Could not get tunnel URL, check ngrok manually" -ForegroundColor Yellow
    }
    
    Write-Host ""
    
    # Wait 1 hour 50 minutes (10 minutes before 2-hour limit)
    $waitMinutes = 110
    for ($i = $waitMinutes; $i -gt 0; $i--) {
        Write-Progress -Activity "Tunnel running" -Status "$i minutes remaining" -PercentComplete ((($waitMinutes - $i) / $waitMinutes) * 100)
        Start-Sleep -Seconds 60
    }
    
    # Kill ngrok process
    Write-Host "Restarting tunnel..." -ForegroundColor Yellow
    Stop-Process -Id $ngrokProcess.Id -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 3
} 