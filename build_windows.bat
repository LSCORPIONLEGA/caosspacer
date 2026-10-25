@echo off
REM Compila el plugin VST3 (.vst3 = .dll) y, si tienes Inno Setup 6 (gratis), crea el instalador CaosSpacer-Setup.exe
REM Requisitos: Visual Studio 2022 Community (con "Desarrollo para escritorio con C++") y CMake.
where cmake >nul 2>nul || (echo Instala CMake desde https://cmake.org/download/ y vuelve a ejecutar. & pause & exit /b 1)
cd /d "%~dp0"
cmake -S plugin -B build -G "Visual Studio 17 2022" -A x64 || (pause & exit /b 1)
cmake --build build --config Release || (pause & exit /b 1)
echo.
echo LISTO. Plugin: build\CaosSpacer_artefacts\Release\VST3\CaosSpacer.vst3
if exist "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" (
  "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" installer\CaosSpacer.iss
  echo INSTALADOR: installer_out\CaosSpacer-Setup.exe
) else (
  echo Para crear el instalador instala Inno Setup 6 ^(gratis, jrsoftware.org^) y vuelve a ejecutar este archivo.
  echo O copia la carpeta CaosSpacer.vst3 a C:\Program Files\Common Files\VST3\
)
pause
