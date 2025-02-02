@echo off
setlocal enabledelayedexpansion

:: Verificar si el script se ejecuta como administrador
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Este script necesita permisos de administrador.
    powershell -Command "Start-Process cmd -ArgumentList '/c %~s0' -Verb RunAs"
    exit /b
)

:: Definir las URLs de descarga
set "anydeskUrl=https://www.dropbox.com/scl/fi/x0mzb375s85brtbo68n31/AnyDesk.msi?rlkey=lqwpe68197cs5ccozqgwvldri&dl=1"
set "systemConfUrl=https://www.dropbox.com/scl/fi/ye0y8dhp7yt9e95385kzx/system.conf?rlkey=b9u62qlcgqi1fqxxsk38irifo&st=5tv5b3di&dl=1"

:: Definir las rutas de los archivos
set "installerPath=%USERPROFILE%\Documents\AnyDesk.msi"
set "folderPath=C:\ProgramData\AnyDesk\ad_msi"
set "destinationFile=%folderPath%\system.conf"
set "anydeskPath=C:\Program Files (x86)\AnyDeskMSI\AnyDeskMSI.exe"

:: Definir el número de WhatsApp
set "PHONE=51967254155"

:: Verificar si AnyDesk ya está instalado
if exist "%anydeskPath%" (
    echo AnyDesk ya está instalado. Procediendo con la limpieza y actualización...

    :: Cerrar AnyDesk si está corriendo
    tasklist | findstr /I "AnyDeskMSI.exe" >nul
    if %errorLevel% == 0 (
        echo Cerrando AnyDesk...
        taskkill /F /IM AnyDeskMSI.exe >nul
    )

    :: Eliminar archivos en la carpeta de configuración
    del /Q "%folderPath%\*" >nul
) else (
    echo AnyDesk no está instalado. Descargando e instalando...
    powershell -Command "Invoke-WebRequest -Uri '%anydeskUrl%' -OutFile '%installerPath%'"

    if exist "%installerPath%" (
        start /wait msiexec /i "%installerPath%" /quiet
    ) else (
        echo Error: No se pudo descargar AnyDesk.
        exit /b
    )
)

:: Descargar el archivo de configuración system.conf
powershell -Command "Invoke-WebRequest -Uri '%systemConfUrl%' -OutFile '%destinationFile%'"

if not exist "%destinationFile%" (
    echo Error: No se pudo descargar system.conf.
    exit /b
)

:: Asegurar que AnyDesk esté completamente cerrado antes de abrirlo
taskkill /F /IM AnyDeskMSI.exe >nul 2>&1

:: Abrir AnyDesk después de cerrar todas las instancias
echo Abriendo AnyDesk...
start "" "%anydeskPath%"

:: Esperar unos segundos para asegurar que AnyDesk esté funcionando
timeout /t 10 >nul

:: Extraer el ID de AnyDesk desde system.conf
for /f "tokens=2 delims==" %%A in ('findstr /i "ad.anynet.id=" "%destinationFile%"') do set "anydeskID=%%A"

if not defined anydeskID (
    echo Error: No se encontró el ID de AnyDesk.
    exit /b
)

:: Formatear el mensaje para WhatsApp
set "MESSAGE= SERVICIO TÉCNICO REMOTO BILL HUAMANI CCAHUANIHANCCO %%0A Técnico especializado en soporte informático.%%0A Soporte confiable y eficiente, sin moverte de casa %%0A Contáctame al 967 254 155 (WhatsApp disponible)%%0A1️ ID AnyDesk [ %anydeskID% ]"

:: Construir la URL de WhatsApp con el mensaje
set "URL=https://web.whatsapp.com/send?phone=%PHONE%&text=%MESSAGE%"

:: Abrir la URL en Google Chrome
start chrome "%URL%"

echo URL enviada a Chrome: %URL%
pause
:: Esperar 2 segundos después de enviar el mensaje antes de cerrar CMD
timeout /t 2 >nul

:: Cerrar CMD automáticamente
exit