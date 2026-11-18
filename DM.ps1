<#
.SYNOPSIS
    DriverMaster CLI - Lightweight driver management and rescue utility (RU/EN/ES).
.DESCRIPTION
    PowerShell script featuring a trilingual language selector (RU/EN/ES), hardware scanner,
    local backup, Pandora Mode rescue USB creation with multilingual recovery script and guide, and selective driver installation.
.DISCLAIMER
    THIS SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED.
    USE AT YOUR OWN RISK. THE AUTHOR SHALL NOT BE LIABLE FOR ANY DAMAGES ARISING FROM
    THE USE OF THIS SOFTWARE.
#>

# Forzar codificación y página de códigos UTF-8 para caracteres cirílicos y especiales
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null

# ========================================================
# 0) COMPROBACIÓN DE PRIVILEGIOS DE ADMINISTRADOR
# ========================================================
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "[!] ERROR: Debes ejecutar este script como Administrador." -ForegroundColor Red
    Write-Host "[*] Haz clic derecho en el archivo .ps1 y selecciona 'Ejecutar con PowerShell'." -ForegroundColor Yellow
    Pause
    exit
}

# ========================================================
# 1) SELECTOR DE IDIOMA (РУССКИЙ / ENGLISH / ESPAÑOL)
# ========================================================
Clear-Host
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "       DRIVERMASTER - LANGUAGE          " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " 1) Русский (RU)" -ForegroundColor Yellow
Write-Host " 2) English (EN)" -ForegroundColor Yellow
Write-Host " 3) Español (ES)" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan

$langChoice = Read-Host "Select language / Выберите язык / Elige idioma (1-3)"

