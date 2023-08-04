# A CLI Tool to automate the proses of building web and android app and hosting theme separetly everytime.
# This could be done more easyly with Github actions. But I needed sum extra control.

# Get the current working directory as the Flutter project directory
$flutterProjectDirectory = (Get-Item -Path ".\").FullName

# Build the web version
Write-Host "========================== START ============================="
 
Write-Host "===   Building the web version..."

Set-Location $flutterProjectDirectory
flutter build web

# Deploy web to Firebase Hosting
# Make sure you have Firebase CLI installed and authenticated with the correct account
 
Write-Host "===   Deploying web to Firebase Hosting..."

firebase deploy --only hosting:gngm3

# Build the Android APK
 
Write-Host "===   Building the Android APK..."

flutter build apk

# Get and copy the APK file path
$apkFilePath = Join-Path $flutterProjectDirectory "build\app\outputs\flutter-apk\app-release.apk"
Write-Host "APK file path: $apkFilePath"

$apkFilePath | Set-Clipboard

 
Write-Host "===   APK file path copied to the clipboard."

# Open Google Chrome and go to a website
$websiteURL = "https://gng-merchant3.web.app/version_control"   

Write-Host "Opening Merchant Site in Google Chrome..."
Write-Host "Upload the apk file in the App Link section..."

Start-Process "chrome.exe" $websiteURL

Write-Host "=========================== E N D ============================"