@echo off
setlocal
REM Ajusta esta ruta si instalaste Open Watcom en otro directorio.
set WATCOM=C:\WATCOM
set PATH=%WATCOM%\binnt64;%PATH%
cd /d C:\ASM

echo ================================================
echo   COMPILACION DE LOS TRES PROGRAMAS - SOFTWARE FJ
echo ================================================
echo.

where wasm >nul 2>nul
if errorlevel 1 (
  echo ERROR: No se encuentra WASM.
  echo Verifica que Open Watcom este instalado en C:\WATCOM.
  pause
  exit /b 1
)
where wlink >nul 2>nul
if errorlevel 1 (
  echo ERROR: No se encuentra WLINK.
  pause
  exit /b 1
)

echo [1/3] Ensamblando calculadora...
wasm -zcm=masm 01_CALC_HEX.ASM
if errorlevel 1 goto error
wlink system dos name 01_CALC_HEX.EXE file 01_CALC_HEX.OBJ option start=INICIO
if errorlevel 1 goto error

echo.
echo [2/3] Ensamblando mascaras logicas...
wasm -zcm=masm 02_MASCARAS.ASM
if errorlevel 1 goto error
wlink system dos name 02_MASCARAS.EXE file 02_MASCARAS.OBJ option start=INICIO
if errorlevel 1 goto error

echo.
echo [3/3] Ensamblando contador hexadecimal...
wasm -zcm=masm 03_CONTADOR.ASM
if errorlevel 1 goto error
wlink system dos name 03_CONTADOR.EXE file 03_CONTADOR.OBJ option start=INICIO
if errorlevel 1 goto error

echo.
echo ================================================
echo COMPILACION Y ENLACE FINALIZADOS
 echo Se generaron los tres archivos EXE en C:\ASM
echo ================================================
dir *.EXE
pause
exit /b 0

:error
echo.
echo ERROR: Revisa el mensaje anterior. No se continuo con los siguientes programas.
pause
exit /b 1