$t = @{}
switch ($langChoice) {
    '1' { # Русский
        $t.Title = "DRIVERMASTER CLI v1.0 - МЕНЕДЖЕР ДРАЙВЕРОВ"
        $t.Opt1 = "1) Инструкция первой помощи (Черный экран)"
        $t.Opt2 = "2) Сканирование оборудования и отчет (Рабочий стол)"
        $t.Opt3 = "3) Локальная резервная копия (Текущие драйверы)"
        $t.Opt4 = "4) Создать аварийную USB-флешку (Режим Pandora)"
        $t.Opt5 = "5) Выборочная и тихая установка драйверов"
        $t.Opt6 = "6) Выход"
        $t.Prompt = "Выберите опцию (1-6)"
        $t.Invalid = "[!] Неверная опция. Выберите число от 1 до 6."
        $t.ExitMsg = "Выход из DriverMaster..."
        $t.Pause = "Нажмите любую клавишу для продолжения..."
        
        $t.Header1 = "=== ИНСТРУКЦИЯ ПЕРВОЙ ПОМОЩИ (ЧЕРНЫЙ ЭКРАН) ==="
        $t.Header2 = "=== СКАНИРОВАНИЕ ОБОРУДОВАНИЯ И ОТЧЕТ ==="
        $t.Header3 = "=== ЛОКАЛЬНАЯ РЕЗЕРВНАЯ КОПИЯ ==="
        $t.Header4 = "=== СОЗДАНИЕ АВАРИЙНОЙ USB (РЕЖИМ PANDORA) ==="
        $t.Header5 = "=== ВЫБОРОЧНАЯ УСТАНОВКА ДРАЙВЕРОВ ==="

        $t.UsbPrompt = "Введите букву USB-диска с двоеточием (например, E:)"
        $t.UsbInvalid = "[!] Неверный или отключенный USB-диск. Убедитесь, что указали двоеточие (например, E:)."

        $t.BatName = "Восстановление-Авария.bat"
        $t.GuideName = "Инструкция_Первой_Помощи.txt"
        $t.BatTitle = "НАБОР ЭКСТРЕННОГО ВОССТАНОВЛЕНИЯ DRIVERMASTER"
        $t.BatInject = "РЕЖИМ ВОССТАНОВЛЕНИЯ: ИНТЕГРАЦИЯ СТАБИЛЬНЫХ ДРАЙВЕРОВ..."
        $t.BatFound = "Обнаружена ОС Windows на диске:"
        $t.BatErrorDrive = "[ОШИБКА] Раздел Windows не найден."
        $t.BatDone = "ВОССТАНОВЛЕНИЕ ЗАВЕРШЕНО! Можете перезагрузить компьютер."
        $t.BatFail = "[!] Ошибка при установке драйверов."

        $t.GuideText = @"
========================================================
     ПРОТОКОЛ АВАРИЙНОГО ВОССТАНОВЛЕНИЯ - ЧЕРНЫЙ ЭКРАН
========================================================
Если после обновления драйверов экран остался черным:

1. ПЕРЕКЛЮЧЕНИЕ ВИДЕОПОРТА (Встроенная графика):
   - Выключите ПК. Отключите кабель от дискретной видеокарты.
   - Подключите его к МАТЕРИНСКОЙ ПЛАТЕ (встроенное видео процессора).
   - Включите ПК для восстановления сигнала изображения.

2. СБРОС BIOS (Очистка CMOS):
   - Если сигнала нет, полностью отключите ПК от сети.
   - Извлеките круглую батарейку CMOS (CR2032) на 1 минуту и верните на место.

3. ЗАПУСК СКРИПТА ВОССТАНОВЛЕНИЯ:
   - Загрузитесь в среду восстановления или командную строку (CMD).
   - Запустите скрипт '$($t.BatName)' с этой аварийной USB-флешки.
========================================================
"@
    }
    '3' { # Español
        $t.Title = "DRIVERMASTER CLI v1.0 - GESTOR DE DRIVERS"
        $t.Opt1 = "1) Ver Guía de Primeros Auxilios (Pantalla Negra)"
        $t.Opt2 = "2) Escanear, detectar y exportar informe (Escritorio)"
        $t.Opt3 = "3) Copia de seguridad local (Drivers actuales)"
        $t.Opt4 = "4) Crear USB de Rescate Automático (Modo Pandora)"
        $t.Opt5 = "5) Instalación selectiva y silenciosa de drivers"
        $t.Opt6 = "6) Salir"
        $t.Prompt = "Selecciona una opción (1-6)"
        $t.Invalid = "[!] Opción no válida. Selecciona un número del 1 al 6."
        $t.ExitMsg = "Saliendo de DriverMaster..."
        $t.Pause = "Presiona una tecla para continuar..."
        
        $t.Header1 = "=== GUÍA DE PRIMEROS AUXILIOS (PANTALLA NEGRA) ==="
        $t.Header2 = "=== ESCANEO DE HARDWARE E INFORME ==="
        $t.Header3 = "=== COPIA DE SEGURIDAD LOCAL ==="
        $t.Header4 = "=== CREAR USB DE RESCATE (MODO PANDORA) ==="
        $t.Header5 = "=== INSTALACIÓN SELECTIVA DE DRIVERS ==="

        $t.UsbPrompt = "Introduce la letra de tu unidad USB con dos puntos (ej. E:)"
        $t.UsbInvalid = "[!] Unidad USB no válida o desconectada. Asegúrate de incluir los dos puntos (ej. E:)."

        $t.BatName = "Restaurar-Emergencia.bat"
        $t.GuideName = "PRIMEROS_AUXILIOS_FISICOS.txt"
        $t.BatTitle = "Kit de Rescate DriverMaster"
        $t.BatInject = "MODO RESCATE: INYECTANDO DRIVERS ESTABLES..."
        $t.BatFound = "Windows detectado en:"
        $t.BatErrorDrive = "[ERROR] Particion de Windows no encontrada."
        $t.BatDone = "¡RESTAURACION COMPLETADA! Ya puedes reiniciar tu PC."
        $t.BatFail = "[!] Error durante la inyeccion de drivers."

        $t.GuideText = @"
========================================================
     PROTOCOLO DE EMERGENCIA - PANTALLA NEGRA TOTAL
========================================================
Si el ordenador se queda en negro tras actualizar drivers:

1. CAMBIO DE PUERTO DE VÍDEO (Gráficos Integrados):
   - Apaga el PC. Desconecta el cable de la tarjeta gráfica dedicada.
   - Conéctalo a la PLACA BASE (gráficos integrados del procesador).
   - Enciende el PC para recuperar la señal de vídeo.

2. RESETEAR LA BIOS (Borrar CMOS):
   - Si sigue sin vídeo, desconecta el PC de la corriente.
   - Quita la pila de botón (CR2032) durante 1 minuto.
   - Vuelve a colocarla y enciende el PC.

3. EJECUTAR EL SCRIPT DE RESCATE:
   - Entra en la línea de comandos de recuperación de Windows (CMD).
   - Ejecuta '$($t.BatName)' desde este USB.
========================================================
"@
    }
    default { # Inglés (Por defecto)
        $t.Title = "DRIVERMASTER CLI v1.0 - DRIVER MANAGER"
        $t.Opt1 = "1) View First Aid Guide (Black Screen)"
        $t.Opt2 = "2) Scan hardware and report (Desktop)"
        $t.Opt3 = "3) Local backup (Current drivers)"
        $t.Opt4 = "4) Create Auto Rescue USB (Pandora Mode)"
        $t.Opt5 = "5) Selective and silent driver installation"
        $t.Opt6 = "6) Exit"
        $t.Prompt = "Select an option (1-6)"
        $t.Invalid = "[!] Invalid option. Please select a number from 1 to 6."
        $t.ExitMsg = "Exiting DriverMaster..."
        $t.Pause = "Press any key to continue..."
        
        $t.Header1 = "=== FIRST AID GUIDE (BLACK SCREEN) ==="
        $t.Header2 = "=== HARDWARE SCAN & REPORT ==="
        $t.Header3 = "=== LOCAL BACKUP ==="
        $t.Header4 = "=== CREATE AUTO RESCUE USB (PANDORA MODE) ==="
        $t.Header5 = "=== SELECTIVE DRIVER INSTALLATION ==="

        $t.UsbPrompt = "Enter your USB drive letter with colon (e.g. E:)"
        $t.UsbInvalid = "[!] Invalid or disconnected USB drive. Make sure to include the colon (e.g. E:)."

        $t.BatName = "Emergency-Restore.bat"
        $t.GuideName = "FIRST_AID_PHYSICAL_GUIDE.txt"
        $t.BatTitle = "DriverMaster Rescue Kit"
        $t.BatInject = "RESCUE MODE: INJECTING STABLE DRIVERS..."
        $t.BatFound = "Windows detected at:"
        $t.BatErrorDrive = "[ERROR] Windows partition not found."
        $t.BatDone = "RESTORATION COMPLETE! You can now restart your PC."
        $t.BatFail = "[!] Error during driver injection."

        $t.GuideText = @"
========================================================
     EMERGENCY PROTOCOL - TOTAL BLACK SCREEN
========================================================
If the PC goes black after updating drivers:

1. VIDEO PORT SWITCH (Integrated Graphics):
   - Turn off the PC. Unplug HDMI/DP from dedicated GPU.
   - Plug it into the MOTHERBOARD (CPU integrated graphics).
   - Turn on the PC to recover video signal.

2. BIOS RESET (Clear CMOS):
   - If no video, unplug the PC from power.
   - Remove the round coin cell battery (CR2032) for 1 min.
   - Put it back and turn on.

3. RUN RESCUE SCRIPT:
   - Enter Windows recovery command prompt (CMD).
   - Run '$($t.BatName)' from this USB.
========================================================
"@
    }
}

