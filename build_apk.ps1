$env:JAVA_HOME = "C:\Program Files\Microsoft\jdk-17.0.20.101-hotspot"
$env:Path = "C:\Program Files\Microsoft\jdk-17.0.20.101-hotspot\bin;C:\Users\HP\flutter\bin;C:\Users\HP\AppData\Local\Android\Sdk\platform-tools;" + $env:Path
Remove-Item -Force "C:\Users\HP\flutter\bin\cache\lockfile" -ErrorAction SilentlyContinue

Write-Host "Building release APK for target platform android-arm64..."
& "C:\Users\HP\flutter\bin\flutter.bat" build apk --release --target-platform android-arm64 --android-skip-build-dependency-validation
$buildExit = $LASTEXITCODE

Write-Host "Flutter build exited with code $buildExit"
exit $buildExit

