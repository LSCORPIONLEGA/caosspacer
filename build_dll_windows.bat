@echo off
REM Solo el motor como DLL (API en C) y la herramienta CLI. Ejecutar desde "x64 Native Tools Command Prompt for VS 2022".
cd /d "%~dp0"
if not exist out mkdir out
cl /nologo /O2 /MT /EHsc /std:c++17 /LD dsp\ts_api.cpp /Fe:out\CaosSpacerDSP.dll || exit /b 1
cl /nologo /O2 /MT /EHsc /std:c++17 dsp\ts_cli.cpp /Fe:out\ts_cli.exe || exit /b 1
echo LISTO: out\CaosSpacerDSP.dll y out\ts_cli.exe
