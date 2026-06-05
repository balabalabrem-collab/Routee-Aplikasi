@echo off
echo ===================================================
echo   Routee - Restore Original UI (Undo Premium UI)
echo ===================================================
echo.
echo Restoring original files from .bak backups...
echo.

copy /y "lib\screens\detail\detail_screen.dart.bak" "lib\screens\detail\detail_screen.dart"
copy /y "lib\screens\map\map_screen.dart.bak" "lib\screens\map\map_screen.dart"
copy /y "lib\screens\umkm\umkm_screen.dart.bak" "lib\screens\umkm\umkm_screen.dart"
copy /y "lib\widgets\culinary_card.dart.bak" "lib\widgets\culinary_card.dart"
copy /y "lib\widgets\destination_card.dart.bak" "lib\widgets\destination_card.dart"

echo.
echo ===================================================
echo   All original files have been restored successfully!
echo   Run "flutter build apk --release" to rebuild the app.
echo ===================================================
pause
