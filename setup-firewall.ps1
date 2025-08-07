# Script for configuring Windows Firewall for rosatom project
# Run as Administrator!

Write-Host "Configuring Windows Firewall for rosatom project..." -ForegroundColor Green

# Check administrator rights
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    exit 1
}

# Allow port 80 (nginx)
Write-Host "Allowing port 80 (HTTP)..." -ForegroundColor Yellow
netsh advfirewall firewall add rule name="Rosatom HTTP" dir=in action=allow protocol=TCP localport=80

# Allow port 8080 (telephone-book)
Write-Host "Allowing port 8080 (Telephone Book)..." -ForegroundColor Yellow  
netsh advfirewall firewall add rule name="Rosatom Telephone Book" dir=in action=allow protocol=TCP localport=8080

# Allow port 44044 (SSO gRPC)
Write-Host "Allowing port 44044 (SSO)..." -ForegroundColor Yellow
netsh advfirewall firewall add rule name="Rosatom SSO" dir=in action=allow protocol=TCP localport=44044

# Allow port 5432 (PostgreSQL)
Write-Host "Allowing port 5432 (PostgreSQL)..." -ForegroundColor Yellow
netsh advfirewall firewall add rule name="Rosatom PostgreSQL" dir=in action=allow protocol=TCP localport=5432

Write-Host ""
Write-Host "Firewall configuration completed!" -ForegroundColor Green
Write-Host "Now you can run deploy.ps1" -ForegroundColor Cyan 