# Install OpenTofu without admin rights (user-local)
$ErrorActionPreference = "Stop"

$installDir = "$env:LOCALAPPDATA\Programs\OpenTofu"
$null = New-Item -ItemType Directory -Force -Path $installDir

# Get latest release version from GitHub
$release = Invoke-RestMethod "https://api.github.com/repos/opentofu/opentofu/releases/latest"
$version = $release.tag_name.TrimStart("v")
Write-Host "Latest OpenTofu version: $version"

# Download zip
$zipUrl = "https://github.com/opentofu/opentofu/releases/download/v$version/tofu_${version}_windows_amd64.zip"
$zipPath = "$env:TEMP\tofu_$version.zip"
Write-Host "Downloading from $zipUrl ..."
Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -UseBasicParsing

# Extract tofu.exe
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [System.IO.Compression.ZipFile]::OpenRead($zipPath)
$entry = $zip.Entries | Where-Object { $_.Name -eq "tofu.exe" }
$destPath = Join-Path $installDir "tofu.exe"
[System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $destPath, $true)
$zip.Dispose()
Remove-Item $zipPath

# Add to user PATH if not already present
$userPath = [Environment]::GetEnvironmentVariable("PATH", "User")
if ($userPath -notlike "*$installDir*") {
    [Environment]::SetEnvironmentVariable("PATH", "$userPath;$installDir", "User")
    Write-Host "Added $installDir to user PATH."
    Write-Host "Restart your terminal for PATH changes to take effect."
}

$installedVersion = & $destPath version | Select-Object -First 1
Write-Host "Installed: $installedVersion"