# ========================================================
# FUNCIÓN DEL MENÚ PRINCIPAL
# ========================================================
function Show-Menu {
    Clear-Host
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "       $($t.Title)       " -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host " $($t.Opt1)" -ForegroundColor Yellow
    Write-Host " $($t.Opt2)" -ForegroundColor Green
    Write-Host " $($t.Opt3)" -ForegroundColor Green
    Write-Host " $($t.Opt4)" -ForegroundColor Magenta
    Write-Host " $($t.Opt5)" -ForegroundColor Green
    Write-Host " $($t.Opt6)" -ForegroundColor Red
    Write-Host "----------------------------------------" -ForegroundColor Cyan
    Write-Host "           Developed by RS914           " -ForegroundColor Magenta
    Write-Host "========================================" -ForegroundColor Cyan
}

# ========================================================
# BUCLE PRINCIPAL
# ========================================================
do {
    Show-Menu
    $option = Read-Host $t.Prompt

    switch ($option) {
        '1' {
            Clear-Host
            Write-Host $t.Header1 -ForegroundColor Yellow
            Write-Host $t.GuideText -ForegroundColor Yellow
            Write-Host $t.Pause -ForegroundColor Cyan
            [void][System.Console]::ReadKey($true)
        }
        '2' {
            Clear-Host
            Write-Host $t.Header2 -ForegroundColor Cyan
            
            $desktopPath = [Environment]::GetFolderPath('Desktop')
            $reportPath = Join-Path $desktopPath "hardware.txt"
            $reportLines = @()
            
            $reportLines += "========================================"
            $reportLines += "         HARDWARE REPORT - DRIVERMASTER"
            $reportLines += "========================================"
            $reportLines += "Scan date: $(Get-Date)"
            $reportLines += ""

            $cpu = Get-CimInstance Win32_Processor
            $cpuName = $cpu.Name
            $cpuLine = "[+] CPU: $cpuName"
            Write-Host $cpuLine -ForegroundColor Green
            $reportLines += $cpuLine

            $mb = Get-CimInstance Win32_BaseBoard
            $mbLine = "[+] Motherboard: $($mb.Manufacturer) - $($mb.Product)"
            Write-Host $mbLine -ForegroundColor Green
            $reportLines += $mbLine

            $gpu = Get-CimInstance Win32_VideoController
            foreach ($card in $gpu) {
                $gpuLine = "[+] Active GPU: $($card.Name)"
                Write-Host $gpuLine -ForegroundColor Green
                $reportLines += $gpuLine
            }

            $ramModules = Get-CimInstance Win32_PhysicalMemory
            $totalBytes = ($ramModules | Measure-Object -Property Capacity -Sum).Sum
            $totalRamGB = [math]::Round($totalBytes / 1GB, 2)
            $totalRamMB = [math]::Round($totalBytes / 1MB, 0)
            
            $ramTotalLine = "[+] Total RAM (Physical): $totalRamGB GB ($totalRamMB MB)"
            Write-Host "[+] Total RAM (Physical): " -NoNewline
            Write-Host "$totalRamGB GB " -NoNewline -ForegroundColor Green
            Write-Host "($totalRamMB MB)" -ForegroundColor DarkGreen
            $reportLines += $ramTotalLine

            foreach ($mem in $ramModules) {
                $modGB = [math]::Round($mem.Capacity / 1GB, 1)
                $modMB = [math]::Round($mem.Capacity / 1MB, 0)
                $modLine = "    -> Module: $modGB GB ($modMB MB) | Speed: $($mem.Speed) MHz | Slot: $($mem.DeviceLocator)"
                Write-Host $modLine -ForegroundColor Yellow
                $reportLines += $modLine
            }

            $reportLines | Out-File -FilePath $reportPath -Encoding UTF8
            Write-Host "`n[+] Report successfully saved to your Desktop: hardware.txt!" -ForegroundColor Cyan
            Write-Host $t.Pause -ForegroundColor Cyan
            [void][System.Console]::ReadKey($true)
        }
        '3' {
            Clear-Host
            Write-Host $t.Header3 -ForegroundColor Cyan
            $localPath = "C:\DriversBackup"
            if (!(Test-Path $localPath)) { New-Item -ItemType Directory -Path $localPath -Force | Out-Null }
            
            Write-Host "[+] Exporting active device drivers to local disk..." -ForegroundColor Yellow
            $activeDrivers = Get-WindowsDriver -Online -All | Where-Object { $_.ClassName -ne "" -and $_.OriginalFileName -ne $null }
            $total = $activeDrivers.Count
            $i = 0
            foreach ($drv in $activeDrivers) {
                $i++
                $percent = [int](($i / $total) * 100)
                Write-Progress -Activity "Exporting Local Drivers" -Status "$i of $total drivers processed ($percent%)" -PercentComplete $percent
                & pnputil.exe /export-driver $drv.OriginalFileName "$localPath" | Out-Null
            }
            Write-Progress -Activity "Exporting Local Drivers" -Completed

            Write-Host "[+] Local backup successfully created at $localPath!" -ForegroundColor Green
            Write-Host $t.Pause -ForegroundColor Cyan
            [void][System.Console]::ReadKey($true)
        }
        '4' {
            Clear-Host
            Write-Host $t.Header4 -ForegroundColor Magenta
            
            $usbPath = Read-Host $t.UsbPrompt
            $rescueFolder = Join-Path $usbPath "DriverFlashback"
            $backupFolder = Join-Path $rescueFolder "DriversBackup"

            if (Test-Path $usbPath) {
                if (!(Test-Path $backupFolder)) { New-Item -ItemType Directory -Path $backupFolder -Force | Out-Null }

                Write-Host "[+] Step 1/3: Exporting active device drivers to USB..." -ForegroundColor Yellow

                $activeDrivers = Get-WindowsDriver -Online -All | Where-Object { $_.ClassName -ne "" -and $_.OriginalFileName -ne $null }
                $targetCount = $activeDrivers.Count
                if ($targetCount -le 0) { $targetCount = 50 }

                $currentCount = 0

                foreach ($drv in $activeDrivers) {
                    & pnputil.exe /export-driver $drv.OriginalFileName "$backupFolder" | Out-Null
                    $currentCount++
                    if ($currentCount -gt $targetCount) { $currentCount = $targetCount }

                    $percent = [math]::Min(100, [int](($currentCount / $targetCount) * 100))
                    Write-Progress -Activity "Creating Rescue USB (Pandora Mode)" -Status "Exporting driver $currentCount of $targetCount ($percent%)" -PercentComplete $percent
                }

                Write-Progress -Activity "Creating Rescue USB (Pandora Mode)" -Completed
                Write-Host "[+] Export completed successfully ($targetCount drivers)!" -ForegroundColor Green

                Write-Host "`n[+] Step 2/3: Generating recovery script ($($t.BatName))..." -ForegroundColor Yellow
                $batContent = @"
@echo off
TITLE $($t.BatTitle)
color 0C
echo ========================================================
echo   $($t.BatInject)
echo ========================================================
set "TARGET_DRIVE="
for %%d in (C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    if exist "%%d:\Windows\System32\drivers" (
        set "TARGET_DRIVE=%%d:"
        goto :StartInject
    )
)
echo $($t.BatErrorDrive)
pause
exit

:StartInject
echo $($t.BatFound) %TARGET_DRIVE%
dism /image:%TARGET_DRIVE%\ /add-driver /driver:%~dp0DriversBackup /recurse /forceunsigned
if %errorlevel% equ 0 (
    echo.
    echo ========================================================
    echo   $($t.BatDone)
    echo ========================================================
) else (
    echo $($t.BatFail)
)
pause
"@
                $batPath = Join-Path $rescueFolder $t.BatName
                $batContent | Out-File -FilePath $batPath -Encoding ASCII

                Write-Host "[+] Step 3/3: Saving physical first aid guide..." -ForegroundColor Yellow
                $guiaTxtPath = Join-Path $rescueFolder $t.GuideName
                $t.GuideText | Out-File -FilePath $guiaTxtPath -Encoding UTF8

                Write-Host "`n[+] Rescue USB successfully prepared at: $rescueFolder!" -ForegroundColor Green
            } else {
                Write-Host $t.UsbInvalid -ForegroundColor Red
            }
            Write-Host $t.Pause -ForegroundColor Cyan
            [void][System.Console]::ReadKey($true)
        }
        '5' {
            Clear-Host
            Write-Host $t.Header5 -ForegroundColor Cyan
            Write-Host "[*] Tip: Point only to your dedicated GPU folder to avoid iGPU conflicts." -ForegroundColor Yellow
            
            $driversFolder = Read-Host "Enter target folder path (e.g. C:\NewDrivers\NVIDIA)"
            
            if (Test-Path $driversFolder) {
                Write-Host "[+] Installing drivers silently..." -ForegroundColor Yellow
                pnputil /add-driver "$driversFolder\*.inf" /install /subfolders
                
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "[+] Installation completed successfully! A system restart is recommended." -ForegroundColor Green
                } else {
                    Write-Host "[!] Process finished, but some drivers may require a reboot or were already up to date." -ForegroundColor Yellow
                }
            } else {
                Write-Host "[!] The specified path does not exist." -ForegroundColor Red
            }
            Write-Host $t.Pause -ForegroundColor Cyan
            [void][System.Console]::ReadKey($true)
        }
        '6' {
            Write-Host $t.ExitMsg -ForegroundColor Cyan
            exit
        }
        default {
            Write-Host $t.Invalid -ForegroundColor Red
            Start-Sleep -Seconds 2
        }
    }
} while ($true)