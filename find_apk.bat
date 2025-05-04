@echo off
echo ==================================
echo Flutter APK Finder Utility
echo ==================================

echo Checking build directory structure...
cd %~dp0

echo Looking for APK files...
echo.

echo 1. Checking in standard Flutter output location:
echo -------------------------------------------
dir /s /b "build\app\outputs\flutter-apk\*.apk" 2>nul
if %ERRORLEVEL% NEQ 0 echo No APK found in Flutter output directory.
echo.

echo 2. Checking in Android build output location:
echo -------------------------------------------
dir /s /b "android\build\outputs\apk\*.apk" 2>nul
dir /s /b "android\app\build\outputs\apk\*.apk" 2>nul
if %ERRORLEVEL% NEQ 0 echo No APK found in Android output directories.
echo.

echo 3. Checking for any APK in the project:
echo -------------------------------------------
dir /s /b "*.apk" 2>nul
if %ERRORLEVEL% NEQ 0 echo No APK found anywhere in the project.
echo.

echo 4. Current Flutter configuration:
echo -------------------------------------------
flutter doctor -v
echo.

echo 5. Checking build folder contents:
echo -------------------------------------------
dir /b "build" 2>nul
if %ERRORLEVEL% NEQ 0 echo Build directory does not exist.
echo.

echo ==================================
echo Trying a full clean and rebuild...
echo ==================================
echo Running: flutter clean...
call flutter clean
echo.

echo Running: flutter pub get...
call flutter pub get
echo.

echo Rebuilding with verbose flag...
echo Running: flutter build apk --debug --verbose
call flutter build apk --debug --verbose

echo.
echo Search for APK again after rebuild:
echo -------------------------------------------
dir /s /b "*.apk" 2>nul

echo.
echo ==================================
pause