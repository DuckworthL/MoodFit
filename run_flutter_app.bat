@echo off
echo ==================================
echo Flutter App Runner - Path Fix Utility
echo ==================================

echo Checking environment...
cd %~dp0
echo Current directory: %CD%

SET APK_PATH=%CD%\android\build\app\outputs\flutter-apk\app-debug.apk

echo.
echo Step 1: Building APK with debug configuration...
call flutter build apk --debug
echo.

echo Step 2: Checking if APK was built...
if exist "%APK_PATH%" (
    echo Found APK at: %APK_PATH%
    echo.
    echo Step 3: Installing APK to connected device...
    call flutter install
    echo.
    echo If the app doesn't start automatically, try running:
    echo flutter run --use-application-binary="%APK_PATH%"
) else (
    echo ERROR: APK not found at expected location.
    echo Expected path: %APK_PATH%
    echo.
    echo Possible issues:
    echo 1. Build failed - check for compiler errors
    echo 2. APK was built but in a different location
    echo.
    echo Try running: flutter build apk --debug --verbose
)

echo.
echo ==================================
pause