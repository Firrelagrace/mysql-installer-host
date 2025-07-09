#!PS
#timeout=1000000

# Define variables
$mysqlZipUrl = "https://github.com/Firrelagrace/mysql-installer-host/releases/download/V1.0/mysql-8.0.42-winx64.zip"
$mysqlZip = "$env:TEMP\mysql.zip"
$mysqlExtractPath = "C:\MySQL"
$mysqlInstallDir = "$mysqlExtractPath\mysql-8.0.42-winx64"
$mysqlExePath = "$mysqlInstallDir\bin\mysql.exe"

# Function to get MySQL version
function Get-MySQLVersion {
    try {
        if (Test-Path $mysqlExePath) {
            $output = & "$mysqlExePath" --version
            if ($output -match "Ver\s([\d\.]+)") {
                return [version]$matches[1]
            }
        }
    } catch {
        Write-Host "Error checking MySQL version: $_"
    }
    return $null
}

# Function to add MySQL to PATH
function Add-ToPath {
    if (-not (Test-Path "$mysqlInstallDir\bin")) {
        Write-Host "❌ MySQL bin directory not found. Skipping PATH update."
        return
    }

    $currentPath = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine)
    if ($currentPath -notlike "*$mysqlInstallDir\bin*") {
        $newPath = "$currentPath;$mysqlInstallDir\bin"
        [Environment]::SetEnvironmentVariable("Path", $newPath, [EnvironmentVariableTarget]::Machine)
        Write-Host "✅ MySQL path added to system PATH."
    } else {
        Write-Host "ℹ️ MySQL already in system PATH."
    }
}

# Step 1: Download MySQL ZIP
try {
    if (-not (Test-Path $mysqlZip)) {
        Write-Host "⬇️ Downloading MySQL 8.0.42 from GitHub..."
        Invoke-WebRequest -Uri $mysqlZipUrl -OutFile $mysqlZip
        Write-Host "✅ Download complete."
    } else {
        Write-Host "ℹ️ MySQL ZIP already exists."
    }
} catch {
    Write-Host "❌ Failed to download MySQL: $_"
    exit 1
}

# Step 2: Extract ZIP
try {
    if (-not (Test-Path $mysqlInstallDir)) {
        Write-Host "📦 Extracting MySQL..."
        Expand-Archive -Path $mysqlZip -DestinationPath $mysqlExtractPath -Force
        Write-Host "✅ Extraction complete."
    } else {
        Write-Host "ℹ️ MySQL already extracted."
    }
} catch {
    Write-Host "❌ Failed to extract MySQL ZIP: $_"
    exit 1
}

# Step 3: Add to system PATH
Add-ToPath

# Step 4: Check version
$installedVersion = Get-MySQLVersion
if ($installedVersion) {
    Write-Host "🎉 MySQL successfully installed. Version: $installedVersion"
} else {
    Write-Host "❌ Could not verify MySQL installation. Please check manually."
}
