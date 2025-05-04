@echo off
echo ==================================
echo Flutter App Installer Utility
echo ==================================

echo Current directory: %CD%

SET APK_PATH=%CD%\build\app\outputs\flutter-apk\app.apk

echo.
echo Using APK at: %APK_PATH%
echo.

echo Installing APK to device...
flutter install --use-application-binary="%APK_PATH%"

echo.
echo If the above fails, try with the alternative APK path:
echo flutter install --use-application-binary="%CD%\android\app\build\outputs\apk\debug\app-debug.apk"
echo.

echo ==================================
pause