@echo off
echo ==================================
echo Flutter Build and Install Utility
echo ==================================

cd %~dp0
echo Current directory: %CD%

echo.
echo Step 1: Cleaning existing build...
call flutter clean
echo.

echo Step 2: Getting dependencies...
call flutter pub get
echo.

echo Step 3: Building APK...
call flutter build apk --debug
echo.

SET APK_PATH=%CD%\build\app\outputs\flutter-apk\app.apk

echo Step 4: Checking if APK exists...
if exist "%APK_PATH%" (
    echo APK found at: %APK_PATH%
    echo.
    echo Step 5: Installing APK to device...
    call flutter install --use-application-binary="%APK_PATH%"
) else (
    echo APK not found at expected location, checking alternative location...
    
    SET ALT_APK_PATH=%CD%\android\app\build\outputs\apk\debug\app-debug.apk
    
    if exist "%ALT_APK_PATH%" (
        echo APK found at alternative location: %ALT_APK_PATH%
        echo.
        echo Step 5: Installing APK from alternative location...
        call flutter install --use-application-binary="%ALT_APK_PATH%"
    ) else (
        echo ERROR: Could not find APK file at any expected location.
        echo Please check for build errors above.
    )
)

echo.
echo ==================================
pause