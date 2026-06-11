::https://github.com/lz57005/AchillesScript

::###Setting#Start#############
::  Just uncomment the string with set  (or comment it back, 
::  only the assignment of the variable is checked, the value is not checked)

::Disable warning before applying
::set NoWarn=1

::Ignore REBOOT_PENDING
::set NoPending=1

::Disable backup
::set NoBackup=1

::Do not disable Security App
::set NotDisableSecHealth=1

::Do not disable Security App tray icon (actual only if NotDisableSecHealth=1)
::set NotHideSystray=1

::Do not disable Security Center Service (if NotDisableSecHealth=1 then NotDisableWscsvc=1 allways)
::set NotDisableWscsvc=1

::Do not create tasks in sheduler for re-disabling Defender after major windows updates
::set NotCreateReDisablingTasks=1

::Reboot in SafeMode for restore 
::set Reboot2Safe4Restore=1

::Do not reboot after restore 
::set NoReboot4Restore=1

::Reboot in SafeMode for disabling if something not work
::set UseReboot2Safe=1

::Disable reboot after applying the script not all parameters are fully applied without reboot, works only if undefined UseReboot2Safe)
::set NoReboot=1

::Do not reset the platform version (rollback to Defender version installed with Windows) while disabling
::set NotResetPlatform=1

::View deprecated [4] preset with blocking launch in interface
::Set ViewBlock=1

::Try to bypass the Tamper Protection (ignores the enabled state) without rebooting into Safe Mode.
::It works unstable (does not work in Home editions), full disabling usually on the second reboot, for test or broken systems where it is not possible to disable the Tamper Protection or reboot into Safe Mode, or just for fun
::set TryBypassTamper=1

::WARNING: DisableCIPolicies or DisablePkcsPolicies can broke store app installation
::NOTE: SYSTEM32\CodeIntegrity\CIPolicies\Active\{60FD87F8-4593-44A0-91B0-2E0DA022F248}.cip is now skipped if exists because break boot
::WARNING: Future windows updates may add new non-disableable policies that could break boot too

::Disable Code Integrity Policies (*.cip)
::set DisableCIPolicies=1

::Disable App Control Policies *.p7b (only if DisableCIPolicies=1)
::set DisablePkcsPolicies=1

::###Setting#End#############

@echo off
cls
chcp 65001
color 0F
mode 85,30
set "curver=3.9.0"
set "asv=v.%curver%"
set AS=Achilles
set "ifdef=if defined"
set "ifNdef=if not defined"
cls
dir "%windir%\sysnative" && set "sysdir=%windir%\sysnative\" || set "sysdir=%windir%\system32\"
cls
if "%sysdir%"=="X:\windows\system32\" set "sysdir="
for %%i in (C D E F G H I J K L M N O P Q R S T U V W Y Z) do (
    if exist "%%i:\Windows\System32" (
        set "sys=%%i"
        goto :SysFound
    )
)
:SysFound
cls
%ifNdef% sys set "sys=C"
%ifNdef% sysdir set "sysdir=%sys%:\windows\system32\"
set "syswow=%sys%:\windows\SysWOW64"
set "cmd=%sysdir%cmd.exe"
set "reg=%sysdir%reg.exe"
set "ra=%reg% add"
set "rq=%reg% query"
set "rd=%reg% delete"
set "rs=%reg% save"
set "rl=%reg% load"
set "ru=%reg% unload"
set "dw=REG_DWORD"
set "sz=REG_SZ"
set "msz=REG_MULTI_SZ"
set "bcdedit=%sysdir%bcdedit.exe"
set "sc=%sysdir%sc.exe"
set "find=%sysdir%find.exe"
(%sc% query Null | %find% /i"RUNNING")||(%sc% config Null start= system&%sc% start Null)||(cls&echo.&echo "Null" service is not running, run script as administrator manually&echo.&pause&exit)
cls
echo Achilles' Script...
set "findstr=%sysdir%findstr.exe"
set powershell="%sysdir%WindowsPowerShell\v1.0\powershell.exe"
%ifdef% ProgramFiles(x86) set csc="%windir%\Microsoft.NET\Framework64\v4.0.30319\csc.exe" 
%ifNdef% ProgramFiles(x86) set csc="%windir%\Microsoft.NET\Framework\v4.0.30319\csc.exe" 
set "sp=Set-MpPreference"
set "regsvr32=%sysdir%regsvr32.exe"
set "regsvr=%syswow%\regsvr32.exe"
set "whoami=%sysdir%whoami.exe"
set "fltmc=%sysdir%fltmc.exe"
set "schtasks=%sysdir%schtasks.exe"
set "shutdown=%sysdir%shutdown.exe"
set "timeout=%sysdir%timeout.exe"
set "reagentc=%sysdir%reagentc.exe"
set "tk=%sysdir%taskkill.exe"
set "gpupdate=%sysdir%gpupdate.exe"
set "tasklist=%sysdir%tasklist.exe"
set "mountvol=%sysdir%mountvol.exe"
set "manage-bde=%sysdir%manage-bde.exe"
set "curl=%sysdir%curl.exe"
set "Script=%~dpnx0"
set ScriptPS=\"%~dpnx0\"
set ASR="HKLM\Software\%AS%Script"
set "pth=%~dp0"
%rq% %ASR% /v "Name" >nul 2>&1&&for /f "tokens=2*" %%a in ('%rq% %ASR% /v "Name" 2^>nul') do (set "ASN=%%b")
echo [1;30mInitialization...[0m
%ifdef% ASN goto SkipRandom
setlocal EnableDelayedExpansion
set index=8
set number=52
set symbols=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ
:loopgen
set /a rand=%number%*%random%/32768
set name=!symbols:~%rand%,1!%name%
set /a index-=1
if %index% GTR 0 goto :loopgen
echo %name%>"%temp%\name.txt"
endlocal
set /p ASN=<"%temp%\name.txt"
del /f /q "%temp%\name.txt">nul 2>&1
:SkipRandom
set "ScriptC=%sys%:\%ASN%.cmd"
%ifdef% save goto :SkipFindSave
%rq% %ASR% /v "Save" >nul 2>&1&&for /f "tokens=2*" %%a in ('%rq% %ASR% /v "Save" 2^>nul') do (set "save=%%b"&goto :SkipFindSave)
%ifNdef% save set "save=%pth%"
%ifNdef% usertemp set "usertemp=%temp%\"
set SaveDesktop=
if "%pth%"=="%temp%\" set SaveDesktop=1
echo %pth%|%findstr% /i /c:"\\\\">nul 2>&1&&set SaveDesktop=1
echo %pth%|%findstr% /i /c:"%temp%">nul 2>&1&&set SaveDesktop=1
echo %pth%|%findstr% /i /c:"%tmp%">nul 2>&1&&set SaveDesktop=1
%ifNdef% save if "%pth%"=="%usertemp%\" set SaveDesktop=1
%ifdef% SaveDesktop for /f "tokens=2*" %%a in ('%rq% "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v "Desktop" 2^>nul') do set "save=%%b\"
%ifdef% SaveDesktop for /f "tokens=*" %%a in ('echo "%save%"') do @set save=%%a
%ifdef% SaveDesktop set "save=%save:"=%"
%ifdef% SaveDesktop if not exist "%save%" set "save=%USERPROFILE%\Desktop\"
set "save=%save%Achilles Backup\"
:SkipFindSave
echo [1;30mChecking the settings...[0m
if not exist "%temp%" set "temp=%sys%:"
%rq% %ASR% /v "NotDisableSecHealth" >nul 2>&1&&for /f "tokens=2*" %%a in ('%rq% %ASR% /v "NotDisableSecHealth" 2^>nul') do (set "NotDisableSecHealth=%%b")
%rq% %ASR% /v "NotHideSystray" >nul 2>&1&&for /f "tokens=2*" %%a in ('%rq% %ASR% /v "NotHideSystray" 2^>nul') do (set "NotHideSystray=%%b")
%rq% %ASR% /v "NotDisableWscsvc" >nul 2>&1&&for /f "tokens=2*" %%a in ('%rq% %ASR% /v "NotDisableWscsvc" 2^>nul') do (set "NotDisableWscsvc=%%b")
%rq% %ASR% /v "DisableCIPolicies" >nul 2>&1&&for /f "tokens=2*" %%a in ('%rq% %ASR% /v "DisableCIPolicies" 2^>nul') do (set "DisableCIPolicies=%%b")
%rq% %ASR% /v "DisablePkcsPolicies" >nul 2>&1&&for /f "tokens=2*" %%a in ('%rq% %ASR% /v "DisablePkcsPolicies" 2^>nul') do (set "DisablePkcsPolicies=%%b")
%rq% %ASR% /v "UseReboot2Safe" >nul 2>&1&&for /f "tokens=2*" %%a in ('%rq% %ASR% /v "UseReboot2Safe" 2^>nul') do (set "UseReboot2Safe=%%b")
%rq% %ASR% /v "Reboot2Safe4Restore" >nul 2>&1&&for /f "tokens=2*" %%a in ('%rq% %ASR% /v "Reboot2Safe4Restore" 2^>nul') do (set "Reboot2Safe4Restore=%%b")
%rq% %ASR% /v "NoReboot4Restore" >nul 2>&1&&for /f "tokens=2*" %%a in ('%rq% %ASR% /v "NoReboot4Restore" 2^>nul') do (set "NoReboot4Restore=%%b")
%rq% %ASR% /v "NotResetPlatform" >nul 2>&1&&for /f "tokens=2*" %%a in ('%rq% %ASR% /v "NotResetPlatform" 2^>nul') do (set "NotResetPlatform=%%b")
set "arg1=%~1"
set "arg2=%~2"
shift
set "args=%*"
set "runasti=%args:* =%"
set "msg=call :2LangMsg"
set "err=call :2LangErr"
set "errn=call :2LangErrNoPause"
set L=ru
set isTrustedInstaller=
set "dl=Disable"
set "el=Enable"
set "df=Defend"
set "wd=Windows %df%er"
set "ss=SmartScreen"
set "cv=CurrentVersion"
set "scc=SYSTEM\CurrentControlSet\Control"
set "smw=SOFTWARE\Microsoft\Windows"
set "spm=SOFTWARE\Policies\Microsoft"
set "smwd=%smw% %df%er"
set "smwci=%smw% NT\%cv%\Image File Execution Options"
set "spmwd=%spm%\%wd%"
set "sccd=%scc%\DeviceGuard"
set "scs=SYSTEM\CurrentControlSet\Services"
set "scl=SOFTWARE\Classes"
set "uwpsearch=HKLM\%scl%\Local Settings\%smw%\%cv%\AppModel\PackageRepository\Packages"
set "regback=%save%Registry Backup"
set "plist=HKLM\%smw% NT\%cv%\ProfileList"
set "evt=WINEVT\Channels\Microsoft-Windows-"
(%rq% "HKCU\Keyboard Layout\Preload" 2>nul|%find% "00000419">nul 2>&1) && (set Lang=%L%)
(%rq% "HKCU\Control Panel\Desktop" /v PreferredUILanguages 2>nul|%find% "%L%-%L%">nul 2>&1) && (set Lang=%L%)
::set Lang=
%ifNdef% Lang (title %AS%'Script) else (title Ахилесов Скрипт)
if not "%temp%"=="" echo %pth%|%findstr% /i /c:"%temp%">nul 2>&1&&if not "%pth%"=="%temp%\" %err% "The script is running from an archive or a subfolder in temp. Run the script from another location." "Скрипт запущен из архива или подпапки в темпе. Запустите скрипт из другого места."
if not "%tmp%"=="" echo %pth%|%findstr% /i /c:"%tmp%">nul 2>&1&&if not "%pth%"=="%tmp%\" %err% "The script is running from an archive or a subfolder in temp. Run the script from another location." "Скрипт запущен из архива или подпапки в темпе. Запустите скрипт из другого места."
%msg% "[1;30mPrivileges check...[0m" "[1;30mПроверка привилегий...[0m"
%fltmc% >nul 2>&1||(%whoami% /groups|%find% "S-1-5-32-544" >nul 2>&1)||%ifdef% Lang (echo Запустите этот файл из под учетной записи с правами администратора)&pause&exit else (echo Run this file under an account with administrator rights)&pause&exit
if not exist %powershell% %err% "Error %powershell% file not exist" "Ошибка файл %powershell% не найден"
call :CheckTrusted||%bcdedit% >nul 2>&1||(if "%AdminRestart%"=="1" (%err% "Error! bcdedit is broken or unable to get admin rights using powershell" "Ошибка! bcdedit поломан или невозможно получить права администратора через powershell"&exit) else (set AdminRestart=1&%msg% "Requesting Administrator privileges..." "Запрос привилегий администратора..."&%powershell% -MTA -NoP -NoL -NonI -EP Bypass -c Start-Process %cmd% -ArgumentList '/c', '%ScriptPS% %args%' -Verb RunAs&exit))
echo test>>"%pth%test.ps1"&&del /f /q "%pth%test.ps1"||(%err% "Testing write error in %pth%test.ps1" "Ошибка тестовой записи в %pth%test.ps1")
echo test>>"%pth%test.cmd"&&del /f /q "%pth%test.cmd"||(%err% "Testing write error in %pth%test.cmd" "Ошибка тестовой записи в %pth%test.cmd")
set REBOOT_PENDING=
%rq% "HKLM\%smw%\%cv%\WindowsUpdate\Auto Update\RebootRequired" > nul 2>&1 && set REBOOT_PENDING=1
%rq% "HKLM\%smw%\%cv%\Component Based Servicing\RebootPending" > nul 2>&1 && set REBOOT_PENDING=1
%ifNdef% NoPending %ifdef% arg1 %ifdef% REBOOT_PENDING %errn% "Scheduled actions during reboot, reboot before using the script" "Запланированы действия во время перезагрузки, перед использованием скрипта перезагрузитесь"
%msg% "[1;30mChecking arguments...[0m" "[1;30mПроверка аргументов...[0m"
%ifdef% arg1 (
	for %%i in (apply multi restore block unblock ti backup safeboot winre sac uwpoff uwpon fixboot) do if [%arg1%]==[%%i] set "isValidArg=%%i"
	%ifNdef% isValidArg %errn% "Invalid command line arguments %args%" "Недопустимые аргументы командной строки %args%"
	set  isValidArg=
)
%rd% %ASR% /f >nul 2>&1
%ifNdef% arg1 if exist "%temp%\hkcu.txt" del /f /q "%temp%\hkcu.txt">nul 2>&1
if "%arg1%"=="apply" (
	%ifdef% arg2 for %%i in (1 2 3 4 5 policies setting services block) do if [%arg2%]==[%%i] set "isValidArg=%%i"
	%ifNdef% isValidArg %errn% "Invalid command line arguments %args%" "Недопустимые аргументы командной строки %args%"
	%ifdef% arg2 for %%i in (1 2 3 4 5) do if [%arg2%]==[%%i] call :Menu%%i
	if [%arg2%]==[policies] set Policies=1
	if [%arg2%]==[setting]  set Registry=1
	if [%arg2%]==[services] set Services=1
	if [%arg2%]==[block]    set Block=1
	call :MAIN
)
if "%arg1%" neq "multi" goto :SkipMulti
	:multi
	set "multi=%~1"
	set isValidArg=
	%ifdef% multi for %%i in (policies setting services block) do if [%multi%]==[%%i] set "isValidArg=%%i"
	%ifNdef% isValidArg %errn% "Invalid command line arguments %args%" "Недопустимые аргументы командной строки %args%"
	if [%isValidArg%]==[policies] set Policies=1
	if [%isValidArg%]==[setting]  set Registry=1
	if [%isValidArg%]==[services] set Services=1
	if [%isValidArg%]==[block]    set Block=1
	shift
	if [%~1] == [] call :MAIN
	goto :multi
:SkipMulti
if "%arg1%"=="restore" call :Menu5
if "%arg1%"=="block"   if "%arg2%" neq "" (call :BlockProcess %arg2%&exit /b)
if "%arg1%"=="unblock" if "%arg2%" neq "" (call :UnBlockProcess %arg2%&exit /b)
if "%arg1%"=="ti"      (call :TrustedRun&exit /b %errorlevel%)
if "%arg1%"=="backup"  (
	set NoBackup=
	del /f /q "%save%MySecurityDefaults.reg">nul 2>&1
	rd /s /q "%regback%">nul 2>&1
	call :LoadUsers
	call :Backup
	exit /b
)
if "%arg1%"=="safeboot" call :Reboot2Safe only
if "%arg1%"=="winre"  call :WinRE&exit /b
if "%arg1%"=="sac"    call :SAC&exit /b
if "%arg1%"=="uwpoff" if "%arg2%" neq "" (call :BlockUWP %arg2%&exit /b)
if "%arg1%"=="uwpon"  if "%arg2%" neq "" (call :UnBlockUWP %arg2%&exit /b)
if "%arg1%"=="fixboot" %powershell% -MTA -NoP -NoL -NonI -EP Bypass -c "$g = $null; bcdedit /v | ForEach-Object { if ($_ -match 'identifier\s+(\{[^}]+\})') { $g = $Matches[1] } if ($_ -match 'description\s+Safe Mode\s*$' -and $g) { bcdedit /delete $g /f >$null 2>&1; $g = $null } }"&%bcdedit% /timeout 30&%bcdedit% /deletevalue {bootmgr} displaybootmenu&exit /b
if "%arg1%" neq "" %err% "Invalid command line arguments %args%" "Недопустимые аргументы командной строки %args%"

%msg% "[1;30mDetermining the Windows version...[0m" "[1;30mОпределение версии Windows...[0m"
for /f "tokens=4 delims= " %%v in ('ver') do set "win=%%v"
for /f "tokens=3 delims=." %%v in ('echo  %win%') do set /a "build=%%v"
for /f "tokens=1 delims=." %%v in ('echo  %win%') do set /a "win=%%v"
for /f "tokens=4" %%a in ('ver') do set "WindowsBuild=%%a"
set "WindowsBuild=%WindowsBuild:~5,-1%"
if [%win%] lss [10] %ifdef% Lang (echo Этот скрипт разработан для Windows 10 и новее)&echo.&pause&exit else (echo This Script is designed for Windows 10 and newer)&echo.&pause&exit
for /f "tokens=2*" %%a in ('%rq% "HKLM\%smw% NT\%cv%" /v ProductName') do set "WindowsVersion=%%b"
if [%build%] geq [22000] set WindowsVersion=%WindowsVersion:10=11%
::##############################################################
:BEGIN
set Item=
set Policies=
set Registry=
set Services=
set Block=

call :Screen
%ifNdef% Lang (choice /C 1234567890X /N /M "Enter menu item number using your keyboard:") else (choice /C 1234567890X /N /M "Введите номер пункта меню используя клавиатуру:")
set "Item=%errorlevel%"
if %Item% gtr 10 exit
call :Menu%Item%

:Menu10
call :Status

:Menu1
set Policies=1
call :MAIN
:Menu2
set Registry=1
call :Menu1
:Menu3
set Services=1
call :Menu2
:Menu4
set Block=1
call :Menu3

:Menu5
cls
%ifNdef% arg1 %ifNdef% NoWarn call :WarnRestore
%msg% "Restore defaults..." "Восстановление по умолчанию..."
%ifdef% Item set "args=apply %Item%"
call :CheckTrusted||call :LoadUsers
call :CheckTrusted||call :RestoreCurrentUser
%ifNdef% SAFEBOOT_OPTION %ifdef% Reboot2Safe4Restore call :Reboot2Safe
call :CheckTrusted||(call :TrustedRun 1&&exit)
call :Restore
if [%build%] geq [22000] %ra% "HKLM\%smw%\%cv%\RunOnce" /v "RevertPlatform" /t %sz% /d "\"%sys%:\Program Files\%wd%\MpCmdRun.exe\" -RevertPlatform" /f>nul 2>&1
%ifNdef% NoReboot4Restore call :Reboot2Normal
exit

:Menu6
set SubItem=
call :Header
%msg% "[36m─────────────────────────────────────────────────────────────────────────────[0m" "[36m──────────────────────────────────────────────────────────────────────────────[0m"
set DefVBS=
set DefVBSreg=
set DefVBSps=
set DefVBSLock=
set DefLsa=
set DefLsaLock=
set DefCred=
set DefCredLock=
%msg% "[1;32mSystem analysis...[0m" "[1;32mАнализ системы...[0m"
echo.
del /f /q "%temp%\%AS%status.txt">nul 2>&1
chcp 437 >nul 2>&1
%powershell% -MTA -NoL -NonI -EP Bypass -c "Get-WmiObject -ClassName Win32_DeviceGuard -Namespace root\Microsoft\Windows\DeviceGuard">"%temp%\%AS%status.txt"
chcp 65001 >nul 2>&1
%ifNdef% DefVBS (%rq% "HKLM\%sccd%\Scenarios\HypervisorEnforcedCodeIntegrity" /v "%el%d" 2>nul|%find% "0x1">nul 2>&1)&&set DefVBSreg=1||set DefVBSreg=
%findstr% /r /c:"VirtualizationBasedSecurityStatus *: *\0" "%temp%\%AS%status.txt" >nul 2>&1&&set "DefVBSps="||set DefVBSps=1
del /f /q "%temp%\%AS%status.txt">nul 2>&1
%ifdef% DefVBSreg set DefVBS=1
%ifdef% DefVBSps  set DefVBS=1
%ifNdef% DefVBSreg %ifdef% DefVBSps set DefVBSLock=1
%ifNdef% DefVBSLock %ifdef% DefVBS (%rq% "HKLM\%sccd%\Scenarios\HypervisorEnforcedCodeIntegrity" /v "Locked" 2>nul|%find% "0x1">nul 2>&1)&&set DefVBSLock=1||set DefVBSLock=
(%rq% "HKLM\%scc%\Lsa" /v "RunAsPPLBoot" 2>nul|%find% "0x2">nul 2>&1)&&set DefLsa=1||set DefLsa=
(%rq% "HKLM\%scc%\Lsa" /v "RunAsPPL" 2>nul|%find% "0x2">nul 2>&1)&&set DefLsa=1
(%rq% "HKLM\%scc%\Lsa" /v "RunAsPPLBoot" 2>nul|%find% "0x1">nul 2>&1)&&set DefLsaLock=1||set DefLsaLock=
(%rq% "HKLM\%scc%\Lsa" /v "RunAsPPL" 2>nul|%find% "0x1">nul 2>&1)&&set DefLsaLock=1
(%rq% "HKLM\%spm%\Windows\System" /v "RunAsPPL" 2>nul|%find% "0x1">nul 2>&1)&&set DefLsaLock=1
(%rq% "HKLM\%scc%\CI\State">nul 2>&1)&&((%rq% "HKLM\%scc%\CI\State" /v "HVCI%el%d" 2>nul|%find% "0x1">nul 2>&1)&&set DefCred=1||set DefCred=)||set DefCred=
(%rq% "HKLM\%sccd%\Scenarios\KeyGuard\Status">nul 2>&1)&&((%rq% "HKLM\%sccd%\Scenarios\KeyGuard\Status" /v "CredGuard%el%d" 2>nul|%find% "0x1">nul 2>&1)&&set DefCred=1||set DefCred=)||set DefCred=
%ifdef% DefCred (%rq% "HKLM\%sccd%\Scenarios\HypervisorEnforcedCodeIntegrity" /v "Locked" 2>nul|%find% "0x1">nul 2>&1)&&set DefCredLock=1||set DefCredLock=
%bcdedit%|%find% "hypervisorlaunchtype    Auto">nul 2>&1&&set hyperv=1||set "hyperv="
cls
call :Header
%msg% "[36m─────────────────────────────────────────────────────────────────────────────[0m" "[36m──────────────────────────────────────────────────────────────────────────────[0m"
%ifdef% DefLsaLock  (%msg% " LSA              [31mLocked[0m" " LSA              [31mзаблокирован[0m") else (%msg% " LSA              [1;32mNOT[0m locked" " LSA              [1;32mНЕ[0m заблокирован")
%ifdef% DefVBSLock  (%msg% " VBS              [31mLocked[0m" " VBS              [31mзаблокирован[0m") else (%msg% " VBS              [1;32mNOT[0m locked" " VBS              [1;32mНЕ[0m заблокирован")
%ifdef% DefCredLock (%msg% " Credential Guard [31mLocked[0m" " Credential Guard [31mзаблокирован[0m") else (%msg% " Credential Guard [1;32mNOT[0m locked" " Credential Guard [1;32mНЕ[0m заблокирован")
%ifdef% hyperv      (%msg% " Hypervisor       [31mEnabled[0m" " Hypervisor       [31mвключен[0m") else (%msg% " Hypervisor       [1;32mDisabled[0m" " Hypervisor       [1;32mВыключен[0m")
%msg% "[36m────────────────────────────────────────────────────────────────────────────┐[0m" "[36m─────────────────────────────────────────────────────────────────────────────┐[0m"
%msg% " [1;34m[1][0m Unlock LSA [1;30m[Local Security Authority protection][0m                       [36m│[0m" " [1;34m[1][0m Разблокировать LSA [1;30m[Защита локальной системы безопасности][0m              [36m│[0m"
%msg% " [1;34m[2][0m Unlock VBS [1;30m[Virtual based security][0m                                    [36m│[0m" " [1;34m[2][0m Разблокировать VBS [1;30m[Безопасность на основе виртуализации][0m               [36m│[0m"
%msg% " [1;34m[3][0m Unlock Credential Guard                                                [36m│[0m" " [1;34m[3][0m Разблокировать Credential Guard                                         [36m│[0m"
%msg% " [1;34m[4][0m Unlock All                                                             [36m│[0m" " [1;34m[4][0m Разблокировать всё                                                      [36m│[0m"
%msg% " [1;34m[5][0m Disable Hypervisor and reboot                                          [36m│[0m" " [1;34m[5][0m Отключить гипервизор и перезгрузиться                                   [36m│[0m"
%msg% " [1;34m[6][0m Disable Hypervisor and unlock all                                      [36m│[0m" " [1;34m[6][0m Отключить гипервизор и разблокировать всё                               [36m│[0m"
%msg% "[36m────────────────────────────────────────────────────────────────────────────┤[0m" "[36m─────────────────────────────────────────────────────────────────────────────┤[0m"
%msg% " [1;35m[X][0m Back                                                                   [36m│[0m" " [1;35m[X][0m Назад                                                                   [36m│[0m"
%msg% "[36m────────────────────────────────────────────────────────────────────────────┘[0m" "[36m─────────────────────────────────────────────────────────────────────────────┘[0m"
%ifNdef% Lang (choice /C 123456X /N /M "Enter menu item number using your keyboard:") else (choice /C 123456X /N /M "Введите номер пункта меню используя клавиатуру:")
set "SubItem=%errorlevel%"
if [%SubItem%] == [1] call :UnlockUEFI LSA
if [%SubItem%] == [2] call :UnlockUEFI VBS
if [%SubItem%] == [3] call :UnlockUEFI CG
if [%SubItem%] == [4] call :UnlockUEFI ALL
if [%SubItem%] == [5] %bcdedit% /set hypervisorlaunchtype off&call :Reboot2Normal&exit
if [%SubItem%] == [6] call :UnlockUEFI ALLHV
if %SubItem% gtr 6 goto :BEGIN
exit
 
:Menu7
set SubItem=
call :Header
%msg% "[36m────────────────────────────────────────────────────────────────────────────┐[0m" "[36m─────────────────────────────────────────────────────────────────────────────┐[0m"
%msg% " [1;34m[1][0m Reboot to UEFI                                                         [36m│[0m" " [1;34m[1][0m Перезагрузится в UEFI                                                   [36m│[0m"
%msg% " [1;34m[2][0m Reboot to Windows Recovery Environment                                 [36m│[0m" " [1;34m[2][0m Перезагрузится в среду восстановления Windows                           [36m│[0m"
%msg% " [1;34m[3][0m Reboot to Safe mode                                                    [36m│[0m" " [1;34m[3][0m Перезагрузится в безопасный режим                                       [36m│[0m"
%msg% " [1;34m[4][0m Reboot normal                                                          [36m│[0m" " [1;34m[4][0m Перезагрузится обычно                                                   [36m│[0m"
%msg% "[36m────────────────────────────────────────────────────────────────────────────┤[0m" "[36m─────────────────────────────────────────────────────────────────────────────┤[0m"
%msg% " [1;35m[X][0m Back                                                                   [36m│[0m" " [1;35m[X][0m Назад                                                                   [36m│[0m"
%msg% "[36m────────────────────────────────────────────────────────────────────────────┘[0m" "[36m─────────────────────────────────────────────────────────────────────────────┘[0m"
%ifNdef% Lang (choice /C 1234X /N /M "Enter menu item number using your keyboard:") else (choice /C 1234X /N /M "Введите номер пункта меню используя клавиатуру:")
set "SubItem=%errorlevel%"
if [%SubItem%] == [1] %ifNdef% SAFEBOOT_OPTION (%shutdown% /r /fw /t 3 /c "Reboot to UEFI"&%timeout% /t 4&exit) else (cls&%msg% "You cannot reboot into UEFI from Safe Mode" "Нельзя перезагрузиться в UEFI из безопасного режима"&echo.&pause&goto :Menu7)
if [%SubItem%] == [2] cls&call :WinRE&exit 
if [%SubItem%] == [3] cls&call :Reboot2Safe only
if [%SubItem%] == [4] %shutdown% /r /f /t 3 /c "Reboot"&%timeout% /t 4&exit
if %SubItem% gtr 4 goto :BEGIN
exit

:Menu8
set SubItem=
call :Header
%msg% "[36m────────────────────────────────────────────────────────────────────────────┐[0m" "[36m─────────────────────────────────────────────────────────────────────────────┐[0m"
%msg% " [36mRun with TrustedInstaller privileges:[0m                                      [36m│[0m" " [36mЗапустить с правами TrustedInstaller:[0m                                       [36m│[0m"
%msg% " [1;34m[1][0m cmd.exe                                                                [36m│[0m" " [1;34m[1][0m cmd.exe                                                                 [36m│[0m"
%msg% " [1;34m[2][0m powershell.exe                                                         [36m│[0m" " [1;34m[2][0m powershell.exe                                                          [36m│[0m"
%msg% " [1;34m[3][0m regedit.exe                                                            [36m│[0m" " [1;34m[3][0m regedit.exe                                                             [36m│[0m"
%msg% "[36m────────────────────────────────────────────────────────────────────────────┤[0m" "[36m─────────────────────────────────────────────────────────────────────────────┤[0m"
%msg% " [1;35m[X][0m Back                                                                   [36m│[0m" " [1;35m[X][0m Назад                                                                   [36m│[0m"
%msg% "[36m────────────────────────────────────────────────────────────────────────────┘[0m" "[36m─────────────────────────────────────────────────────────────────────────────┘[0m"
%ifNdef% Lang (choice /C 123X /N /M "Enter menu item number using your keyboard:") else (choice /C 123X /N /M "Введите номер пункта меню используя клавиатуру:")
set "SubItem=%errorlevel%"
if [%SubItem%] == [1] call :TrustedRun 2&goto :Menu8
if [%SubItem%] == [2] call :TrustedRun 3&goto :Menu8
if [%SubItem%] == [3] call :TrustedRun 4&goto :Menu8
if %SubItem% gtr 3 goto :BEGIN
goto :Menu8

:Menu9
del /f /q "%~dp0latest.json" >nul 2>&1
del /f /q "%~dp0script.tmp"  >nul 2>&1
set SubItem=
call :Header
%msg% "[36m────────────────────────────────────────────────────────────────────────────┐[0m" "[36m─────────────────────────────────────────────────────────────────────────────┐[0m"
%msg% " [1;34m[1][0m Update Script                                                          [36m│[0m" " [1;34m[1][0m Обновить скрипт                                                         [36m│[0m"
%msg% " [1;34m[2][0m Open readme.md online                                                  [36m│[0m" " [1;34m[2][0m Открыть readme.md online                                                [36m│[0m"
%msg% " [1;34m[3][0m Short Help                                                             [36m│[0m" " [1;34m[3][0m Краткая справка                                                         [36m│[0m"
%msg% "[36m────────────────────────────────────────────────────────────────────────────┤[0m" "[36m─────────────────────────────────────────────────────────────────────────────┤[0m"
%msg% " [1;35m[X][0m Back                                                                   [36m│[0m" " [1;35m[X][0m Назад                                                                   [36m│[0m"
%msg% "[36m────────────────────────────────────────────────────────────────────────────┘[0m" "[36m─────────────────────────────────────────────────────────────────────────────┘[0m"
%ifNdef% Lang (choice /C 123X /N /M "Enter menu item number using your keyboard:") else (choice /C 123X /N /M "Введите номер пункта меню используя клавиатуру:")
set "SubItem=%errorlevel%"
if [%SubItem%] == [1] call :Update
if [%SubItem%] == [2] start "" "https://github.com/lz57005/AchillesScript"
if [%SubItem%] == [3] call :MiniHelp
if %SubItem% gtr 3 goto :BEGIN
goto :Menu9

:Update
call :Header
echo.
%msg% " Checking availability github.com..." " Проверка доступности github.com..."
%curl% -skLRI "https://github.com" -o nul || (%msg% " [31mGithub.com unavailable for curl[0m" " [31mGithub.com не достпупен для curl[0m"&echo.&pause&goto :Menu9)
%msg% " Requesting data via api.github.com..." " Запрос данных через api.github.com..."
%curl% -#LRk https://api.github.com/repos/lz57005/AchillesScript/releases/latest -o "%~dp0latest.json" || (%msg% " [31mError downloading JSON via api.github.com[0m" " [31mОшибка загрузки JSON через api.github.com[0m"&echo.&pause&goto :Menu9) 
%msg% " Definition of the latest version..." " Определение последней версии..." 
%findstr% /i /C:"API rate limit exceeded" "%~dp0latest.json" >nul 2>&1 && (%msg% " [31mGithub API request limit exceeded for your IP, try later[0m" " [31mПревышен лимит запросов API Github для вашего IP-адреса, попробуйте позже[0m"&echo.&pause&goto :Menu9) 
for /f "usebackq delims=" %%L in (`%findstr% /rc:"\"tag_name\" *: *\".*\"" "%~dp0latest.json"`) do set "verline=%%L"&goto :gotver
:gotver
del /f /q "%~dp0latest.json" >nul 2>&1
if "%verline%"=="" %msg% " [31mError getting the latest version[0m" " [31mОшибка получения последней версии[0m"&echo.&pause&goto :Menu9)
for /f "tokens=1* delims=:" %%a in ("%verline%") do set "newver=%%b"
set "newver=%newver:,=%"
set "newver=%newver:"=%"
set "newver=%newver: =%"
if "%curver%"=="%newver%" (
		%msg% " Your current version is %curver% latest, no updates" " Ваша текущая версия %curver% последняя, обновлений нет"&echo.&pause&goto :Menu9
	) else (
		%msg% " [32mThe new [0m[34mver %newver%[0m[32m is available" " [32mДоступна новая [0m[34mver %newver%[0m"
		%msg% " [[32m1[0m] - [32mYes[0m [[31m0[0m] - [31mNo[0m" " [[32m1[0m] - [32mДа[0m [[31m0[0m] - [31mНет[0m"
		%ifNdef% Lang (choice /C 01 /N /M "Update now?") else (choice /C 01 /N /M "Обновить сейчас?")
		set "SubItem=%errorlevel%"
		if [%SubItem%] == [0] goto :Menu9
	)
%curl% -#LRk https://github.com/lz57005/AchillesScript/releases/download/%newver%/AchillesScript.cmd -o "%~dp0script.tmp" || (%msg% " [31mError loading the script from github.com[0m" " [31mОшибка загрузки скрипта с github.com[0m"&echo.&pause&goto :Menu9)  
set /p check_script=<"%~dp0script.tmp" 
if not "%check_script%"=="::https://github.com/lz57005/AchillesScript" (%msg% " [31mError loading the script[0m" " [31mОшибка загрузки скрипта[0m"&echo.&pause&goto :Menu9)
move /y "%~dp0script.tmp" "%Script%">nul 2>&1&&((start "" "%Script%")&exit)||(%msg% " [31mError script update[0m" " [31mОшибка обновления скрипта[0m"&echo.&pause&goto :Menu9)
del /f /q "%~dp0script.tmp"  >nul 2>&1
goto :Menu9

:MAIN
cls
%ifdef% Policies %ifNdef% Registry %ifNdef% Services %ifNdef% Block set PoliciesOnly=1
%ifdef% arg1 %ifdef% SecondStage goto :SecondStage
%ifdef% arg1 %ifdef% SAFEBOOT_OPTION goto :MainWork
%ifNdef% NoPending %ifdef% REBOOT_PENDING %err% "Scheduled actions during reboot, reboot before using the script" "Запланированы действия во время перезагрузки, перед использованием скрипта перезагрузитесь"
set "DefTamper="
(%rq% "HKLM\%smwd%\Features" /v "TamperProtection">nul 2>&1)&&((%rq% "HKLM\%smwd%\Features" /v "TamperProtection" 2>nul|%find% "0x4">nul 2>&1)&&set "DefTamper="||set DefTamper=1)||set "DefTamper="
%ifdef% DefTamper %ifNdef% TryBypassTamper (set "UseReboot2Safe=1"&set "NoReboot=")
%ifNdef% NoWarn %ifNdef% arg1 call :Warning
call :LoadUsers
%ifNdef% NoBackup call :Backup
%ifdef% Item set "args=apply %Item%">nul 2>&1
%ifNdef% SAFEBOOT_OPTION (
	call :StopTelemetry
	%ifdef% Registry call :TasksDisable
	%ifNdef% PoliciesOnly %ifNdef% NotCreateReDisablingTasks call :TasksForReDisabling
	%ifdef% UseReboot2Safe call :Reboot2Safe
	)
:MainWork
%ifdef% SAFEBOOT_OPTION call :LoadUsers
call :WorkUsers
set SecondStage=1
call :CheckTrusted||(call :TrustedRun 1&&exit&cls)
:SecondStage
call :Policies
%ifNdef% SAFEBOOT_OPTION call :SetMpPreference
%ifNdef% PoliciesOnly call :ResetPlatform
%ifNdef% SAFEBOOT_OPTION %ifNdef% PoliciesOnly call :StopInstances
%ifdef% Policies call :PoliciesReg
%ifNdef% UseReboot2Safe if exist "%gpupdate%" (%msg% "Updating policy..." "Обновление политик..."&("%gpupdate%" /force>nul 2>&1||"%gpupdate%" /force>nul 2>&1))
%ifdef% Registry if [%build%] geq [19045] call :UnregDll
%ifdef% Registry call :Registry
%ifdef% Registry call :ASRdel
%ifdef% DisableCIPolicies %ifdef% Registry call :CIPolicies
%ifdef% Services call :Services
%ifdef%    Block call :Block
%ifdef% SAFEBOOT_OPTION %ifdef% UseReboot2Safe call :Reboot2Normal
%ifNdef% NoReboot call :Reboot2Normal
%ifdef% NoReboot %ra% "HKLM\%smw%\%cv%\RunOnce" /v "NeedRestart" /t %sz% /d "" /f>nul 2>&1
%msg% "DONE" "ЗАВЕРШЕНО"
echo.
set arg1=
set Item=
%timeout% /t 3
exit

:2LangMsg
chcp 65001 >nul 2>&1
%ifdef% Lang (echo %~2) else (echo %~1)
%ifdef% SAFEBOOT_OPTION %ifdef% arg1 (%ifdef% Lang (echo %~2>>"%sys%:\%AS%.log") else (echo %~1>>"%sys%:\%AS%.log"))
exit /b

:2LangErr
chcp 65001 >nul 2>&1
(%ifdef% Lang (echo %~2) else (echo %~1))&pause>nul 2>&1&exit

:2LangErrNoPause
chcp 65001 >nul 2>&1
(%ifdef% Lang (echo %~2) else (echo %~1))&exit /b 1

:CheckTrusted
%whoami% /GROUPS|%find% "S-1-16-16384">nul 2>&1&&exit /b 0||exit /b 1

:Warning
cls
set SubItem=
if "%Item%"=="1" %msg% " [4;1;32mGroup Policies                                                                  [0m" " [4;1;32mГрупповые политики                                                              [0m"
if "%Item%"=="2" %msg% " [4;1;32mGroup Policies + Registry Settings                                              [0m" " [4;1;32mГрупповые политики + Настройки реестра                                          [0m"
if "%Item%"=="3" %msg% " [4;1;32mGroup Policies + Registry Settings + Disabling Services and drivers             [0m" " [4;1;32mГрупповые политики + Настройки реестра + Отключение служб и драйверов           [0m"
if "%Item%"=="4" %msg% " [4;1;32mPolicies + Settings + Disabling Services and drivers + Block launch             [0m" " [4;1;32mПолитики + Настройки + Отключение служб и драйверов + Блокировка запуска        [0m"
if exist "%save%MySecurityDefaults.reg" %msg% " [1;30mMySecurityDefaults.reg is detected, backup of the current settings will be skipped.[0m" " [1;30mОбнаружен MySecurityDefaults.reg, будет пропущен бэкап текущих настроек.[0m"
if exist "%save%MySecurityDefaults.reg" echo  "%save%MySecurityDefaults.reg"
%ifdef% Policies (
%msg% " [36mGroup policies will be applied to %dl%:[0m" " [36mБудут применены групповые политики для отключения компонент:[0m"
%msg% " Microsoft %df%er, Tamper protection, Smart App Control," " Microsoft %df%er, Защита от подделки, Интелектуальное управления приложениями,"
%msg% " Virtual based security, Local Security Authority protection, Credential Guard." " Безопасность на основе виртуализации VBS, Защита LSA, Credential Guard."
%msg% " %ss%, Attack surface reduction ASR rules." " %ss%, Правила сокращения направлений атак ASR."
if exist "%sysdir%MRT.exe" %msg% " %dl% updating and reporting for Malicious Software Removal Tool." " Отключено обновление и отчеты средства удаления вредоносных программ MRT."
)
%ifdef% Registry (
%msg% " [36mWill be disabled:[0m" " [36mБудут отключены:[0m"
%msg% " Tasks in scheduler, warnings for downloaded files, file explorer extensions." " Задачи планировщика, предупреждения для скачанных файлов, расширения проводника."
)
%ifdef% Services %msg% " %df%er services and drivers. Applocker." " Службы и драйверы защитника. Applocker."
%ifdef%    Block %msg% " Launch of %df%er executable files and services will be blocked." " Будет заблокирован запуск исполняемых файлов и служб защитника."
%ifdef% DisableCIPolicies  (%msg% " Code integrity policies and app control." " Политики целостности кода и управления приложениями.") else (echo.) 
%ifNdef% NotDisableSecHealth (%msg% " Security application and its components." " Приложение Безопасность и его компоненты.") else (echo.)
%msg% " [1;30mUse the numbers on your keyboard to change settings, continue, or cancel.[0m" " [1;30mИспользуйте цифры на клавиатуре для изменения настроек, продолжения или отмены.[0m"
%msg% " [36mSetting:[0m" " [36mНастройки:[0m"
if exist "%save%MySecurityDefaults.reg" (%msg% " [1;30m[2] Backup                                      [ ][0m" " [1;30m[2] Резервная копия                                     [ ][0m") else (
%ifNdef% NoBackup (%msg% " [[33m2[0m] Backup                                      [[32mV[0m]" " [[33m2[0m] Резервная копия                                     [[32mV[0m]") else (%msg% " [[33m2[0m] Backup                                      [[31mX[0m]" " [[33m2[0m] Резервная копия                                     [[31mX[0m]")
)
%ifNdef% NotDisableSecHealth (%msg% " [[33m3[0m] %dl% Security application                [[32mV[0m]" " [[33m3[0m] Отключить приложение Безопасность                   [[32mV[0m]") else (%msg% " [[33m3[0m] %dl% Security application                [[31mX[0m]"  " [[33m3[0m] Отключить приложение Безопасность                   [[31mX[0m]")
%ifNdef% NotDisableSecHealth (echo  [1;30m[4] -[0m) else (
%ifNdef% NotHideSystray (%msg% " [[33m4[0m] %dl% Security app tray icon              [[32mV[0m]" " [[33m4[0m] Отключить иконку в трее приложения Безопасность     [[32mV[0m]") else (%msg% " [[33m4[0m] %dl% Security app tray icon              [[31mX[0m]" " [[33m4[0m] Отключить иконку в трее приложения Безопасность     [[31mX[0m]")
)
%ifNdef% Services (echo  [1;30m[5] -[0m) else (%ifdef% NotDisableSecHealth (echo  [1;30m[5] -[0m) else (
	%ifNdef% NotDisableWscsvc (%msg% " [[33m5[0m] %dl% Security center service             [[32mV[0m]" " [[33m5[0m] Отключить службу центра безопасности                [[32mV[0m]") else (%msg% " [[33m5[0m] %dl% Security center service             [[31mX[0m]" " [[33m5[0m] Отключить службу центра безопасности                [[31mX[0m]")
))
set DefTamper=
(%rq% "HKLM\%smwd%\Features" /v "TamperProtection">nul 2>&1)&&((%rq% "HKLM\%smwd%\Features" /v "TamperProtection" 2>nul|%find% "0x4">nul 2>&1)&&set "DefTamper="||set DefTamper=1)||set "DefTamper="
set NewPlatform=
if exist "%ProgramData%\Microsoft\%wd%\Platform" for /d %%D in ("%ProgramData%\Microsoft\%wd%\Platform\*") do (if exist "%%D\MpCmdRun.exe" set NewPlatform=%%D)
%ifdef% DefTamper (echo  [1;30m[7] -[0m) else (
	%ifdef% UseReboot2Safe (%msg% " [[33m6[0m] Use reboot to Safe Mode                     [[32mV[0m]" " [[33m6[0m] Использовать перезагрузку в безопасный режим        [[32mV[0m]") else (%msg% " [[33m6[0m] Use reboot to Safe Mode                     [[31mX[0m]" " [[33m6[0m] Использовать перезагрузку в безопасный режим        [[31mX[0m]") 
)
%ifdef% DefTamper %ifNdef% TryBypassTamper (set "UseReboot2Safe=1"&set "NoReboot=")&goto :SkipRebootSetting
%ifdef% UseReboot2Safe (echo  [1;30m[7] -[0m) else (
	%ifNdef% NoReboot (%msg% " [[33m7[0m] Reboot after applying all                   [[32mV[0m]" " [[33m7[0m] Перезагрузится после применения всего               [[32mV[0m]") else (%msg% " [[33m7[0m] Reboot after applying all                   [[31mX[0m]" " [[33m7[0m] Перезагрузится после применения всего               [[31mX[0m]") 
)
:SkipRebootSetting
%ifNdef% PoliciesOnly (%ifNdef% NotCreateReDisablingTasks (%msg% " [[33m8[0m] Create tasks for re-disabling after updates [[32mV[0m]" " [[33m8[0m] Создать задания для переотключения после обновлений [[32mV[0m]") else (%msg% " [[33m8[0m] Create tasks for re-disabling after updates [[31mX[0m]" " [[33m8[0m] Создать задания для переотключения после обновлений [[31mX[0m]") )
call :CheckAV||%msg% " [4;1;33mFirst, disable the third-party antivirus manually if it is installed![0m" " [4;1;33mВначале отключите сторонний антивирус вручную, если он установлен![0m"
%ifdef% DefTamper (%msg% " [33mManually disable Tamper protection in setting[0m" " [33mВручную отключите Защиту от подделки в настройках[0m" 
				   %msg% " [33mfor applying script without restarting into Safe Mode.[0m" " [33mдля применения скрипта без перезагрузки в безопасный режим.[0m" 
				   %msg% " [[33mS[0m] Open Protection setting" " [[33mS[0m] Открыть настройки защиты")
set DefVBS=
set DefLsa=
set DefLsaLock=
set DefCred=
set DefCredLock=
set /a LockCount=0
(%rq% "HKLM\%sccd%\Scenarios\HypervisorEnforcedCodeIntegrity" /v "%el%d" 2>nul|%find% "0x1">nul 2>&1)&&set DefVBS=1||set DefVBS=
%ifdef% DefVBS (%rq% "HKLM\%sccd%\Scenarios\HypervisorEnforcedCodeIntegrity" /v "Locked" 2>nul|%find% "0x1">nul 2>&1)&&set DefVBSLock=1||set DefVBSLock=
(%rq% "HKLM\%scc%\Lsa" /v "RunAsPPLBoot" 2>nul|%find% "0x2">nul 2>&1)&&set DefLsa=1||set DefLsa=
(%rq% "HKLM\%scc%\Lsa" /v "RunAsPPL" 2>nul|%find% "0x2">nul 2>&1)&&set DefLsa=1
(%rq% "HKLM\%scc%\Lsa" /v "RunAsPPLBoot" 2>nul|%find% "0x1">nul 2>&1)&&set DefLsaLock=1||set DefLsaLock=
(%rq% "HKLM\%scc%\Lsa" /v "RunAsPPL" 2>nul|%find% "0x1">nul 2>&1)&&set DefLsaLock=1
(%rq% "HKLM\%spm%\Windows\System" /v "RunAsPPL" 2>nul|%find% "0x1">nul 2>&1)&&set DefLsaLock=1
(%rq% "HKLM\%scc%\CI\State">nul 2>&1)&&((%rq% "HKLM\%scc%\CI\State" /v "HVCI%el%d" 2>nul|%find% "0x1">nul 2>&1)&&set DefCred=1||set DefCred=)||set DefCred=
(%rq% "HKLM\%sccd%\Scenarios\KeyGuard\Status">nul 2>&1)&&((%rq% "HKLM\%sccd%\Scenarios\KeyGuard\Status" /v "CredGuard%el%d" 2>nul|%find% "0x1">nul 2>&1)&&set DefCred=1||set DefCred=)||set DefCred=
%ifdef% DefCred (%rq% "HKLM\%sccd%\Scenarios\HypervisorEnforcedCodeIntegrity" /v "Locked" 2>nul|%find% "0x1">nul 2>&1)&&set DefCredLock=1||set DefCredLock=
%ifdef% DefLsaLock set /a LockCount+=1
%ifdef% DefVBSLock set /a LockCount+=1 
%ifdef% DefCredLock set /a LockCount+=1
if %LockCount% gtr 0 (%msg% " [31mSome settings are locked in UEFI! Unlock them![0m" " [31mЧасть настроек заблокирована в UEFI! Разблокируйте их![0m" ) else (echo.)
set /a needecho=0
%ifNdef% SAFEBOOT_OPTION %ifdef% UseReboot2Safe (%msg% " [33mThe computer will be restarted [31mtwice[33m, to [31msafe mode[33m and back.[0m" " [33mКомпьютер будет перезагружен [31mдважды[33m, в [31mбезопасный режим[33m и обратно.[0m") else (set /a needecho+=1)
%ifNdef% UseReboot2Safe %ifNdef% NoReboot (%msg% " [33mThe computer will be restarted.[0m" " [33mКомпьютер будет перезагружен.[0m") else (set /a needecho+=1)
if %needecho% gtr 0 echo.
%msg% " [4;1;1mYou really want to %dl% Windows defenses?[0m [[32m1[0m] - [32mYes[0m [[31m0[0m] - [31mNo[0m" " [4;1;1mВы действительно хотите отключить защиты Windows?[0m   [[32m1[0m] - [32mДа[0m [[31m0[0m] - [31mНет[0m"
choice /C 012345678S /N >nul 2>&1
set "SubItem=%errorlevel%"
if [%SubItem%]==[1] goto :BEGIN
if not exist "%save%MySecurityDefaults.reg"                                            if [%SubItem%]==[3] (%ifNdef% NoBackup             (set NoBackup=1)             else (set NoBackup=))&goto :Warning
                                                                                       if [%SubItem%]==[4] (%ifNdef% NotDisableSecHealth  (set NotDisableSecHealth=1)  else (set NotDisableSecHealth=))&goto :Warning
%ifdef% NotDisableSecHealth                                                            if [%SubItem%]==[5] (%ifNdef% NotHideSystray       (set NotHideSystray=1)       else (set NotHideSystray=))&goto :Warning
%ifNdef% NotDisableSecHealth %ifdef% Services                                          if [%SubItem%]==[6] (%ifNdef% NotDisableWscsvc     (set NotDisableWscsvc=1)     else (set NotDisableWscsvc=))&goto :Warning
                                                                                       if [%SubItem%]==[7] (%ifNdef% UseReboot2Safe       (set UseReboot2Safe=1&set NoReboot=) else (set UseReboot2Safe=))&goto :Warning
								      %ifNdef% DefTamper       %ifNdef% UseReboot2Safe if [%SubItem%]==[8] (%ifNdef% NoReboot             (set NoReboot=1)                     else (set NoReboot=))&goto :Warning
																					   if [%SubItem%]==[9] (%ifNdef% NotCreateReDisablingTasks     (set NotCreateReDisablingTasks=1)     else (set NotCreateReDisablingTasks=))&goto :Warning
																					   if [%SubItem%]==[10] (start "" "windowsdefender://threatsettings"&set "UseReboot2Safe="&goto :BEGIN)
cls
exit /b

:WarnRestore
cls
%msg% " [32mRestore Defaults                                                                [0m" " [32mВосстановить по умолчанию                                                [0m"
echo.
%msg% " [36mAll settings and parameters affected by the script will be restored[0m" " [36mБудут восстановлены по умолчанию все настройки и параметры[0m"
%msg% " [36mto their default values.[0m" " [36mзатрагиваемые скриптом.[0m"
echo. 
if exist "%save%MySecurityDefaults.reg" (
%msg% " [1;30mMySecurityDefaults.reg has been detected and will be restored.[0m" " [1;30mОбнаружен MySecurityDefaults.reg, он будет восстановлен.[0m"
%msg% " [1;30mDelete MySecurityDefaults.reg and restart the script,[0m" " [1;30mУдалите MySecurityDefaults.reg и перезапустите скрипт,[0m"
%msg% " [1;30mif you don't want to restore it.[0m" " [1;30mесли не хотите восстанавливать его.[0m"
echo  [1;30m%save%[0m
echo.
)
%msg% " [1;30mUse the numbers on your keyboard to change settings, continue, or cancel.[0m" " [1;30mИспользуйте цифры на клавиатуре для изменения настроек, продолжения или отмены.[0m"
%ifdef% Reboot2Safe4Restore (%msg% " [[33m2[0m] Reboot into Safe Mode for restore* [[32mV[0m]" " [[33m2[0m] Перезагрузиться в безопасный для восстановления* [[32mV[0m]") else (%msg% " [[33m2[0m] Reboot into Safe Mode for restore* [[31mX[0m]" " [[33m2[0m] Перезагрузиться в безопасный для восстановления* [[31mX[0m]")
%ifNdef% Reboot2Safe4Restore (%ifNdef% NoReboot4Restore (%msg% " [[33m3[0m] Reboot after restore [[32mV[0m]" " [[33m3[0m] Перезагрузиться после восстановления* [[32mV[0m]") else (%msg% " [[33m3[0m] Reboot after restore [[31mX[0m]" " [[33m3[0m] Перезагрузиться после восстановления* [[31mX[0m]"))
%msg% " [1;30m*use it if defender services-drivers are active[0m" " [1;30m*используйте если службы-драйверы защитника активны[0m"
echo.
call :CheckAV||%msg% " [1;31mFirst, disable the third-party antivirus manually if it is installed![0m" " [1;31mВначале отключите сторонний антивирус вручную, если он установлен![0m"
%ifNdef% SAFEBOOT_OPTION %ifdef% Reboot2Safe4Restore %msg% " [33mThe computer will be restarted [31mtwice[33m, to [31msafe mode[33m and back.[0m" " [33mКомпьютер будет перезагружен [31mдважды[33m, в [31mбезопасный режим[33m и обратно.[0m"
%ifdef% SAFEBOOT_OPTION %ifdef% Reboot2Safe4Restore %msg% " [33mThe computer will be restarted.[0m" " [33mКомпьютер будет перезагружен.[0m"
echo.
%msg% " [[32m1[0m] - [32mYes[0m [[31m0[0m] - [31mNo[0m" " [[32m1[0m] - [32mДа[0m [[31m0[0m] - [31mНет[0m"
%ifNdef% Lang (choice /C 0123 /N /M "You really want to restored the default settings?") else (choice /C 0123 /N /M "Вы действительно хотите восстановить настройки по умолчанию?")
set "SubItem=%errorlevel%"
if [%SubItem%]==[1] goto :BEGIN
if [%SubItem%]==[3] (%ifNdef% Reboot2Safe4Restore (set Reboot2Safe4Restore=1) else (set Reboot2Safe4Restore=))&goto :WarnRestore
if [%SubItem%]==[4] (%ifNdef% NoReboot4Restore (set NoReboot4Restore=1) else (set NoReboot4Restore=))&goto :WarnRestore
cls
exit /b

:Reboot2Safe
%msg% "Preparing to reboot into safe mode..." "Подготовка к перезагрузке в безопасный режим..."
set "only=%~1"
%reg% copy "HKLM\%scc%\SafeBoot\Minimal\Win%df%" "HKLM\%scc%\SafeBoot\Minimal\Win%df%_off" /s /f>nul 2>&1
%rd% "HKLM\%scc%\SafeBoot\Minimal\Win%df%" /f>nul 2>&1
set "BootArgs=%args%"
%ifdef% Item set "BootArgs=apply %Item%"
%tk% /im mmc.exe /t /f>nul 2>&1
set "EventLog="
for /f "tokens=2*" %%a in ('%rq% "HKLM\%scc%\WMI\Autologger\EventLog-System\{555908d1-a6d7-4695-8e1e-26931d2012f4}" /v "%el%d" 2^>nul') do set "EventLog=%%b"
if [%EventLog%]==[0x1] %ra% "HKLM\%scc%\WMI\Autologger\EventLog-System\{555908d1-a6d7-4695-8e1e-26931d2012f4}" /v %el%d /t %dw% /d 0 /f>nul 2>&1
%ifdef% only goto :SkipService
echo using System; using System.Diagnostics; using System.ServiceProcess; namespace %ASN%WindowsService{public class %ASN%Service:ServiceBase{public %ASN%Service(){ServiceName = "%ASN% Service"; CanStop = true; AutoLog = false;} protected override void OnStart(string[] args){string %ASN% = @"/c "+'\u0022'+@"%sys%:\%ASN%Boot.cmd"+'\u0022'+" service";Process.Start("cmd.exe", %ASN%); this.Stop();}} class Program {static void Main() {ServiceBase.Run(new %ASN%Service());}}}>"%temp%\%ASN%.cs"
%csc% /out:"%sys%:\%ASN%.exe" "%temp%\%ASN%.cs">nul 2>&1
del /f /q "%temp%\%ASN%.cs">nul 2>&1
%sc% delete 0%ASN%>nul 2>&1
%sc% create 0%ASN% type= own start= auto error= ignore obj= "LocalSystem" binPath= "%sys%:\%ASN%.exe">nul 2>&1
%ra% "HKLM\%scc%\SafeBoot\Minimal\0%ASN%" /ve /t REG_SZ /d "Service" /f>nul 2>&1
:SkipService
call :SafeBoot %only%
%ra% "HKLM\%smw%\%cv%\RunOnce" /v "*%ASN%" /t %sz% /d "cmd.exe /c \"%sys%:\%ASN%Boot.cmd\"" /f>nul 2>&1
%ifNdef% only %ra% %ASR% /v "Save" /t %sz% /d "%save%\" /f >nul 2>&1
%ifNdef% only %ra% %ASR% /v "Name" /t %sz% /d "%ASN%" /f >nul 2>&1
%ifNdef% only %ifdef% NotDisableSecHealth %ra% %ASR% /v "NotDisableSecHealth" /t %sz% /d "1" /f >nul 2>&1
%ifNdef% only %ifdef% NotHideSystray %ra% %ASR% /v "NotHideSystray" /t %sz% /d "1" /f >nul 2>&1
%ifNdef% only %ifdef% NotDisableWscsvc %ra% %ASR% /v "NotDisableWscsvc" /t %sz% /d "1" /f >nul 2>&1
%ifNdef% only %ifdef% DisableCIPolicies %ra% %ASR% /v "DisableCIPolicies" /t %sz% /d "1" /f >nul 2>&1
%ifNdef% only %ifdef% DisablePkcsPolicies %ra% %ASR% /v "DisablePkcsPolicies" /t %sz% /d "1" /f >nul 2>&1
%ifNdef% only %ifdef% UseReboot2Safe %ra% %ASR% /v "UseReboot2Safe" /t %sz% /d "1" /f >nul 2>&1
%ifNdef% only %ifdef% Reboot2Safe4Restore %ra% %ASR% /v "Reboot2Safe4Restore" /t %sz% /d "1" /f >nul 2>&1
%ifNdef% only %ifdef% NoReboot4Restore %ra% %ASR% /v "NoReboot4Restore" /t %sz% /d "1" /f >nul 2>&1
%manage-bde% -protectors %sys%: -%dl% -rebootcount 1 >nul 2>&1
%msg% "The computer will now reboot into safe mode." "Компьютер сейчас перезагрузиться в безопасный режим."
%ifNdef% Lang (%shutdown% /r /f /t 3 /c "Reboot into safe mode") else (%shutdown% /r /f /t 3 /c "Перезагрузка в безопасный режим")
%timeout% /t 4
exit

:SafeBoot
set "only=%~1"
del /f /q "%sys%:\%ASN%Boot.cmd">nul 2>&1
(%rq% "HKLM\%scc%\SafeBoot\Minimal\Win%df%">nul 2>&1) && (set win%df%=1)
set boottimeout=30
set displaybootmenu=
for /f "tokens=2" %%t in ('%bcdedit% /enum {bootmgr} ^| %find% "timeout"') do set "boottimeout=%%t"
for /f "tokens=2" %%t in ('%bcdedit% /enum {bootmgr} ^| %find% "displaybootmenu"') do set "displaybootmenu=%%t"
for /f "tokens=2" %%t in ('%bcdedit% /v ^| %find% "default"') do set "default=%%t"
for /f "tokens=2 delims={}" %%a in ('%bcdedit% /copy {current} /d "Safe Mode" ^| %find% "{"') do set guid=%%a
%ifNdef% guid for /f "tokens=2 delims={}" %%a in ('%bcdedit% /copy {default} /d "Safe Mode" ^| %find% "{"') do set guid=%%a
%bcdedit% /timeout "2" >nul 2>&1
%bcdedit% /set {bootmgr} displaybootmenu Yes>nul 2>&1
set asrX=
set asrY=
set asrZ=
%rq% "HKLM\%smwd%\%wd% Exploit Guard\ASR\Rules" /v "33ddedf1-c6e0-47cb-833e-de6133960387" >nul 2>&1&&for /f "tokens=2*" %%a in ('%rq% "HKLM\%smwd%\%wd% Exploit Guard\ASR\Rules" /v "33ddedf1-c6e0-47cb-833e-de6133960387" 2^>nul') do (set "asrX=%%b")
%rq% "HKLM\%spmwd%\%wd% Exploit Guard\ASR\Rules" /v "33ddedf1-c6e0-47cb-833e-de6133960387" >nul 2>&1&&for /f "tokens=2*" %%a in ('%rq% "HKLM\%spmwd%\%wd% Exploit Guard\ASR\Rules" /v "33ddedf1-c6e0-47cb-833e-de6133960387" 2^>nul') do (set "asrY=%%b")
%ifdef% asrX set "asrX=%asrX:0x=%"
%ifdef% asrY set "asrY=%asrY:0x=%"
if "%asrX%"=="1" set asrZ=1&if "%asrY%"=="1" set asrZ=1
%ifNdef% asrZ goto :SkipASRsafe
%msg% "Disabling blocking ASR rule..." "Отключение блокирующего ASR правила..."
call :ApplyPol
echo %spmwd%\%wd% Exploit Guard\ASR\Rules;33ddedf1-c6e0-47cb-833e-de6133960387;SZ;^0>"%temp%\%ASN%asr.txt"
echo %smwd%\%wd% Exploit Guard\ASR\Rules;33ddedf1-c6e0-47cb-833e-de6133960387;SZ;^0>>"%temp%\%ASN%asr.txt"
set PolWork=Add&set "PolIn=%temp%\%ASN%asr.txt"&set "PolOut=%sysdir%GroupPolicy\Machine\Registry.pol"
chcp 437 >nul 2>&1&%powershell% -MTA -NoP -NoL -NonI -EP Bypass -f "%temp%\%ASN%pol.ps1">nul 2>&1&chcp 65001 >nul 2>&1
"%gpupdate%" /force>nul 2>&1
set PolWork=Del&set "PolIn=%temp%\%ASN%asr.txt"&set "PolOut=%sysdir%GroupPolicy\Machine\Registry.pol"
chcp 437 >nul 2>&1&%powershell% -MTA -NoP -NoL -NonI -EP Bypass -f "%temp%\%ASN%pol.ps1">nul 2>&1&chcp 65001 >nul 2>&1
del /f /q "%temp%\%ASN%pol.ps1">nul 2>&1
del /f /q "%temp%\%ASN%asr.txt">nul 2>&1
if "%asrX%"=="1" chcp 437 >nul 2>&1&	%powershell% -MTA -NoP -NoL -NonI -EP Bypass -c "%sp% -AttackSurfaceReductionRules_Ids 33ddedf1-c6e0-47cb-833e-de6133960387 -AttackSurfaceReductionRules_Actions Disabled">nul 2>&1&chcp 65001 >nul 2>&1
%rd% "HKLM\%smwd%\%wd% Exploit Guard\ASR\Rules" /v "33ddedf1-c6e0-47cb-833e-de6133960387" /f >nul 2>&1
:SkipASRsafe
call :CheckAV&&goto :SkipSendWait
%bcdedit% /v|%find% "safeboot">nul 2>&1&&goto :SafeOK||(chcp 437 >nul 2>&1&%powershell% -NoP -EP Bypass -c "Add-Type -AssemblyName System.Windows.Forms; $command = 'bcdedit /set {{}%guid%{}} bootmenupolicy Legacy&bcdedit /set {{}%guid%{}} hypervisorlaunchtype off&bcdedit /set {{}%guid%{}} safeboot minimal&&bcdedit /default {{}%guid%{}}&exit'; $p = Start-Process -FilePath 'cmd.exe' -PassThru -ErrorAction Ignore; if (!$p -or $p.HasExited) { exit }; $i=0; while ($p.MainWindowHandle -eq 0 -and !$p.HasExited -and $i -lt 40) { Start-Sleep -m 50; $p.Refresh(); $i++ }; if ($p.MainWindowHandle -eq 0 -or $p.HasExited) { exit }; $wsh = New-Object -ComObject WScript.Shell; $null = $wsh.AppActivate($p.Id); [System.Windows.Forms.SendKeys]::SendWait($command); [System.Windows.Forms.SendKeys]::SendWait('{ENTER}');  $null = $p.WaitForExit(2000)">nul 2>&1&chcp 65001 >nul 2>&1)
:SkipSendWait
%bcdedit% /v|%find% "safeboot">nul 2>&1&&goto :SafeOK||(%bcdedit% /set {%guid%} bootmenupolicy Legacy>nul 2>&1
														%bcdedit% /set {%guid%} hypervisorlaunchtype off>nul 2>&1
														%schtasks% /create /tn "SafebootTemp" /tr "cmd /c bcdedit /set {%guid%} safeboot minimal&bcdedit /default {%guid%}&exit" /sc once /st 00:00 /ru "NT SERVICE\TrustedInstaller" /rl HIGHEST /f>nul 2>&1
														%schtasks% /run /tn "SafebootTemp">nul 2>&1
														%timeout% /T 1 /nobreak >nul 2>&1
														%schtasks% /delete /tn "SafebootTemp" /f >nul 2>&1)
%bcdedit% /v|%find% "safeboot">nul 2>&1&&goto :SafeOK||call :TrustedRun 5
%bcdedit% /v|%find% "safeboot">nul 2>&1&&goto :SafeOK||%bcdedit% /set {%guid%} safeboot minimal
%bcdedit% /v|%find% "safeboot">nul 2>&1&&goto :SafeOK||call :SafeFail
:SafeOK
echo ^@echo off>"%sys%:\%ASN%Boot.cmd"
echo chcp 65001^>nul 2^>^&^1>>"%sys%:\%ASN%Boot.cmd"
copy /y "%Script%" "%ScriptC%">nul 2>&1
%ifNdef% only echo if defined SAFEBOOT_OPTION start ^"^" ^"%ScriptC%^" %BootArgs% >>"%sys%:\%ASN%Boot.cmd"
%ifNdef% only echo if ^"%%~1^"=="service" reg add "HKLM\%smw%\%cv%\RunOnce" /v "*%ASN%" /t %sz% /d "cmd.exe /c \"%sys%:\%ASN%Wait.cmd\"" /f^&goto :RestoreBoot>>"%sys%:\%ASN%Boot.cmd"
echo sc stop 0%ASN%^>nul 2^>^&^1>>"%sys%:\%ASN%Boot.cmd"
echo taskkill /im %ASN%.exe /f^>nul 2^>^&^1>>"%sys%:\%ASN%Boot.cmd"
echo sc delete 0%ASN%^>nul 2^>^&^1>>"%sys%:\%ASN%Boot.cmd"
echo :RestoreBoot>>"%sys%:\%ASN%Boot.cmd"
echo bcdedit /timeout "%boottimeout%" >>"%sys%:\%ASN%Boot.cmd"
%ifdef% displaybootmenu echo bcdedit /set {bootmgr} displaybootmenu %displaybootmenu% >>"%sys%:\%ASN%Boot.cmd"
%ifNdef% displaybootmenu echo bcdedit /deletevalue {bootmgr} displaybootmenu >>"%sys%:\%ASN%Boot.cmd"
%ifdef% default echo bcdedit /default %default% >>"%sys%:\%ASN%Boot.cmd"
echo bcdedit /delete {%guid%}^|^|%powershell% -MTA -NoP -NoL -NonI -EP Bypass -c "$GUID = ((bcdedit /v | Out-String) -split '\r?\n\r?\n' | Where-Object { $_ -match 'description\s+safe mode' } | ForEach-Object { ([regex]::Match($_, '{[a-f0-9-]+}')).Value }); if ($GUID) { bcdedit /delete $GUID /f }">>"%sys%:\%ASN%Boot.cmd"
echo reg delete "HKLM\%scs%\0%ASN%" /f>>"%sys%:\%ASN%Boot.cmd"
echo reg delete "HKLM\%scc%\SafeBoot\Minimal\0%ASN%" /f>>"%sys%:\%ASN%Boot.cmd"
%ifdef% win%df% (
	%reg% copy "HKLM\%scc%\SafeBoot\Minimal\Win%df%" "HKLM\%scc%\SafeBoot\Minimal\Win%df%_off" /s /f>nul 2>&1
	%rd% "HKLM\%scc%\SafeBoot\Minimal\Win%df%" /f>nul 2>&1
	%ifdef% only echo reg copy "HKLM\%scc%\SafeBoot\Minimal\Win%df%_off" "HKLM\%scc%\SafeBoot\Minimal\Win%df%" /s /f>>"%sys%:\%ASN%Boot.cmd"
	%ifdef% only echo reg delete "HKLM\%scc%\SafeBoot\Minimal\Win%df%_off" /f>>"%sys%:\%ASN%Boot.cmd"
)
if [%EventLog%]==[0x1] echo reg add "HKLM\%scc%\WMI\Autologger\EventLog-System\{555908d1-a6d7-4695-8e1e-26931d2012f4}" /v %el%d /t %dw% /d 1 /f >>"%sys%:\%ASN%Boot.cmd"
%ifdef% only goto :SkipWaitCmd
echo ^@echo off>>"%sys%:\%ASN%Wait.cmd"
echo chcp 65001 ^>nul>>"%sys%:\%ASN%Wait.cmd"
echo del /f /q ^"%sys%:\%ASN%Boot.cmd^">>"%sys%:\%ASN%Wait.cmd"
%ifNdef% Lang (echo title WAIT>>"%sys%:\%ASN%Wait.cmd")  else (echo title Ждите>>"%sys%:\%ASN%Wait.cmd")
echo :StartWait>>"%sys%:\%ASN%Wait.cmd"
echo cls>>"%sys%:\%ASN%Wait.cmd"
%ifNdef% Lang (echo echo Please wait...>>"%sys%:\%ASN%Wait.cmd") else (echo echo Пожалуйста ожидайте...>>"%sys%:\%ASN%Wait.cmd")
echo echo.>>"%sys%:\%ASN%Wait.cmd"
echo if exist "%sys%:\%AS%.log" type "%sys%:\%AS%.log">>"%sys%:\%ASN%Wait.cmd"
echo for /f %%%%a in ('tasklist /fi "imagename eq cmd.exe" ^^^| find /c "cmd.exe"') do set count=%%%%a>>"%sys%:\%ASN%Wait.cmd"
echo if %%count%% lss 3 ( >>"%sys%:\%ASN%Wait.cmd"
echo timeout /t 3 /nobreak ^>nul>>"%sys%:\%ASN%Wait.cmd"
echo cls>>"%sys%:\%ASN%Wait.cmd"
%ifNdef% Lang (echo echo Something went wrong...>>"%sys%:\%ASN%Wait.cmd") else (echo echo Что-то пошло не так...>>"%sys%:\%ASN%Wait.cmd")
%ifNdef% Lang (echo echo Reboot after 5 sec...>>"%sys%:\%ASN%Wait.cmd") else (echo echo Перезагрузка через 5 сек...>>"%sys%:\%ASN%Wait.cmd")
%ifNdef% Lang (echo echo Something went wrong...^>^>^"%sys%:\%AS%.log^">>"%sys%:\%ASN%Wait.cmd") else (echo echo Что-то пошло не так...^>^>^"%sys%:\%AS%.log^">>"%sys%:\%ASN%Wait.cmd")
echo timeout /t 5 /nobreak ^>nul>>"%sys%:\%ASN%Wait.cmd"
echo shutdown /r /f /t 1 >>"%sys%:\%ASN%Wait.cmd"
echo del /f /q ^"%sys%:\%ASN%.exe^">>"%sys%:\%ASN%Wait.cmd"
echo del /f /q ^"%sys%:\%ASN%Boot.cmd^">>"%sys%:\%ASN%Wait.cmd"
echo del /f /q ^"%sys%:\%ASN%Wait.cmd^">>"%sys%:\%ASN%Wait.cmd"
echo del /f /q ^"%sys%:\%ASN%.cmd^">>"%sys%:\%ASN%Wait.cmd"
echo ) >>"%sys%:\%ASN%Wait.cmd"
echo timeout /T 1 /nobreak ^>nul>>"%sys%:\%ASN%Wait.cmd"
echo goto :StartWait>>"%sys%:\%ASN%Wait.cmd"
:SkipWaitCmd
echo del /f /q ^"%sys%:\%ASN%.exe^">>"%sys%:\%ASN%Boot.cmd"
echo if ^"%%~1^"=="service" del /f /q ^"%sys%:\%ASN%Boot.cmd^"^&exit>>"%sys%:\%ASN%Boot.cmd"
%ifdef% only echo del /f /q ^"%sys%:\%ASN%Boot.cmd^"^&exit>>"%sys%:\%ASN%Boot.cmd"
echo title Helper>>"%sys%:\%ASN%Boot.cmd"
echo :StartWait>>"%sys%:\%ASN%Boot.cmd"
echo cls>>"%sys%:\%ASN%Boot.cmd"
%ifNdef% Lang (echo echo The main script is running...>>"%sys%:\%ASN%Boot.cmd") else (echo echo Основной скрипт выполняется...>>"%sys%:\%ASN%Boot.cmd")
%ifNdef% Lang (echo echo Do not close this window>>"%sys%:\%ASN%Boot.cmd") else (echo echo Не закрывайте это окно>>"%sys%:\%ASN%Boot.cmd")
echo for /f %%%%a in ('tasklist /fi "imagename eq cmd.exe" ^^^| find /c "cmd.exe"') do set count=%%%%a>>"%sys%:\%ASN%Boot.cmd"
echo if %%count%% lss 3 ( >>"%sys%:\%ASN%Boot.cmd"
echo timeout /t 3 /nobreak ^>nul>>"%sys%:\%ASN%Boot.cmd"
echo cls>>"%sys%:\%ASN%Boot.cmd"
%ifNdef% Lang (echo echo Something went wrong...>>"%sys%:\%ASN%Boot.cmd") else (echo echo Что-то пошло не так...>>"%sys%:\%ASN%Boot.cmd")
%ifNdef% Lang (echo echo Reboot after 5 sec...>>"%sys%:\%ASN%Boot.cmd") else (echo echo Перезагрузка через 5 сек...>>"%sys%:\%ASN%Boot.cmd")
%ifNdef% Lang (echo echo Something went wrong...^>^>^"%sys%:\%AS%.log^">>"%sys%:\%ASN%Boot.cmd") else (echo echo Что-то пошло не так...^>^>^"%sys%:\%AS%.log^">>"%sys%:\%ASN%Boot.cmd")
echo timeout /t 5 /nobreak ^>nul>>"%sys%:\%ASN%Boot.cmd"
echo shutdown /r /f /t 1 >>"%sys%:\%ASN%Boot.cmd"
echo del /f /q ^"%sys%:\%ASN%.exe^">>"%sys%:\%ASN%Boot.cmd"
echo del /f /q ^"%sys%:\%ASN%Boot.cmd^">>"%sys%:\%ASN%Boot.cmd"
echo del /f /q ^"%sys%:\%ASN%Wait.cmd^">>"%sys%:\%ASN%Boot.cmd"
echo ) >>"%sys%:\%ASN%Boot.cmd"
echo timeout /T 1 /nobreak ^>nul>>"%sys%:\%ASN%Boot.cmd"
echo goto :StartWait>>"%sys%:\%ASN%Boot.cmd"
exit /b

:SafeFail
chcp 65001 >nul 2>&1
del /f /q "%sys%:\%ASN%Boot.cmd">nul 2>&1
%bcdedit% /delete {%guid%}>nul 2>&1
%bcdedit% /timeout "%boottimeout%">nul 2>&1
%ifdef% displaybootmenu %bcdedit% /set {bootmgr} displaybootmenu %displaybootmenu%>nul 2>&1
%err% "Error enabling reboot in safe mode" "Ошибка включения перезагрузки в безопасный режим"
exit

:Reboot2Normal
%msg% "The computer will now reboot." "Компьютер сейчас перезагрузиться."
del /f /q "%sys%:\%AS%.log">nul 2>&1
del /f /q "%sys%:\%ASN%Wait.cmd">nul 2>&1
del /f /q "%sys%:\%ASN%Boot.cmd">nul 2>&1
del /f /q "%sys%:\%ASN%.exe">nul 2>&1
%rd% %ASR% /f >nul 2>&1
%rd% "HKLM\%smw%\%cv%\RunOnce" /v "*%ASN%" /f >nul 2>&1
%ifdef% SAFEBOOT_OPTION del /f /q "%sys%:\%ASN%.cmd">nul 2>&1&%shutdown% /r /f /t 0
%ifNdef% SAFEBOOT_OPTION %shutdown% /r /f /t 3 /c "Reboot"
%timeout% /t 4
exit

:TrustedRun
%msg% "Getting Trusted Installer privileges..." "Получение привилегий Trusted Installer..."
%sc% config "TrustedInstaller" start= demand>nul 2>&1
%sc% start "TrustedInstaller">nul 2>&1
del /f /q "%temp%\%ASN%TI.ps1">nul 2>&1
chcp 437 >nul 2>&1
%powershell% -MTA -NoP -NoL -NonI -EP Bypass -c "$null|Out-File -FilePath '%temp%\%ASN%TI.ps1' -Encoding UTF8">nul 2>&1
chcp 65001 >nul 2>&1
if "%~1"=="" echo $AppFullPath=[System.Environment]::GetEnvironmentVariable('runasti')>>"%temp%\%ASN%TI.ps1"
if "%~1"=="1" echo $AppFullPath='"%Script%" %args%'>>"%temp%\%ASN%TI.ps1"
if "%~1"=="2" echo $AppFullPath='%cmd%'>>"%temp%\%ASN%TI.ps1"
if "%~1"=="3" echo $AppFullPath='powershell.exe -MTA -NoP -NoL -NonI -EP Bypass'>>"%temp%\%ASN%TI.ps1"
if "%~1"=="4" echo $AppFullPath='%sys%:\windows\regedit.exe'>>"%temp%\%ASN%TI.ps1"
if "%~1"=="5" echo $AppFullPath='powershell -EP Bypass  -EncodedCommand dAByAHkAewBBAGQAZAAtAFQAeQBwAGUAIAAoACcAdQBzAGkAbgBnACAAUwB5AHMAdABlAG0AOwB1AHMAaQBuAGcAIABTAHkAcwB0AGUAbQAuAFIAdQBuAHQAaQBtAGUALgBJAG4AdABlAHIAbwBwAFMAZQByAHYAaQBjAGUAcwA7AHAAdQBiAGwAaQBjACAAYwBsAGEAcwBzACAAQgB7AFsARABsAGwASQBtAHAAbwByAHQAKAAjACkAXQBwAHUAYgBsAGkAYwAgAHMAdABhAHQAaQBjACAAZQB4AHQAZQByAG4AIABpAG4AdAAgAEIAYwBkAE8AcABlAG4AUwB5AHMAdABlAG0AUwB0AG8AcgBlACgAbwB1AHQAIABJAG4AdABQAHQAcgAgAHMAKQA7AFsARABsAGwASQBtAHAAbwByAHQAKAAjACkAXQBwAHUAYgBsAGkAYwAgAHMAdABhAHQAaQBjACAAZQB4AHQAZQByAG4AIABpAG4AdAAgAEIAYwBkAE8AcABlAG4ATwBiAGoAZQBjAHQAKABJAG4AdABQAHQAcgAgAHMALAByAGUAZgAgAEcAdQBpAGQAIABpACwAbwB1AHQAIABJAG4AdABQAHQAcgAgAG8AKQA7AFsARABsAGwASQBtAHAAbwByAHQAKAAjACkAXQBwAHUAYgBsAGkAYwAgAHMAdABhAHQAaQBjACAAZQB4AHQAZQByAG4AIABpAG4AdAAgAEIAYwBkAFMAZQB0AEUAbABlAG0AZQBuAHQARABhAHQAYQAoAEkAbgB0AFAAdAByACAAbwAsAHUAaQBuAHQAIABlACwAYgB5AHQAZQBbAF0AIABiACwAaQBuAHQAIAB6ACkAOwBbAEQAbABsAEkAbQBwAG8AcgB0ACgAIwApAF0AcAB1AGIAbABpAGMAIABzAHQAYQB0AGkAYwAgAGUAeAB0AGUAcgBuACAAaQBuAHQAIABCAGMAZABGAGwAdQBzAGgAUwB0AG8AcgBlACgASQBuAHQAUAB0AHIAIABzACkAOwB9ACcALgBSAGUAcABsAGEAYwBlACgAJwAjACcALABbAGMAaABhAHIAXQAzADQAKwAnAGIAYwBkAC4AZABsAGwAJwArAFsAYwBoAGEAcgBdADMANAApACkAOwAkAGcAPQBbAEcAdQBpAGQAXQAkAGUAbgB2ADoAZwB1AGkAZAA7ACQAYgBtAD0AWwBHAHUAaQBkAF0AJwA5AGQAZQBhADgANgAyAGMALQA1AGMAZABkAC0ANABlADcAMAAtAGEAYwBjADEALQBmADMAMgBiADMANAA0AGQANAA3ADkANQAnADsAJABzAD0AJABvAD0AJABtAD0AWwBJAG4AdABQAHQAcgBdADAAOwAkAGIAPQBbAGIAeQB0AGUAWwBdAF0AOgA6AG4AZQB3ACgAOAApADsAaQBmACgAWwBCAF0AOgA6AEIAYwBkAE8AcABlAG4AUwB5AHMAdABlAG0AUwB0AG8AcgBlACgAWwByAGUAZgBdACQAcwApAC0AbwByAFsAQgBdADoAOgBCAGMAZABPAHAAZQBuAE8AYgBqAGUAYwB0ACgAJABzACwAWwByAGUAZgBdACQAZwAsAFsAcgBlAGYAXQAkAG8AKQAtAG8AcgBbAEIAXQA6ADoAQgBjAGQAUwBlAHQARQBsAGUAbQBlAG4AdABEAGEAdABhACgAJABvACwAMAB4ADIANQAwADAAMAAwAEMAMgAsACQAYgAsADgAKQAtAG8AcgBbAEIAXQA6ADoAQgBjAGQAUwBlAHQARQBsAGUAbQBlAG4AdABEAGEAdABhACgAJABvACwAMAB4ADIANQAwADAAMAAwAEYAMAAsACQAYgAsADgAKQAtAG8AcgBbAEIAXQA6ADoAQgBjAGQATwBwAGUAbgBPAGIAagBlAGMAdAAoACQAcwAsAFsAcgBlAGYAXQAkAGIAbQAsAFsAcgBlAGYAXQAkAG0AKQAtAG8AcgBbAEIAXQA6ADoAQgBjAGQAUwBlAHQARQBsAGUAbQBlAG4AdABEAGEAdABhACgAJABtACwAMAB4ADIAMwAwADAAMAAwADAAMwAsACQAZwAuAFQAbwBCAHkAdABlAEEAcgByAGEAeQAoACkALAAxADYAKQAtAG8AcgBbAEIAXQA6ADoAQgBjAGQAUwBlAHQARQBsAGUAbQBlAG4AdABEAGEAdABhACgAJABvACwAMAB4ADIANQAwADAAMAAwADgAMAAsACQAYgAsADgAKQAtAG8AcgBbAEIAXQA6ADoAQgBjAGQARgBsAHUAcwBoAFMAdABvAHIAZQAoACQAcwApACkAewBlAHgAaQB0ACAAMQB9AH0AYwBhAHQAYwBoAHsAZQB4AGkAdAAgADEAfQA='>>"%temp%\%ASN%TI.ps1"
echo [string]$GetTokenAPI=@'>>"%temp%\%ASN%TI.ps1"
echo using System;using System.Diagnostics;using System.Runtime.InteropServices;using System.Security.Principal;using System.Text;namespace WinAPI{internal static class WinBase{[StructLayout(LayoutKind.Sequential,CharSet=CharSet.Unicode)]internal struct STARTUPINFO{public Int32 cb;public string lpReserved;public string lpDesktop;public string lpTitle;public uint dwX;public uint dwY;public uint dwXSize;public uint dwYSize;public uint dwXCountChars;public uint dwYCountChars;public uint dwFillAttribute;public uint dwFlags;public Int16 wShowWindow;public Int16 cbReserved2;public IntPtr lpReserved2;public IntPtr hStdInput;public IntPtr hStdOutput;public IntPtr hStdError;}[StructLayout(LayoutKind.Sequential)]internal struct PROCESS_INFORMATION{public IntPtr hProcess;public IntPtr hThread;public uint dwProcessId;public uint dwThreadId;}}>>"%temp%\%ASN%TI.ps1"
echo internal static class WinNT{[StructLayout(LayoutKind.Sequential,Pack=1)]internal struct TokPriv1Luid{public uint PrivilegeCount;public long Luid;public UInt32 Attributes;}}internal static class Advapi32{[DllImport("advapi32.dll",SetLastError=true)]public static extern bool OpenProcessToken(IntPtr ProcessHandle,UInt32 DesiredAccess,out IntPtr TokenHandle);[DllImport("advapi32.dll",SetLastError=true,CharSet=CharSet.Auto)]public extern static bool DuplicateTokenEx(IntPtr hExistingToken,uint dwDesiredAccess,IntPtr lpTokenAttributes,uint ImpersonationLevel,uint TokenType,out IntPtr phNewToken);>>"%temp%\%ASN%TI.ps1"
echo [DllImport("advapi32.dll",SetLastError=true,CharSet=CharSet.Auto)]internal static extern bool LookupPrivilegeValue(string lpSystemName,string lpName,ref long lpLuid);[DllImport("advapi32.dll",SetLastError=true)]internal static extern bool AdjustTokenPrivileges(IntPtr TokenHandle,bool DisableAllPrivileges,ref WinNT.TokPriv1Luid NewState,UInt32 Zero,IntPtr Null1,IntPtr Null2);[DllImport("advapi32.dll",SetLastError=true,CharSet=CharSet.Unicode)]public static extern bool CreateProcessAsUserW(IntPtr hToken,string lpApplicationName,string lpCommandLine,IntPtr lpProcessAttributes,IntPtr lpThreadAttributes,bool bInheritHandles,uint dwCreationFlags,IntPtr lpEnvironment,string lpCurrentDirectory,ref WinBase.STARTUPINFO lpStartupInfo,out WinBase.PROCESS_INFORMATION lpProcessInformation);>>"%temp%\%ASN%TI.ps1"
echo [DllImport("advapi32.dll",SetLastError=true,CharSet=CharSet.Unicode)]public static extern bool CreateProcessWithTokenW(IntPtr hToken,uint dwLogonFlags,string lpApplicationName,string lpCommandLine,uint dwCreationFlags,IntPtr lpEnvironment,string lpCurrentDirectory,ref WinBase.STARTUPINFO lpStartupInfo,out WinBase.PROCESS_INFORMATION lpProcessInformation);[DllImport("advapi32.dll",SetLastError=true)]public static extern bool SetTokenInformation(IntPtr TokenHandle,uint TokenInformationClass,ref IntPtr TokenInformation,int TokenInformationLength);[DllImport("advapi32.dll",SetLastError=true)]public static extern bool RevertToSelf();}>>"%temp%\%ASN%TI.ps1"
echo internal static class Kernel32{[DllImport("kernel32.dll",SetLastError=true)]public static extern IntPtr OpenProcess(uint processAccess,bool bInheritHandle,int processId);[DllImport("kernel32.dll",SetLastError=true)]public static extern bool CloseHandle(IntPtr hObject);[DllImport("kernel32.dll",SetLastError=true)]public static extern IntPtr GetCurrentProcess();}internal static class Userenv{[DllImport("userenv.dll",SetLastError=true)]public static extern bool CreateEnvironmentBlock(ref IntPtr lpEnvironment,IntPtr hToken,bool bInherit);}>>"%temp%\%ASN%TI.ps1"
echo public static class ProcessConfig{private enum P{SeAssignPrimaryTokenPrivilege,SeBackupPrivilege,SeIncreaseQuotaPrivilege,SeLoadDriverPrivilege,SeManageVolumePrivilege,SeRestorePrivilege,SeSecurityPrivilege,SeShutdownPrivilege,SeSystemEnvironmentPrivilege,SeSystemTimePrivilege,SeTakeOwnershipPrivilege,SeTrustedCredmanAccessPrivilege,SeUndockPrivilege,SeDebugPrivilege,SeImpersonatePrivilege,SeTcbPrivilege};private static void EnablePrivs(IntPtr h){WinNT.TokPriv1Luid tp;tp.PrivilegeCount=1;tp.Luid=0;tp.Attributes=2;try{foreach(string p in Enum.GetNames(typeof(P))){if(Advapi32.LookupPrivilegeValue(null,p,ref tp.Luid))Advapi32.AdjustTokenPrivileges(h,false,ref tp,0,IntPtr.Zero,IntPtr.Zero);}}catch{}}>>"%temp%\%ASN%TI.ps1"
echo private static IntPtr GetTok(int pid){IntPtr hDup=IntPtr.Zero;IntPtr hProc=Kernel32.OpenProcess(0x1000,false,pid);if(hProc!=IntPtr.Zero){IntPtr hTok;if(Advapi32.OpenProcessToken(hProc,0x000A,out hTok)){if(!Advapi32.DuplicateTokenEx(hTok,0xF01FF,IntPtr.Zero,2,1,out hDup))Advapi32.DuplicateTokenEx(hTok,0xF01FF,IntPtr.Zero,3,1,out hDup);Kernel32.CloseHandle(hTok);}Kernel32.CloseHandle(hProc);}return hDup;}>>"%temp%\%ASN%TI.ps1"
echo public static StructOut Run(string cmd){uint err=0;IntPtr hSys=IntPtr.Zero;IntPtr hTI=IntPtr.Zero;IntPtr hCur;if(Advapi32.OpenProcessToken(Kernel32.GetCurrentProcess(),0x0028,out hCur)){EnablePrivs(hCur);Kernel32.CloseHandle(hCur);}string wl=Encoding.UTF8.GetString(new byte[]{119,105,110,108,111,103,111,110});string ti=Encoding.UTF8.GetString(new byte[]{84,114,117,115,116,101,100,73,110,115,116,97,108,108,101,114});Process[] procs=Process.GetProcessesByName(wl);if(procs.Length^>0)hSys=GetTok(procs[0].Id);if(hSys==IntPtr.Zero){foreach(Process p in Process.GetProcesses()){if(p.Id^<=4)continue;IntPtr tmp=GetTok(p.Id);if(tmp!=IntPtr.Zero){try{using(WindowsIdentity id=new WindowsIdentity(tmp)){if(id.IsSystem){hSys=tmp;break;}}}catch{}if(hSys==IntPtr.Zero)Kernel32.CloseHandle(tmp);}}}>>"%temp%\%ASN%TI.ps1"
echo if(hSys==IntPtr.Zero)return new StructOut{ExitCode=1};try{WindowsIdentity.Impersonate(hSys);}catch{}Process[] tiProcs=Process.GetProcessesByName(ti);if(tiProcs.Length^>0)hTI=GetTok(tiProcs[0].Id);try{Advapi32.RevertToSelf();}catch{}IntPtr hFinal=(hTI!=IntPtr.Zero)?hTI:hSys;if(hTI!=IntPtr.Zero^&^&hSys!=IntPtr.Zero)Kernel32.CloseHandle(hSys);EnablePrivs(hFinal);try{WindowsIdentity.Impersonate(hFinal);}catch{}IntPtr sid=new IntPtr(Process.GetCurrentProcess().SessionId);Advapi32.SetTokenInformation(hFinal,12,ref sid,4);>>"%temp%\%ASN%TI.ps1"
echo WinBase.PROCESS_INFORMATION pi=new WinBase.PROCESS_INFORMATION();IntPtr env=IntPtr.Zero;Userenv.CreateEnvironmentBlock(ref env,hFinal,true);WinBase.STARTUPINFO si=new WinBase.STARTUPINFO();si.cb=Marshal.SizeOf(si);si.lpDesktop="winsta0\\default";si.dwFlags=1;si.wShowWindow=5;if(!Advapi32.CreateProcessAsUserW(hFinal,null,cmd,IntPtr.Zero,IntPtr.Zero,false,0x0410,env,null,ref si,out pi)){if(!Advapi32.CreateProcessWithTokenW(hFinal,1,null,cmd,0x0410,env,null,ref si,out pi))err=1;}if(pi.hProcess!=IntPtr.Zero)Kernel32.CloseHandle(pi.hProcess);if(pi.hThread!=IntPtr.Zero)Kernel32.CloseHandle(pi.hThread);try{Advapi32.RevertToSelf();}catch{}Kernel32.CloseHandle(hFinal);return new StructOut{ExitCode=err};}[StructLayout(LayoutKind.Sequential)]public struct StructOut{public uint ExitCode;}}}>>"%temp%\%ASN%TI.ps1"
echo '@>>"%temp%\%ASN%TI.ps1"
echo if (-not ('WinAPI.ProcessConfig' -as [type] )){$cp=[System.CodeDom.Compiler.CompilerParameters]::new(@('System.dll'))>>"%temp%\%ASN%TI.ps1"
echo $cp.TempFiles=[System.CodeDom.Compiler.TempFileCollection]::new($DismScratchDirGlobal,$false)>>"%temp%\%ASN%TI.ps1"
echo $cp.GenerateInMemory=$true>>"%temp%\%ASN%TI.ps1"
echo $cp.CompilerOptions='/platform:anycpu /nologo'>>"%temp%\%ASN%TI.ps1"
echo Add-Type -TypeDefinition $GetTokenAPI -Language CSharp -ErrorAction Stop -CompilerParameters $cp}>>"%temp%\%ASN%TI.ps1"
echo $StructOut=[WinAPI.ProcessConfig]::Run($AppFullPath)>>"%temp%\%ASN%TI.ps1"
echo exit $StructOut.ExitCode>>"%temp%\%ASN%TI.ps1"
chcp 437 >nul 2>&1
%powershell% -MTA -NoP -NoL -NonI -EP Bypass -f "%temp%\%ASN%TI.ps1"
chcp 65001 >nul 2>&1
set "trusted=%errorlevel%">nul 2>&1
set runasti=
del /f /q "%temp%\%ASN%TI.ps1">nul 2>&1
exit /b %trusted%

:Backup
if exist "%save%MySecurityDefaults.reg" goto :EndBackup
%msg% "Creating a recovery point if recovery is enabled..." "Создание точки восстановления, если восстановление включено..."
chcp 437 >nul 2>&1
%powershell% -MTA -NoP -NoL -NonI -EP Bypass -c "Checkpoint-Computer -Description '%AS% Script Backup %date% %time%' -RestorePointType 'MODIFY_SETTINGS' -ErrorAction SilentlyContinue"
set restorepoint=%errorlevel%
chcp 65001 >nul 2>&1
if "%restorepoint%"=="0" (echo OK) else (%msg% "Skip" "Пропуск")
call :RegSave
if exist "%sysdir%GroupPolicy\Machine\Registry.pol" %msg% "Backup %sysdir%GroupPolicy\Machine\Registry.pol..." "Бэкап %sysdir%GroupPolicy\Machine\Registry.pol..."&md "%save%GroupPolicy\Machine">nul 2>&1&copy /b /y "%sysdir%GroupPolicy\Machine\Registry.pol" "%save%GroupPolicy\Machine\Registry.pol">nul 2>&1
if exist "%sysdir%GroupPolicy\User\Registry.pol" %msg% "Backup %sysdir%GroupPolicy\User\Registry.pol..." "Бэкап %sysdir%GroupPolicy\User\Registry.pol..."&md "%save%GroupPolicy\User">nul 2>&1&copy /b /y "%sysdir%GroupPolicy\User\Registry.pol" "%save%GroupPolicy\User\Registry.pol">nul 2>&1
%msg% "Backup security settings from the HKCU registry key..." "Бэкап настроек безопасности из раздела реестра HKCU..."
call :HKCU_List
call :BackupReg "hkcu.list" "hkcu.txt"
%msg% "Backup security settings from the HKLM registry key..." "Бэкап настроек безопасности из раздела реестра HKLM..."
call :HKLM_List
call :BackupReg "hklm.list" "hklm.txt"
if exist "%temp%\hkcu.txt" copy /b "%temp%\hkcu.txt"+"%temp%\hklm.txt" "%save%MySecurityDefaults.reg">nul 2>&1
if not exist "%temp%\hkcu.txt" move /y "%temp%\hklm.txt" "%save%MySecurityDefaults.reg">nul 2>&1
echo "%save%MySecurityDefaults.reg"
:EndBackup
del /f/q "%temp%\hkcu.txt">nul 2>&1
del /f/q "%temp%\hklm.txt">nul 2>&1
del /f /q "%temp%\hkcu.list">nul 2>&1
del /f /q "%temp%\hklm.list">nul 2>&1
exit /b

:RegSave
if exist "%regback%\SOFTWARE" if exist "%regback%\SYSTEM" goto :SkipRegSave
%msg% "Creating a complete copy of the registry in" "Создание полной копии реестра в"
echo %regback%
if not exist "%regback%" md "%regback%">nul 2>&1
%msg% "Creating full copy of HKLM\SOFTWARE" "Создание полной копии HKLM\SOFTWARE"
%rs% HKLM\SOFTWARE "%regback%\SOFTWARE" /y>nul 2>&1
%msg% "Creating full copy of HKLM\SYSTEM" "Создание полной копии HKLM\SYSTEM"
%rs% HKLM\SYSTEM "%regback%\SYSTEM" /y>nul 2>&1
:SkipRegSave
exit /b

:BackupReg
set out="%temp%\%ASN%Backup.ps1"
del /f/q %out%>nul 2>&1
chcp 437 >nul 2>&1
%powershell% -MTA -NoP -NoL -NonI -EP Bypass -c "$null|Out-File -FilePath '%out%' -Encoding UTF8">nul 2>&1
chcp 65001 >nul 2>&1
echo $I="%temp%\%~1">>%out%
echo $F="%temp%\%~2">>%out%
echo $O=New-Object System.Text.StringBuilder>>%out%
echo if($F -ne "%temp%\hklm.txt"){[void]$O.AppendLine("Windows Registry Editor Version 5.00")}>>%out%
echo if($F -eq "%temp%\hklm.txt"){if(![System.IO.File]::Exists("%temp%\hkcu.txt")){[void]$O.AppendLine("Windows Registry Editor Version 5.00")}}>>%out%
echo [void]$O.AppendLine("")>>%out%
echo foreach($line in [System.IO.File]::ReadLines($I)){$l=$line.Trim()>>%out%
echo if($l -eq ""){continue}>>%out%
echo $t=$l.Split(',')>>%out%
echo $P=$t[0]>>%out%
echo $K=if($t.Count -gt 1){$t[1]}else{""}>>%out%
echo $S=$P.Replace("HKCU:","HKEY_CURRENT_USER").Replace("HKLM:","HKEY_LOCAL_MACHINE").Replace("HKU:","HKEY_USERS")>>%out%
echo $regKey = $null>>%out%
echo try {>>%out%
echo $hiveStr,$pathStr = $P.Split(':',2); if($pathStr.StartsWith('\')){$pathStr = $pathStr.Substring(1)}>>%out%
echo $hive = switch($hiveStr){"HKCU"{[Microsoft.Win32.Registry]::CurrentUser}"HKLM"{[Microsoft.Win32.Registry]::LocalMachine}"HKU"{[Microsoft.Win32.Registry]::Users}}>>%out%
echo if($hive){$regKey = $hive.OpenSubKey($pathStr, $false)}>>%out%
echo if($regKey){[void]$O.AppendLine("[$S]")>>%out%
echo if($K -eq ""){foreach($vn in $regKey.GetValueNames()){>>%out%
echo $val = $regKey.GetValue($vn)>>%out%
echo if($vn -eq ""){[void]$O.AppendLine("@=`"$val`"")}>>%out%
echo else{[void]$O.AppendLine("""$vn""=`"$val`"")}}}>>%out%
echo else{$valueNames = $regKey.GetValueNames()>>%out%
echo if($valueNames -contains $K){$V=$regKey.GetValue($K); $VK=$regKey.GetValueKind($K)>>%out%
echo $ln = $null; if($V -is [string] -or $V -is [array]){$ln = $V.Length}>>%out%
echo if($ln -eq 0){if($K -eq "Start"){[void]$O.AppendLine("""$K""=dword:$("{0:X8}" -f $V)")}>>%out%
echo else{[void]$O.AppendLine("""$K""=""""")}}>>%out%
echo else{if($V -is [int] -or $V -is [long]){[void]$O.AppendLine("""$K""=dword:$("{0:X8}" -f $V)")}>>%out%
echo elseif($VK -eq "MultiString"){$bytes=[System.Text.Encoding]::Unicode.GetBytes(($V -join "`0") + "`0"); $hex=[System.BitConverter]::ToString($bytes).Replace("-",","); [void]$O.AppendLine("""$K""=hex(7):$hex")}>>%out%
echo elseif ($V -is [byte[]]) {>>%out%
echo $bin=[System.BitConverter]::ToString($V).Replace("-",",")>>%out%
echo [void]$O.AppendLine("""$K""=hex:$bin")}>>%out%
echo else{[void]$O.AppendLine("""$K""=""$V""")}}>>%out%
echo }>>%out%
echo else{[void]$O.AppendLine("""$K""=-")}}>>%out%
echo [void]$O.AppendLine("")}>>%out%
echo else{if(-not $O.ToString().Contains("[-$S]")){[void]$O.AppendLine("[-$S]")>>%out%
echo [void]$O.AppendLine("")}}}>>%out%
echo finally{if($regKey){$regKey.Close()}}}>>%out%
echo [System.IO.File]::WriteAllText($F, $O.ToString(), [System.Text.Encoding]::Unicode)>>%out%
chcp 437 >nul 2>&1
%powershell% -MTA -NoP -NoL -NonI -EP Bypass -f %out%>nul 2>&1
chcp 65001 >nul 2>&1
del /f/q %out%>nul 2>&1
exit /b

:Header
cls
color 0F
			   echo [36m┌──────────────────────────────────────────┐[0m
			   echo [36m│[36m ┌─┐┌─┐┬ ┬┬┬  ┬  ┌─┐┌─┐┐ ┌─┐┌─┐┬─┐┬┌─┐┌┬┐[0m [36m│[0m
               echo [36m│[36m ├─┤│  ├─┤││  │  ├┤ └─┐  └─┐│  ├┬┘│├─┘ │ [0m [36m│[0m
               echo [36m│[36m ┴ ┴└─┴┴ ┴┴┴─┘┴─┘└─┘└─┘  └─┘└─┘┴└─┴┴   ┴ [0m [36m│[0m
			   echo [36m└──────────────────────────────────────────┘[0m
%msg% "[36m Disable Microsoft %df%er[0m       [34m%asv%[0m" "[36m Отключение Microsoft %df%er[0m      [34m%asv%[0m"
echo.
               echo  [33m%WindowsVersion% build %WindowsBuild%[0m
exit /b

:Screen
call :Header
%msg% "[36m────────────────────────────────────────────────────────────────────────────┐[0m" "[36m─────────────────────────────────────────────────────────────────────────────┐[0m"
%msg% " [1;33m[0][0m Current status                                                         [36m│[0m" " [1;33m[0][0m Текущий статус                                                          [36m│[0m"
%msg% "[36m────────────────────────────────────────────────────────────────────────────┤[0m" "[36m─────────────────────────────────────────────────────────────────────────────┤[0m"
%msg% " [36mDisable using:[0m                                                             [36m│[0m" " [36mОтключить используя:[0m                                                        [36m│[0m"
%msg% " [32m[1][0m Group Policies                                                         [36m│[0m" " [32m[1][0m Групповые политики                                                      [36m│[0m"
%msg% " [32m[2][0m Group Policies + Registry Settings                                     [36m│[0m" " [32m[2][0m Групповые политики + Настройки реестра                                  [36m│[0m"
%msg% " [32m[3][0m Group Policies + Registry Settings + Disabling Services and drivers    [36m│[0m" " [32m[3][0m Групповые политики + Настройки реестра + Отключение служб и драйверов   [36m│[0m"
%ifdef% ViewBlock %msg% " [32m[4][0m Policies + Settings + Services and drivers + Block launch              [36m│[0m" " [32m[4][0m Политики + Настройки + Службы и драйверы + Блокировка запуска[36m           │[0m"
%msg% "[36m────────────────────────────────────────────────────────────────────────────┤[0m" "[36m─────────────────────────────────────────────────────────────────────────────┤[0m"
%msg% " [33m[5][0m Restore Defaults                                                       [36m│[0m" " [33m[5][0m Восстановить по умолчанию                                               [36m│[0m"
%msg% "[36m────────────────────────────────────────────────────────────────────────────┤[0m" "[36m─────────────────────────────────────────────────────────────────────────────┤[0m"
%msg% " [1;34m[6][0m Disable locked functions                                               [36m│[0m" " [1;34m[6][0m Отключение заблокированных функций                                      [36m│[0m"
%msg% " [1;34m[7][0m Reboot menu                                                            [36m│[0m" " [1;34m[7][0m Меню перезагрузки                                                       [36m│[0m"
%msg% " [1;34m[8][0m Run as TrustedInstaller                                                [36m│[0m" " [1;34m[8][0m Меню запуска с правами TrustedInstaller                                 [36m│[0m"
%msg% "[36m────────────────────────────────────────────────────────────────────────────┤[0m" "[36m─────────────────────────────────────────────────────────────────────────────┤[0m"
%msg% " [1;35m[9][0m Help and Update                                                        [36m│[0m" " [1;35m[9][0m Помощь и обновление                                                     [36m│[0m"
%msg% " [35m[X][0m Exit                                                                   [36m│[0m" " [35m[X][0m Выход                                                                   [36m│[0m"
%msg% "[36m────────────────────────────────────────────────────────────────────────────┘[0m" "[36m─────────────────────────────────────────────────────────────────────────────┘[0m"
exit /b

:HKCU_List
del /f/q "%temp%\hkcu.list">nul 2>&1
echo HKCU:\%smw% Security Health\State,AppAndBrowser_Edge%ss%Off>"%temp%\hkcu.list"
echo HKCU:\%smw% Security Health\State,AppAndBrowser_Pua%ss%Off>>"%temp%\hkcu.list"
echo HKCU:\%smw% Security Health\State,AppAndBrowser_StoreApps%ss%Off>>"%temp%\hkcu.list"
echo HKCU:\%smw%\%cv%\AppHost,%el%WebContentEvaluation>>"%temp%\hkcu.list"
echo HKCU:\%smw%\%cv%\AppHost,PreventOverride>>"%temp%\hkcu.list"
echo HKCU:\%smw%\%cv%\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance,%el%d>>"%temp%\hkcu.list"
echo HKCU:\%smw%\%cv%\Policies\Attachments,SaveZoneInformation>>"%temp%\hkcu.list"
echo HKCU:\%smw%\%cv%\Policies\Attachments,HideZoneInfoOnProperties>>"%temp%\hkcu.list"
echo HKCU:\%smw%\%cv%\Policies\Attachments,ScanWithAntiVirus>>"%temp%\hkcu.list"
echo HKCU:\%smw%\%cv%\Policies\Associations,DefaultFileTypeRisk>>"%temp%\hkcu.list"
echo HKCU:\%spm%\Edge,PreventOverride>>"%temp%\hkcu.list"
echo HKCU:\%spm%\Edge,%ss%%el%d>>"%temp%\hkcu.list"
echo HKCU:\%spm%\Edge,%ss%Pua%el%d>>"%temp%\hkcu.list"
echo HKCU:\Software\Microsoft\Edge,%ss%%el%d>>"%temp%\hkcu.list"
echo HKCU:\Software\Microsoft\Edge,%ss%Pua%el%d>>"%temp%\hkcu.list"
echo HKCU:\Software\Microsoft\Edge,%ss%%el%d>>"%temp%\hkcu.list"
echo HKCU:\Software\Microsoft\Edge,%ss%Pua%el%d>>"%temp%\hkcu.list"
echo HKCU:\%spm%\Windows\%cv%\Internet Settings\Zones\3,180F>>"%temp%\hkcu.list"
echo HKCU:\%spm%\Windows\%cv%\Internet Settings\Lockdown_Zones\3,180F>>"%temp%\hkcu.list"
for /f "tokens=7 delims=\" %%a in ('%rq% "%plist%" ^| %findstr% /R /C:"S-1-5-21-*"') do (
	echo HKU:\%%a\%smw% Security Health\State,AppAndBrowser_Edge%ss%Off>>"%temp%\hkcu.list"
	echo HKU:\%%a\%smw% Security Health\State,AppAndBrowser_Pua%ss%Off>>"%temp%\hkcu.list"
	echo HKU:\%%a\%smw% Security Health\State,AppAndBrowser_StoreApps%ss%Off>>"%temp%\hkcu.list"
	echo HKU:\%%a\%smw%\%cv%\AppHost,%el%WebContentEvaluation>>"%temp%\hkcu.list"
	echo HKU:\%%a\%smw%\%cv%\AppHost,PreventOverride>>"%temp%\hkcu.list"
	echo HKU:\%%a\%smw%\%cv%\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance,%el%d>>"%temp%\hkcu.list"
	echo HKU:\%%a\%smw%\%cv%\Policies\Attachments,SaveZoneInformation>>"%temp%\hkcu.list"
	echo HKU:\%%a\%smw%\%cv%\Policies\Attachments,HideZoneInfoOnProperties>>"%temp%\hkcu.list"
	echo HKU:\%%a\%smw%\%cv%\Policies\Attachments,ScanWithAntiVirus>>"%temp%\hkcu.list"
	echo HKU:\%smw%\%cv%\Policies\Associations,DefaultFileTypeRisk>>"%temp%\hkcu.list"
	echo HKU:\%spm%\Edge,PreventOverride>>"%temp%\hkcu.list"
	echo HKU:\%spm%\Edge,%ss%%el%d>>"%temp%\hkcu.list"
	echo HKU:\%spm%\Edge,%ss%Pua%el%d>>"%temp%\hkcu.list"
	echo HKU:\%%a\Software\Microsoft\Edge,%ss%%el%d>>"%temp%\hkcu.list"
	echo HKU:\%%a\Software\Microsoft\Edge,%ss%Pua%el%d>>"%temp%\hkcu.list"
	echo HKU:\%spm%\Windows\%cv%\Internet Settings\Zones\3,180F>>"%temp%\hkcu.list"
	echo HKU:\%spm%\Windows\%cv%\Internet Settings\Lockdown_Zones\3,180F>>"%temp%\hkcu.list"
)
call :ListUWP sechealth
call :ListUWP chxapp
exit /b

:HKLM_List
del /f/q "%temp%\hklm.list">nul 2>&1
echo HKLM:\%scc%\CI\Policy>>"%temp%\hklm.list"
echo HKLM:\%scc%\CI\Config>>"%temp%\hklm.list"
echo HKLM:\%scc%\CI\State>>"%temp%\hklm.list"
echo HKLM:\%scc%\Lsa,LsaCfgFlags>>"%temp%\hklm.list"
echo HKLM:\%scc%\Lsa,RunAsPPL>>"%temp%\hklm.list"
echo HKLM:\%scc%\Lsa,RunAsPPLBoot>>"%temp%\hklm.list"
echo HKLM:\%scc%\SafeBoot\Minimal\Win%df%>"%temp%\hklm.list"
echo HKLM:\%scc%\SafeBoot\Minimal\Win%df%_off>>"%temp%\hklm.list"
echo HKLM:\%scc%\Ubpm,CriticalMaintenance_%df%erCleanup>>"%temp%\hklm.list"
echo HKLM:\%scc%\Ubpm,CriticalMaintenance_%df%erVerification>>"%temp%\hklm.list"
echo HKLM:\%scc%\WMI\Autologger\%df%erApiLogger,Start>>"%temp%\hklm.list"
echo HKLM:\%scc%\WMI\Autologger\%df%erAuditLogger,Start>>"%temp%\hklm.list"
echo HKLM:\%sccd%\Capabilities>>"%temp%\hklm.list"
echo HKLM:\%sccd%\Scenarios\KernelShadowStacks,AuditMode%el%d>>"%temp%\hklm.list"
echo HKLM:\%sccd%\Scenarios\KernelShadowStacks,%el%d>>"%temp%\hklm.list"
echo HKLM:\%sccd%\Scenarios\KernelShadowStacks,Was%el%dBy>>"%temp%\hklm.list"
echo HKLM:\%sccd%\Scenarios\KeyGuard\Status>>"%temp%\hklm.list"
echo HKLM:\%scl%\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}>>"%temp%\hklm.list"
echo HKLM:\%scl%\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}\InProcServer32>>"%temp%\hklm.list"
echo HKLM:\%scl%\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}\LocalServer32>>"%temp%\hklm.list"
echo HKLM:\%scl%\exefile\shell\open,No%ss%>>"%temp%\hklm.list"
echo HKLM:\%scl%\exefile\shell\runas,No%ss%>>"%temp%\hklm.list"
echo HKLM:\%scl%\exefile\shell\runasuser,No%ss%>>"%temp%\hklm.list"
echo HKLM:\%scl%\WOW6432Node\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}>>"%temp%\hklm.list"
echo HKLM:\%scl%\WOW6432Node\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}\InProcServer32>>"%temp%\hklm.list"
echo HKLM:\%scl%\WOW6432Node\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}\LocalServer32>>"%temp%\hklm.list"
echo HKLM:\%scs%\AppID,Start>>"%temp%\hklm.list"
echo HKLM:\%scs%\AppID,DependOnService>>"%temp%\hklm.list"
echo HKLM:\%scs%\AppIDSvc,Start>>"%temp%\hklm.list"
echo HKLM:\%scs%\AppIDSvc,DependOnService>>"%temp%\hklm.list"
echo HKLM:\%scs%\applockerfltr,Start>>"%temp%\hklm.list"
echo HKLM:\%scs%\applockerfltr,DependOnService>>"%temp%\hklm.list"
echo HKLM:\%scs%\KslD,Start>>"%temp%\hklm.list"
echo HKLM:\%scs%\KslD,DependOnService>>"%temp%\hklm.list"
echo HKLM:\%scs%\MDCoreSvc,Start>>"%temp%\hklm.list"
echo HKLM:\%scs%\MDCoreSvc,DependOnService>>"%temp%\hklm.list"
echo HKLM:\%scs%\MsSecCore,Start>>"%temp%\hklm.list"
echo HKLM:\%scs%\MsSecCore,DependOnService>>"%temp%\hklm.list"
echo HKLM:\%scs%\MsSecFlt,Start>>"%temp%\hklm.list"
echo HKLM:\%scs%\MsSecFlt,DependOnService>>"%temp%\hklm.list"
echo HKLM:\%scs%\MsSecWfp,Start>>"%temp%\hklm.list"
echo HKLM:\%scs%\MsSecWfp,DependOnService>>"%temp%\hklm.list"
echo HKLM:\%scs%\SecurityHealthService,Start>>"%temp%\hklm.list"
echo HKLM:\%scs%\SecurityHealthService,DependOnService>>"%temp%\hklm.list"
echo HKLM:\%scs%\Sense,Start>>"%temp%\hklm.list"
echo HKLM:\%scs%\Sense,DependOnService>>"%temp%\hklm.list"
echo HKLM:\%scs%\SgrmAgent,Start>>"%temp%\hklm.list"
echo HKLM:\%scs%\SgrmAgent,DependOnService>>"%temp%\hklm.list"
echo HKLM:\%scs%\SgrmBroker,Start>>"%temp%\hklm.list"
echo HKLM:\%scs%\SgrmBroker,DependOnService>>"%temp%\hklm.list"
echo HKLM:\%scs%\WdBoot,Start>>"%temp%\hklm.list"
echo HKLM:\%scs%\WdBoot,DependOnService>>"%temp%\hklm.list"
echo HKLM:\%scs%\WdDevFlt,Start>>"%temp%\hklm.list"
echo HKLM:\%scs%\WdDevFlt,DependOnService>>"%temp%\hklm.list"
echo HKLM:\%scs%\WdFilter,Start>>"%temp%\hklm.list"
echo HKLM:\%scs%\WdFilter,DependOnService>>"%temp%\hklm.list"
echo HKLM:\%scs%\WdNisDrv,Start>>"%temp%\hklm.list"
echo HKLM:\%scs%\WdNisDrv,DependOnService>>"%temp%\hklm.list"
echo HKLM:\%scs%\WdNisSvc,Start>>"%temp%\hklm.list"
echo HKLM:\%scs%\WdNisSvc,DependOnService>>"%temp%\hklm.list"
echo HKLM:\%scs%\webthreatdefsvc,Start>>"%temp%\hklm.list"
echo HKLM:\%scs%\webthreatdefsvc,DependOnService>>"%temp%\hklm.list"
echo HKLM:\%scs%\webthreatdefusersvc,Start>>"%temp%\hklm.list"
echo HKLM:\%scs%\webthreatdefusersvc,DependOnService>>"%temp%\hklm.list"
echo HKLM:\%scs%\Win%df%,Start>>"%temp%\hklm.list"
echo HKLM:\%scs%\Win%df%,DependOnService>>"%temp%\hklm.list"
echo HKLM:\%scs%\wscsvc,Start>>"%temp%\hklm.list"
echo HKLM:\%scs%\wscsvc,DependOnService>>"%temp%\hklm.list"
echo HKLM:\%scs%\wtd,Start>>"%temp%\hklm.list"
echo HKLM:\%scs%\wtd,DependOnService>>"%temp%\hklm.list"
echo HKLM:\%smw% NT\%cv%\Svchost,WebThreatDefense>>"%temp%\hklm.list"
echo HKLM:\%scs%\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System,WebThreatDefSvc_Allow_In>>"%temp%\hklm.list"
echo HKLM:\%scs%\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System,WebThreatDefSvc_Allow_Out>>"%temp%\hklm.list"
echo HKLM:\%scs%\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System,WebThreatDefSvc_Block_In>>"%temp%\hklm.list"
echo HKLM:\%scs%\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System,WebThreatDefSvc_Block_Out>>"%temp%\hklm.list"
echo HKLM:\%scs%\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System,Windows%df%er-1>>"%temp%\hklm.list"
echo HKLM:\%scs%\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System,Windows%df%er-2>>"%temp%\hklm.list"
echo HKLM:\%scs%\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System,Windows%df%er-3>>"%temp%\hklm.list"
echo HKLM:\%smw%\%cv%\AppHost,%el%WebContentEvaluation>>"%temp%\hklm.list"
echo HKLM:\%smw%\%cv%\Explorer,%ss%%el%d>>"%temp%\hklm.list"
echo HKLM:\%smw%\%cv%\Explorer,Aic%el%d>>"%temp%\hklm.list"
echo HKLM:\%smw%\%cv%\Explorer\StartupApproved\Run,SecurityHealth>>"%temp%\hklm.list"
echo HKLM:\%smw%\%cv%\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance,%el%d>>"%temp%\hklm.list"
echo HKLM:\%smw%\%cv%\Policies\Explorer,SettingsPageVisibility>>"%temp%\hklm.list"
echo HKLM:\%smw%\%cv%\Policies\System\Audit,ProcessCreationIncludeCmdLine_%el%d>>"%temp%\hklm.list"
echo HKLM:\%smw%\%cv%\Run,SecurityHealth>>"%temp%\hklm.list"
echo HKLM:\%smw%\%cv%\Run\Autoruns%dl%d,SecurityHealth>>"%temp%\hklm.list"
echo HKLM:\%smw%\%cv%\Shell Extensions\Approved,{09A47860-11B0-4DA5-AFA5-26D86198A780}>>"%temp%\hklm.list"
echo HKLM:\%smw%\%cv%\Shell Extensions\Blocked,{09A47860-11B0-4DA5-AFA5-26D86198A780}>>"%temp%\hklm.list"
echo HKLM:\%smw%\%cv%\%evt%%wd%\Operational,%el%d>>"%temp%\hklm.list"
echo HKLM:\%smw%\%cv%\%evt%%wd%\WHC,%el%d>>"%temp%\hklm.list"
echo HKLM:\%smw%\%cv%\WTDS\Components>>"%temp%\hklm.list"
echo HKLM:\%smw%\%cv%\WTDS\FeatureFlags>>"%temp%\hklm.list"
echo HKLM:\%smw%\Edge,%ss%%el%d>>"%temp%\hkcu.list"
echo HKLM:\%smw%\Edge,PreventOverride>"%temp%\hkcu.list"
echo HKLM:\%smw%\MicrosoftEdge\PhishingFilter,%el%dV9>>"%temp%\hklm.list"
echo HKLM:\%smw%\MicrosoftEdge\PhishingFilter,PreventOverrideAppRepUnknown>>"%temp%\hklm.list"
echo HKLM:\%smw%\MicrosoftEdge\PhishingFilter>>"%temp%\hklm.list"
echo HKLM:\%smw%\MRT,DontOfferThroughWUAU>>"%temp%\hklm.list"
echo HKLM:\%smw%\MRT,DontReportInfectionInformation>>"%temp%\hklm.list"
echo HKLM:\%smwci%\%df%erbootstrapper.exe>>"%temp%\hklm.list"
echo HKLM:\%smwci%\%ss%.exe>>"%temp%\hklm.list"
echo HKLM:\%smwci%\ConfigSecurityPolicy.exe>>"%temp%\hklm.list"
echo HKLM:\%smwci%\DlpUserAgent.exe>>"%temp%\hklm.list"
echo HKLM:\%smwci%\LSASS.exe>>"%temp%\hklm.list"
echo HKLM:\%smwci%\Mp%df%erCoreService.exe>>"%temp%\hklm.list"
echo HKLM:\%smwci%\mpam-d.exe>>"%temp%\hklm.list"
echo HKLM:\%smwci%\mpam-fe.exe>>"%temp%\hklm.list"
echo HKLM:\%smwci%\mpam-fe_bd.exe>>"%temp%\hklm.list"
echo HKLM:\%smwci%\mpas-d.exe>>"%temp%\hklm.list"
echo HKLM:\%smwci%\mpas-fe.exe>>"%temp%\hklm.list"
echo HKLM:\%smwci%\mpas-fe_bd.exe>>"%temp%\hklm.list"
echo HKLM:\%smwci%\mpav-d.exe>>"%temp%\hklm.list"
echo HKLM:\%smwci%\mpav-fe.exe>>"%temp%\hklm.list"
echo HKLM:\%smwci%\mpav-fe_bd.exe>>"%temp%\hklm.list"
echo HKLM:\%smwci%\UpdatePlatform.amd64fre.exe>>"%temp%\hklm.list"
echo HKLM:\%smwci%\MpCmdRun.exe>>"%temp%\hklm.list"
echo HKLM:\%smwci%\MpCopyAccelerator.exe>>"%temp%\hklm.list"
echo HKLM:\%smwci%\MpDlpCmd.exe>>"%temp%\hklm.list"
echo HKLM:\%smwci%\MpDlpService.exe>>"%temp%\hklm.list"
echo HKLM:\%smwci%\Mp%df%erCoreService.exe>>"%temp%\hklm.list"
echo HKLM:\%smwci%\mpextms.exe>>"%temp%\hklm.list"
echo HKLM:\%smwci%\MpSigStub.exe>>"%temp%\hklm.list"
echo HKLM:\%smwci%\MRT.exe>>"%temp%\hklm.list"
echo HKLM:\%smwci%\MsMpEng.exe>>"%temp%\hklm.list"
echo HKLM:\%smwci%\MsMpEngCP.exe>>"%temp%\hklm.list"
echo HKLM:\%smwci%\MsSense.exe>>"%temp%\hklm.list"
echo HKLM:\%smwci%\NisSrv.exe>>"%temp%\hklm.list"
echo HKLM:\%smwci%\OfflineScannerShell.exe>>"%temp%\hklm.list"
echo HKLM:\%smwci%\SecureKernel.exe>>"%temp%\hklm.list"
echo HKLM:\%smwci%\SecurityHealthHost.exe>>"%temp%\hklm.list"
echo HKLM:\%smwci%\SecurityHealthService.exe>>"%temp%\hklm.list"
echo HKLM:\%smwci%\SecurityHealthSystray.exe>>"%temp%\hklm.list"
echo HKLM:\%smwci%\SenseAP.exe>>"%temp%\hklm.list"
echo HKLM:\%smwci%\SenseAPToast.exe>>"%temp%\hklm.list"
echo HKLM:\%smwci%\SenseCM.exe>>"%temp%\hklm.list"
echo HKLM:\%smwci%\SenseGPParser.exe>>"%temp%\hklm.list"
echo HKLM:\%smwci%\SenseIdentity.exe>>"%temp%\hklm.list"
echo HKLM:\%smwci%\SenseImdsCollector.exe>>"%temp%\hklm.list"
echo HKLM:\%smwci%\SenseIR.exe>>"%temp%\hklm.list"
echo HKLM:\%smwci%\SenseNdr.exe>>"%temp%\hklm.list"
echo HKLM:\%smwci%\SenseSampleUploader.exe>>"%temp%\hklm.list"
echo HKLM:\%smwci%\SenseTVM.exe>>"%temp%\hklm.list"
echo HKLM:\%smwci%\SenseCE.exe>>"%temp%\hklm.list"
echo HKLM:\%smwci%\SgrmBroker.exe>>"%temp%\hklm.list"
echo HKLM:\%smwd% Security Center\Device security,UILockdown>>"%temp%\hklm.list"
echo HKLM:\%smwd% Security Center\Notifications,%dl%EnhancedNotifications>>"%temp%\hklm.list"
echo HKLM:\%smwd% Security Center\Virus and threat protection,FilesBlockedNotification%dl%d>>"%temp%\hklm.list"
echo HKLM:\%smwd% Security Center\Virus and threat protection,NoActionNotification%dl%d>>"%temp%\hklm.list"
echo HKLM:\%smwd% Security Center\Virus and threat protection,SummaryNotification%dl%d>>"%temp%\hklm.list"
echo HKLM:\%smwd%,%dl%AntiSpyware>>"%temp%\hklm.list"
echo HKLM:\%smwd%,%dl%AntiVirus>>"%temp%\hklm.list"
echo HKLM:\%smwd%,HybridMode%el%d>>"%temp%\hklm.list"
echo HKLM:\%smwd%,IsServiceRunning>>"%temp%\hklm.list"
echo HKLM:\%smwd%,ProductStatus>>"%temp%\hklm.list"
echo HKLM:\%smwd%,ProductType>>"%temp%\hklm.list"
echo HKLM:\%smwd%,PUAProtection>>"%temp%\hklm.list"
echo HKLM:\%smwd%,SmartLockerMode>>"%temp%\hklm.list"
echo HKLM:\%smwd%,VerifiedAndReputableTrustMode%el%d>>"%temp%\hklm.list"
echo HKLM:\%smwd%\%wd% Exploit Guard\ASR,%el%ASRConsumers>>"%temp%\hklm.list"
echo HKLM:\%smwd%\%wd% Exploit Guard\ASR\Rules>>"%temp%\hklm.list"
echo HKLM:\%smwd%\%wd% Exploit Guard\Controlled Folder Access,%el%ControlledFolderAccess>>"%temp%\hklm.list"
echo HKLM:\%smwd%\%wd% Exploit Guard\Network Protection,%el%NetworkProtection>>"%temp%\hklm.list"
echo HKLM:\%smwd%\CoreService,%dl%CoreService1DSTelemetry>>"%temp%\hklm.list"
echo HKLM:\%smwd%\CoreService,%dl%CoreServiceECSIntegration>>"%temp%\hklm.list"
echo HKLM:\%smwd%\CoreService,Md%dl%ResController>>"%temp%\hklm.list"
echo HKLM:\%smwd%\Features,%el%CACS>>"%temp%\hklm.list"
echo HKLM:\%smwd%\Features,Protection>>"%temp%\hklm.list"
echo HKLM:\%smwd%\Features,TamperProtection>>"%temp%\hklm.list"
echo HKLM:\%smwd%\Features,TamperProtectionSource>>"%temp%\hklm.list"
echo HKLM:\%smwd%\Features,MpPlatformKillbitsFromEngine>>"%temp%\hklm.list"
echo HKLM:\%smwd%\Features,MpCapability>>"%temp%\hklm.list"
echo HKLM:\%smwd%\Features\EcsConfigs,%el%AdsSymlinkMitigation_MpRamp>>"%temp%\hklm.list"
echo HKLM:\%smwd%\Features\EcsConfigs,%el%BmProcessInfoMetastoreMaintenance_MpRamp>>"%temp%\hklm.list"
echo HKLM:\%smwd%\Features\EcsConfigs,%el%CIWorkaroundOnCFA%el%d_MpRamp>>"%temp%\hklm.list"
echo HKLM:\%smwd%\Features\EcsConfigs,Md%dl%ResController>>"%temp%\hklm.list"
echo HKLM:\%smwd%\Features\EcsConfigs,Mp%dl%PropBagNotification>>"%temp%\hklm.list"
echo HKLM:\%smwd%\Features\EcsConfigs,Mp%dl%ResourceMonitoring>>"%temp%\hklm.list"
echo HKLM:\%smwd%\Features\EcsConfigs,Mp%el%NoMetaStoreProcessInfoContainer>>"%temp%\hklm.list"
echo HKLM:\%smwd%\Features\EcsConfigs,Mp%el%PurgeHipsCache>>"%temp%\hklm.list"
echo HKLM:\%smwd%\Features\EcsConfigs,MpFC_AdvertiseLogonMinutesFeature>>"%temp%\hklm.list"
echo HKLM:\%smwd%\Features\EcsConfigs,MpFC_%el%CommonMetricsEvents>>"%temp%\hklm.list"
echo HKLM:\%smwd%\Features\EcsConfigs,MpFC_%el%ImpersonationOnNetworkResourceScan>>"%temp%\hklm.list"
echo HKLM:\%smwd%\Features\EcsConfigs,MpFC_%el%PersistedScanV2>>"%temp%\hklm.list"
echo HKLM:\%smwd%\Features\EcsConfigs,MpFC_Kernel_%el%FolderGuardOnPostCreate>>"%temp%\hklm.list"
echo HKLM:\%smwd%\Features\EcsConfigs,MpFC_Kernel_SystemIoRequestWorkOnBehalfOf>>"%temp%\hklm.list"
echo HKLM:\%smwd%\Features\EcsConfigs,MpFC_Md%dl%1ds>>"%temp%\hklm.list"
echo HKLM:\%smwd%\Features\EcsConfigs,MpFC_Md%el%CoreService>>"%temp%\hklm.list"
echo HKLM:\%smwd%\Features\EcsConfigs,MpFC_Rtp%el%%df%erConfigMonitoring>>"%temp%\hklm.list"
echo HKLM:\%smwd%\Features\EcsConfigs,MpForceDllHostScanExeOnOpen>>"%temp%\hklm.list"
echo HKLM:\%smwd%\Real-Time Protection,%dl%AsyncScanOnOpen>>"%temp%\hklm.list"
echo HKLM:\%smwd%\Real-Time Protection,%dl%RealtimeMonitoring>>"%temp%\hklm.list"
echo HKLM:\%smwd%\Real-Time Protection,Dpa%dl%d>>"%temp%\hklm.list"
echo HKLM:\%smwd%\Scan,%dl%ArchiveScanning>>"%temp%\hklm.list"
echo HKLM:\%smwd%\Scan,%dl%EmailScanning>>"%temp%\hklm.list"
echo HKLM:\%smwd%\Scan,%dl%RemovableDriveScanning>>"%temp%\hklm.list"
echo HKLM:\%smwd%\Scan,%dl%ScanningMappedNetworkDrivesForFullScan>>"%temp%\hklm.list"
echo HKLM:\%smwd%\Scan,%dl%ScanningNetworkFiles>>"%temp%\hklm.list"
echo HKLM:\%smwd%\Scan,AvgCPULoadFactor>>"%temp%\hklm.list"
echo HKLM:\%smwd%\Scan,LowCpuPriority>>"%temp%\hklm.list"
echo HKLM:\%smwd%\Spynet,MAPSconcurrency>>"%temp%\hklm.list"
echo HKLM:\%smwd%\Spynet,SpyNetReporting>>"%temp%\hklm.list"
echo HKLM:\%smwd%\Spynet,SpyNetReportingLocation>>"%temp%\hklm.list"
echo HKLM:\%smwd%\Spynet,SubmitSamplesConsent>>"%temp%\hklm.list"
echo HKLM:\%smwd%\Threats\ThreatIDDefaultAction>>"%temp%\hklm.list"
echo HKLM:\%smwd%\Threats\ThreatSeverityDefaultAction>>"%temp%\hklm.list"
echo HKLM:\%smwd%\Threats\ThreatTypeDefaultAction>>"%temp%\hklm.list"
echo HKLM:\%spm%\Edge,PreventOverride>>"%temp%\hklm.list"
echo HKLM:\%spm%\Edge,%ss%%el%d>>"%temp%\hklm.list"
echo HKLM:\%spm%\MicrosoftEdge\PhishingFilter,%el%dV9>>"%temp%\hklm.list"
echo HKLM:\%spm%\MicrosoftEdge\PhishingFilter,PreventOverride>>"%temp%\hklm.list"
echo HKLM:\%spm%\MicrosoftEdge\PhishingFilter,PreventOverrideAppRepUnknown>>"%temp%\hklm.list"
echo HKLM:\%spm%\MRT,DontOfferThroughWUAU>>"%temp%\hklm.list"
echo HKLM:\%spm%\MRT,DontReportInfectionInformation>>"%temp%\hklm.list"
echo HKLM:\%spm%\Windows\DeviceGuard,ConfigCIPolicyFilePath>>"%temp%\hklm.list"
echo HKLM:\%spm%\Windows\DeviceGuard,ConfigureKernelShadowStacksLaunch>>"%temp%\hklm.list"
echo HKLM:\%spm%\Windows\DeviceGuard,DeployConfigCIPolicy>>"%temp%\hklm.list"
echo HKLM:\%spm%\Windows\DeviceGuard,%el%VirtualizationBasedSecurity>>"%temp%\hklm.list"
echo HKLM:\%spm%\Windows\DeviceGuard,HVCIMATRequired>>"%temp%\hklm.list"
echo HKLM:\%spm%\Windows\DeviceGuard,HypervisorEnforcedCodeIntegrity>>"%temp%\hklm.list"
echo HKLM:\%spm%\Windows\DeviceGuard,LsaCfgFlags>>"%temp%\hklm.list"
echo HKLM:\%spm%\Windows\DeviceGuard,MachineIdentityIsolation>>"%temp%\hklm.list"
echo HKLM:\%spm%\Windows\System,%el%%ss%>>"%temp%\hklm.list"
echo HKLM:\%spm%\Windows\System,RunAsPPL>>"%temp%\hklm.list"
echo HKLM:\%spm%\Windows\WTDS\Components,CaptureThreatWindow>>"%temp%\hklm.list"
echo HKLM:\%spm%\Windows\WTDS\Components,NotifyMalicious>>"%temp%\hklm.list"
echo HKLM:\%spm%\Windows\WTDS\Components,NotifyPasswordReuse>>"%temp%\hklm.list"
echo HKLM:\%spm%\Windows\WTDS\Components,NotifyUnsafeApp>>"%temp%\hklm.list"
echo HKLM:\%spm%\Windows\WTDS\Components,Service%el%d>>"%temp%\hklm.list"
echo HKLM:\%spmwd% Security Center\Account protection,UILockdown>>"%temp%\hklm.list"
echo HKLM:\%spmwd% Security Center\App and Browser protection,DisallowExploitProtectionOverride>>"%temp%\hklm.list"
echo HKLM:\%spmwd% Security Center\App and Browser protection,UILockdown>>"%temp%\hklm.list"
echo HKLM:\%spmwd% Security Center\Device performance and health,UILockdown>>"%temp%\hklm.list"
echo HKLM:\%spmwd% Security Center\Device security,UILockdown>>"%temp%\hklm.list"
echo HKLM:\%spmwd% Security Center\Family options,UILockdown>>"%temp%\hklm.list"
echo HKLM:\%spmwd% Security Center\Firewall and network protection,UILockdown>>"%temp%\hklm.list"
echo HKLM:\%spmwd% Security Center\Notifications,%dl%Notifications>>"%temp%\hklm.list"
echo HKLM:\%spmwd% Security Center\Systray,HideSystray>>"%temp%\hklm.list"
echo HKLM:\%spmwd% Security Center\Virus and threat protection,UILockdown>>"%temp%\hklm.list"
echo HKLM:\%spmwd%,%dl%AntiSpyware>>"%temp%\hklm.list"
echo HKLM:\%spmwd%,%dl%AntiVirus>>"%temp%\hklm.list"
echo HKLM:\%spmwd%,%dl%LocalAdminMerge>>"%temp%\hklm.list"
echo HKLM:\%spmwd%,%dl%RoutinelyTakingAction>>"%temp%\hklm.list"
echo HKLM:\%spmwd%,AllowFastServiceStartup>>"%temp%\hklm.list"
echo HKLM:\%spmwd%,PUAProtection>>"%temp%\hklm.list"
echo HKLM:\%spmwd%,RandomizeScheduleTaskTimes>>"%temp%\hklm.list"
echo HKLM:\%spmwd%,ServiceKeepAlive>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\%ss%,ConfigureAppInstallControl>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\%ss%,ConfigureAppInstallControl%el%d>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\%wd% Exploit Guard\ASR,ExploitGuard_ASR_ASROnlyPerRuleExclusions>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\%wd% Exploit Guard\ASR,ExploitGuard_ASR_Rules>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\%wd% Exploit Guard\Controlled Folder Access,%el%ControlledFolderAccess>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\%wd% Exploit Guard\Network Protection,AllowNetworkProtectionOnWinServer>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\%wd% Exploit Guard\Network Protection,%el%NetworkProtection>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Device Control,DefaultEnforcement>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Exclusions,%dl%AutoExclusions>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Features,DeviceControl%el%d>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Features,PassiveRemediation>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Features,TDTFeature%el%d>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\MpEngine,%dl%GradualRelease>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\MpEngine,%el%FileHashComputation>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\MpEngine,MpBafsExtendedTimeout>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\MpEngine,MpCloudBlockLevel>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\MpEngine,Mp%el%Pus>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\NIS,%dl%DatagramProcessing>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\NIS,%dl%ProtocolRecognition>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\NIS,AllowSwitchToAsyncInspection>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\NIS,%el%ConvertWarnToBlock>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\NIS\Consumers\IPS,%dl%ProtocolRecognition>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\NIS\Consumers\IPS,%dl%SignatureRetirement>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\NIS\Consumers\IPS,ThrottleDetectionEventsRate>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Policy Manager,%dl%ScanningNetworkFiles>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Real-Time Protection,%dl%AsyncScanOnOpen>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Real-Time Protection,%dl%BehaviorMonitoring>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Real-Time Protection,%dl%InformationProtectionControl>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Real-Time Protection,%dl%IntrusionPreventionSystem>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Real-Time Protection,%dl%IOAVProtection>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Real-Time Protection,%dl%OnAccessProtection>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Real-Time Protection,%dl%RawWriteNotification>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Real-Time Protection,%dl%RealtimeMonitoring>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Real-Time Protection,%dl%ScanOnRealtime%el%>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Real-Time Protection,%dl%ScriptScanning>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Real-Time Protection,IOAVMaxSize>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Real-Time Protection,LocalSettingOverride%dl%BehaviorMonitoring>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Real-Time Protection,LocalSettingOverride%dl%IntrusionPreventionSystem>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Real-Time Protection,LocalSettingOverride%dl%IOAVProtection>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Real-Time Protection,LocalSettingOverride%dl%OnAccessProtection>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Real-Time Protection,LocalSettingOverride%dl%RealtimeMonitoring>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Real-Time Protection,LocalSettingOverrideRealtimeScanDirection>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Real-Time Protection,Oobe%el%RtpAndSigUpdate>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Real-Time Protection,RealtimeScanDirection>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Remediation\Behavioral Network Blocks\Brute Force Protection,BruteForceProtectionConfiguredState>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Remediation\Behavioral Network Blocks\Remote Encryption Protection,RemoteEncryptionProtectionConfiguredState>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Reporting,%dl%EnhancedNotifications>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Reporting,%dl%GenericRePorts>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Reporting,%spmwd%\Reporting>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Reporting,%el%DynamicSignatureDroppedEventReporting>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Reporting,WppTracingComponents>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Reporting,WppTracingLevel>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Scan,%dl%ArchiveScanning>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Scan,%dl%CatchupFullScan>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Scan,%dl%CatchupQuickScan>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Scan,%dl%EmailScanning>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Scan,%dl%Heuristics>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Scan,%dl%PackedExeScanning>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Scan,%dl%RemovableDriveScanning>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Scan,%dl%ReparsePointScanning>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Scan,%dl%RestorePoint>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Scan,%dl%ScanningMappedNetworkDrivesForFullScan>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Scan,%dl%ScanningNetworkFiles>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Scan,AllowPause>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Scan,ArchiveMaxDepth>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Scan,ArchiveMaxSize>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Scan,AvgCPULoadFactor>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Scan,CheckForSignaturesBeforeRunningScan>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Scan,LocalSettingOverrideAvgCPULoadFactor>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Scan,LocalSettingOverrideScanParameters>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Scan,LocalSettingOverrideScheduleDay>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Scan,LocalSettingOverrideScheduleQuickScanTime>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Scan,LocalSettingOverrideScheduleTime>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Scan,LowCpuPriority>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Scan,PurgeItemsAfterDelay>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Scan,QuickScanIncludeExclusions>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Scan,ScanOnlyIfIdle>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Scan,ThrottleForScheduledScanOnly>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Signature Updates,%dl%ScanOnUpdate>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Signature Updates,%dl%ScheduledSignatureUpdateOnBattery>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Signature Updates,%dl%UpdateOnStartupWithoutEngine>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Signature Updates,ForceUpdateFromMU>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Signature Updates,MeteredConnectionUpdates>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Signature Updates,RealtimeSignatureDelivery>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Signature Updates,ScheduleTime>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Signature Updates,SharedSignatureRootUpdateAtScheduledTimeOnly>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Signature Updates,Signature%dl%Notification>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Signature Updates,SignatureUpdateCatchupInterval>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Signature Updates,UpdateOnStartUp>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\%ss%,ConfigureAppInstallControl>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\%ss%,ConfigureAppInstallControl%el%d>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Spynet,%dl%BlockAtFirstSeen>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Spynet,LocalSettingOverrideSpynetReporting>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Spynet,SpynetReporting>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\Spynet,SubmitSamplesConsent>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\UX Configuration,Notification_Suppress>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\UX Configuration,SuppressRebootNotification>>"%temp%\hklm.list"
echo HKLM:\%spmwd%\UX Configuration,UILockdown>>"%temp%\hklm.list"
echo HKLM:\SOFTWARE\Microsoft\RemovalTools\MpGears,HeartbeatTrackingIndex>>"%temp%\hklm.list"
echo HKLM:\SOFTWARE\WOW6432Node\Classes\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}>>"%temp%\hklm.list"
echo HKLM:\System\CurrentControlSet\Policies\EarlyLaunch,DriverLoadPolicy>>"%temp%\hklm.list"
echo HKLM:\%smw%\%cv%\%evt%AppID/Operational>>"%temp%\hklm.list"
echo HKLM:\%smw%\%cv%\%evt%AppLocker/EXE and DLL>>"%temp%\hklm.list"
echo HKLM:\%smw%\%cv%\%evt%AppLocker/MSI and Script>>"%temp%\hklm.list"
echo HKLM:\%smw%\%cv%\%evt%AppLocker/Packaged app-Deployment>>"%temp%\hklm.list"
echo HKLM:\%smw%\%cv%\%evt%AppLocker/Packaged app-Execution>>"%temp%\hklm.list"
echo HKLM:\%smw%\%cv%\%evt%CodeIntegrity/Operational>>"%temp%\hklm.list"
echo HKLM:\%smw%\%cv%\%evt%DeviceGuard/Operational>>"%temp%\hklm.list"
echo HKLM:\%smw%\%cv%\%evt%Security-Adminless/Operational>>"%temp%\hklm.list"
echo HKLM:\%smw%\%cv%\%evt%Security-Audit-Configuration-Client/Operational>>"%temp%\hklm.list"
echo HKLM:\%smw%\%cv%\%evt%Security-EnterpriseData-FileRevocationManager/Operational>>"%temp%\hklm.list"
echo HKLM:\%smw%\%cv%\%evt%Security-Isolation-BrokeringFileSystem/Operational>>"%temp%\hklm.list"
echo HKLM:\%smw%\%cv%\%evt%Security-LessPrivilegedAppContainer/Operational>>"%temp%\hklm.list"
echo HKLM:\%smw%\%cv%\%evt%Security-Mitigations/KernelMode>>"%temp%\hklm.list"
echo HKLM:\%smw%\%cv%\%evt%Security-Mitigations/UserMode>>"%temp%\hklm.list"
echo HKLM:\%smw%\%cv%\%evt%Security-Netlogon/Operational>>"%temp%\hklm.list"
echo HKLM:\%smw%\%cv%\%evt%Security-SPP-UX-GenuineCenter-Logging/Operational>>"%temp%\hklm.list"
echo HKLM:\%smw%\%cv%\%evt%Security-SPP-UX-Notifications/ActionCenter>>"%temp%\hklm.list"
echo HKLM:\%smw%\%cv%\%evt%Security-UserConsentVerifier/Audit>>"%temp%\hklm.list"
echo HKLM:\%smw%\%cv%\%evt%SecurityMitigationsBroker/Operational>>"%temp%\hklm.list"
echo HKLM:\%smw%\%cv%\%evt%SENSE/Operational>>"%temp%\hklm.list"
echo HKLM:\%smw%\%cv%\%evt%SenseIR/Operational>>"%temp%\hklm.list"
echo HKLM:\%smw%\%cv%\%evt%WDAG-PolicyEvaluator-CSP/Operational>>"%temp%\hklm.list"
echo HKLM:\%smw%\%cv%\%evt%WDAG-PolicyEvaluator-GP/Operational>>"%temp%\hklm.list"
echo HKLM:\%smw%\%cv%\%evt%%wd%/Operational>>"%temp%\hklm.list"
echo HKLM:\%smw%\%cv%\%evt%%wd%/WHC>>"%temp%\hklm.list"
echo HKLM:\%smw%\%cv%\%evt%Windows Firewall With Advanced Security/ConnectionSecurity>>"%temp%\hklm.list"
echo HKLM:\%spm%\Windows\%cv%\Internet Settings\Zones\3,180F>>"%temp%\hklm.list"
echo HKLM:\%spm%\Windows\%cv%\Internet Settings\Lockdown_Zones\3,180F>>"%temp%\hklm.list"
echo HKLM:\%smw%Mitigation,UserPreference>>"%temp%\hklm.list"
echo HKLM:\%scc%\Session Manager\kernel,MitigationAuditOptions>>"%temp%\hklm.list"
echo HKLM:\%scc%\Session Manager\kernel,MitigationOptions>>"%temp%\hklm.list"
echo HKLM:\%scc%\Session Manager\kernel,KernelSEHOP%el%d>>"%temp%\hklm.list"
echo HKLM:\%scc%\Session Manager\kernel,%dl%ExceptionChainValidation>>"%temp%\hklm.list"
echo HKLM:\%scc%\SCMConfig,%el%SvchostMitigationPolicy>>"%temp%\hklm.list"
exit /b 

:LoadUsers
setlocal EnableDelayedExpansion
for /f "tokens=7 delims=\" %%a in ('%rq% "%plist%" ^| %findstr% /R /C:"S-1-5-21-*"') do (
	set "sid=%%a"
	set hive=
	%rq% "HKU\!sid!">nul 2>&1
	if not "!errorlevel!"=="0" set hive=1
	if "!hive!"=="1" for /f "tokens=2,*" %%b in ('%rq% "%plist%\!sid!" /v ProfileImagePath') do set sidpath=%%c
	if "!hive!"=="1" %rl% "HKU\!sid!" "!sidpath!\NTUSER.DAT">nul 2>&1
)
endlocal
exit /b

:WorkUsers
%msg% "Applying settings for users..." "Применение настроек для пользователей..."
for /f "tokens=7 delims=\" %%a in ('%rq% "%plist%" ^| %findstr% /R /C:"S-1-5-21-*"') do (
	%ifdef% Policies call :PoliciesHKU %%a
	%ifdef% Registry call :RegistryHKU %%a
)
exit /b

:UserPolList
echo %smw%\%cv%\Policies\Attachments;SaveZoneInformation;DWORD;^1>"%temp%\%ASN%user.txt"
echo %smw%\%cv%\Policies\Attachments;HideZoneInfoOnProperties;DWORD;^1>>"%temp%\%ASN%user.txt"
echo %smw%\%cv%\Policies\Attachments;ScanWithAntiVirus;DWORD;^1>>"%temp%\%ASN%user.txt"
echo %smw%\%cv%\Policies\Associations;DefaultFileTypeRisk;DWORD;615^2>>"%temp%\%ASN%user.txt"
echo %spm%\Edge;%ss%%el%d;DWORD;^0>>"%temp%\%ASN%user.txt"
echo %spm%\Edge;%ss%Pua%el%d;DWORD;^0>>"%temp%\%ASN%user.txt"
echo %spm%\Edge;PreventOverride;DWORD;^0>>"%temp%\%ASN%user.txt"
echo %spm%\Windows\%cv%\Internet Settings\Zones\3;180F;DWORD;^0>>"%temp%\%ASN%user.txt"
echo %spm%\Windows\%cv%\Internet Settings\Lockdown_Zones\3;180F;DWORD;^0>>"%temp%\%ASN%user.txt"
%ifNdef% Registry goto :EndUserPolList
echo %smw%\%cv%\AppHost;%el%WebContentEvaluation;DWORD;^0>>"%temp%\%ASN%user.txt"
echo %smw%\%cv%\AppHost;PreventOverride;DWORD;^0>>"%temp%\%ASN%user.txt"
echo Software\Microsoft\Edge\%ss%%el%d;@;DWORD;^0>>"%temp%\%ASN%user.txt"
echo Software\Microsoft\Edge\%ss%Pua%el%d;@;DWORD;^0>>"%temp%\%ASN%user.txt"
echo %smw% Security Health\State;AppAndBrowser_Edge%ss%Off;DWORD;^1>>"%temp%\%ASN%user.txt"
echo %smw% Security Health\State;AppAndBrowser_StoreApps%ss%Off;DWORD;^1>>"%temp%\%ASN%user.txt"
echo %smw% Security Health\State;AppAndBrowser_Pua%ss%Off;DWORD;^1>>"%temp%\%ASN%user.txt"
%ifNdef% NotDisableSecHealth echo %smw%\%cv%\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance;%el%d;DWORD;^0>>"%temp%\%ASN%user.txt"
:EndUserPolList
exit /b 

:MachinePolList
echo SOFTWARE\Microsoft\%wd%;DisableAntiSpyware;DWORD;^1>>"%temp%\%ASN%machine.txt"
echo SOFTWARE\Microsoft\%wd%;DisableAntiVirus;DWORD;^1>>"%temp%\%ASN%machine.txt"
echo SOFTWARE\Microsoft\%wd%\Real-Time Protection;DisableRealtimeMonitoring;DWORD;^1>>"%temp%\%ASN%machine.txt"
echo SOFTWARE\Microsoft\%wd%\Real-Time Protection;DpaDisabled;DWORD;^1>>"%temp%\%ASN%machine.txt"
echo SOFTWARE\Microsoft\%wd%\Real-Time Protection;DisableArchiveScanning;DWORD;^1>>"%temp%\%ASN%machine.txt"
echo SOFTWARE\Policies\Microsoft\%wd%;DisableAntiSpyware;DWORD;^1>>"%temp%\%ASN%machine.txt"
echo SOFTWARE\Policies\Microsoft\%wd%;DisableAntiVirus;DWORD;^1>>"%temp%\%ASN%machine.txt"
%ifNdef% ForRestore %ifNdef% Policies goto :EndRealMachinePolList
%ifNdef% NotDisableSecHealth (
	echo %spmwd% Security Center\Account protection;UILockdown;DWORD;^1>>"%temp%\%ASN%machine.txt"
	echo %spmwd% Security Center\Device performance and health;UILockdown;DWORD;^1>>"%temp%\%ASN%machine.txt"
	echo %spmwd% Security Center\Family options;UILockdown;DWORD;^1>>"%temp%\%ASN%machine.txt"
	echo %spmwd% Security Center\Firewall and network protection;UILockdown;DWORD;^1>>"%temp%\%ASN%machine.txt"
	echo %spmwd% Security Center\Notifications;%dl%Notifications;DWORD;^1>>"%temp%\%ASN%machine.txt"
	echo %spmwd%\UX Configuration;UILockdown;DWORD;^1>>"%temp%\%ASN%machine.txt"
	echo %spmwd%\UX Configuration;Notification_Suppress;DWORD;^1>>"%temp%\%ASN%machine.txt"
	echo %spmwd%\UX Configuration;SuppressRebootNotification;DWORD;^1>>"%temp%\%ASN%machine.txt"
)
%ifNdef% NotHideSystray echo %spmwd% Security Center\Systray;HideSystray;DWORD;^1>>"%temp%\%ASN%machine.txt"
%ifdef% DisableCIPolicies echo %spmwd% Security Center\Device security;UILockdown;DWORD;^1>>"%temp%\%ASN%machine.txt"
echo %spmwd% Security Center\App and Browser protection;UILockdown;DWORD;^1>>"%temp%\%ASN%machine.txt"
echo %spmwd% Security Center\Virus and threat protection;UILockdown;DWORD;^1>>"%temp%\%ASN%machine.txt"
echo %spm%\MicrosoftEdge\PhishingFilter;%el%dV9;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %spm%\MicrosoftEdge\PhishingFilter;%el%dV9;SZ;^0>>"%temp%\%ASN%machine.txt"
echo %spm%\MicrosoftEdge\PhishingFilter;PreventOverrideAppRepUnknown;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %spm%\MicrosoftEdge\PhishingFilter;PreventOverrideAppRepUnknown;SZ;^0>>"%temp%\%ASN%machine.txt"
echo %spm%\MRT;DontOfferThroughWUAU;DWORD;^1>"%temp%\%ASN%machine.txt"
echo %spm%\MRT;DontReportInfectionInformation;DWORD;^1>>"%temp%\%ASN%machine.txt"
echo %spm%\Windows\DeviceGuard;%el%VirtualizationBasedSecurity;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %spm%\Windows\DeviceGuard;HVCIMATRequired;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %spm%\Windows\System;%el%%ss%;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %spm%\Windows\WTDS\Components;NotifyMalicious;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %spm%\Windows\WTDS\Components;NotifyPasswordReuse;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %spm%\Windows\WTDS\Components;NotifyUnsafeApp;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %spm%\Windows\WTDS\Components;Service%el%d;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %spm%\Windows\%cv%\Internet Settings\Zones\3;180F;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %spm%\Windows\%cv%\Internet Settings\Lockdown_Zones\3;180F;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %spmwd% Security Center\App and Browser protection;DisallowExploitProtectionOverride;DWORD;^1>>"%temp%\%ASN%machine.txt"
echo %spmwd%;%dl%AntiSpyware;DWORD;^1>>"%temp%\%ASN%machine.txt"
echo %spmwd%;%dl%LocalAdminMerge;DWORD;^1>>"%temp%\%ASN%machine.txt"
echo %spmwd%;%dl%RoutinelyTakingAction;DWORD;^1>>"%temp%\%ASN%machine.txt"
echo %spmwd%;AllowFastServiceStartup;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %spmwd%;PUAProtection;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %spmwd%;RandomizeScheduleTaskTimes;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %spmwd%;ServiceKeepAlive;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %spmwd%\Exclusions;%dl%AutoExclusions;DWORD;^1>>"%temp%\%ASN%machine.txt"
echo %spmwd%\MpEngine;%el%FileHashComputation;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %spmwd%\MpEngine;MpBafsExtendedTimeout;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %spmwd%\MpEngine;MpCloudBlockLevel;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %spmwd%\MpEngine;Mp%el%Pus;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %spmwd%\NIS\Consumers\IPS;%dl%ProtocolRecognition;DWORD;^1>>"%temp%\%ASN%machine.txt"
echo %spmwd%\NIS\Consumers\IPS;%dl%SignatureRetirement;DWORD;^1>>"%temp%\%ASN%machine.txt"
echo %spmwd%\NIS\Consumers\IPS;ThrottleDetectionEventsRate;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %spmwd%\Policy Manager;%dl%ScanningNetworkFiles;DWORD;^1>>"%temp%\%ASN%machine.txt"
echo %spmwd%\Real-Time Protection;%dl%BehaviorMonitoring;DWORD;^1>>"%temp%\%ASN%machine.txt"
echo %spmwd%\Real-Time Protection;%dl%InformationProtectionControl;DWORD;^1>>"%temp%\%ASN%machine.txt"
echo %spmwd%\Real-Time Protection;%dl%IntrusionPreventionSystem;DWORD;^1>>"%temp%\%ASN%machine.txt"
echo %spmwd%\Real-Time Protection;%dl%IOAVProtection;DWORD;^1>>"%temp%\%ASN%machine.txt"
echo %spmwd%\Real-Time Protection;%dl%OnAccessProtection;DWORD;^1>>"%temp%\%ASN%machine.txt"
echo %spmwd%\Real-Time Protection;%dl%RawWriteNotification;DWORD;^1>>"%temp%\%ASN%machine.txt"
echo %spmwd%\Real-Time Protection;%dl%RealtimeMonitoring;DWORD;^1>>"%temp%\%ASN%machine.txt"
echo %spmwd%\Real-Time Protection;%dl%ScanOnRealtime%el%;DWORD;^1>>"%temp%\%ASN%machine.txt"
echo %spmwd%\Real-Time Protection;%dl%ScriptScanning;DWORD;^1>>"%temp%\%ASN%machine.txt"
echo %spmwd%\Real-Time Protection;LocalSettingOverride%dl%BehaviorMonitoring;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %spmwd%\Real-Time Protection;LocalSettingOverride%dl%IntrusionPreventionSystem;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %spmwd%\Real-Time Protection;LocalSettingOverride%dl%IOAVProtection;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %spmwd%\Real-Time Protection;LocalSettingOverride%dl%OnAccessProtection;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %spmwd%\Real-Time Protection;LocalSettingOverride%dl%RealtimeMonitoring;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %spmwd%\Real-Time Protection;LocalSettingOverrideRealtimeScanDirection;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %spmwd%\Real-Time Protection;RealtimeScanDirection;DWORD;^2>>"%temp%\%ASN%machine.txt"
echo %spmwd%\Reporting;%dl%EnhancedNotifications;DWORD;^1>>"%temp%\%ASN%machine.txt"
echo %spmwd%\Reporting;%dl%GenericRePorts;DWORD;^1>>"%temp%\%ASN%machine.txt"
echo %spmwd%\Reporting;WppTracingComponents;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %spmwd%\Reporting;WppTracingLevel;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %spmwd%\Scan;%dl%ArchiveScanning;DWORD;^1>>"%temp%\%ASN%machine.txt"
echo %spmwd%\Scan;%dl%CatchupFullScan;DWORD;^1>>"%temp%\%ASN%machine.txt"
echo %spmwd%\Scan;%dl%CatchupQuickScan;DWORD;^1>>"%temp%\%ASN%machine.txt"
echo %spmwd%\Scan;%dl%EmailScanning;DWORD;^1>>"%temp%\%ASN%machine.txt"
echo %spmwd%\Scan;%dl%Heuristics;DWORD;^1>>"%temp%\%ASN%machine.txt"
echo %spmwd%\Scan;%dl%RemovableDriveScanning;DWORD;^1>>"%temp%\%ASN%machine.txt"
echo %spmwd%\Scan;%dl%ReparsePointScanning;DWORD;^1>>"%temp%\%ASN%machine.txt"
echo %spmwd%\Scan;%dl%RestorePoint;DWORD;^1>>"%temp%\%ASN%machine.txt"
echo %spmwd%\Scan;%dl%ScanningMappedNetworkDrivesForFullScan;DWORD;^1>>"%temp%\%ASN%machine.txt"
echo %spmwd%\Scan;%dl%ScanningNetworkFiles;DWORD;^1>>"%temp%\%ASN%machine.txt"
echo %spmwd%\Scan;LowCpuPriority;DWORD;^1>>"%temp%\%ASN%machine.txt"
echo %spmwd%\Scan;ScanOnlyIfIdle;DWORD;^1>>"%temp%\%ASN%machine.txt"
echo %spmwd%\Signature Updates;%dl%ScanOnUpdate;DWORD;^1>>"%temp%\%ASN%machine.txt"
echo %spmwd%\Signature Updates;%dl%ScheduledSignatureUpdateOnBattery;DWORD;^1>>"%temp%\%ASN%machine.txt"
echo %spmwd%\Signature Updates;%dl%UpdateOnStartupWithoutEngine;DWORD;^1>>"%temp%\%ASN%machine.txt"
echo %spmwd%\Signature Updates;ForceUpdateFromMU;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %spmwd%\Signature Updates;RealtimeSignatureDelivery;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %spmwd%\Signature Updates;ScheduleTime;DWORD;144^0>>"%temp%\%ASN%machine.txt"
echo %spmwd%\Signature Updates;Signature%dl%Notification;DWORD;^1>>"%temp%\%ASN%machine.txt"
echo %spmwd%\Signature Updates;SignatureUpdateCatchupInterval;DWORD;^2>>"%temp%\%ASN%machine.txt"
echo %spmwd%\Signature Updates;UpdateOnStartUp;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %spmwd%\%ss%;ConfigureAppInstallControl;SZ;Anywhere>>"%temp%\%ASN%machine.txt"
echo %spmwd%\%ss%;ConfigureAppInstallControl%el%d;DWORD;^1>>"%temp%\%ASN%machine.txt"
echo %spmwd%\Spynet;%dl%BlockAtFirstSeen;DWORD;^1>>"%temp%\%ASN%machine.txt"
echo %spmwd%\Spynet;LocalSettingOverrideSpynetReporting;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %spmwd%\Spynet;SpynetReporting;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %spmwd%\Spynet;SubmitSamplesConsent;DWORD;^2>>"%temp%\%ASN%machine.txt"
echo %spmwd%\%wd% Exploit Guard\ASR;ExploitGuard_ASR_Rules;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %spmwd%\%wd% Exploit Guard\Controlled Folder Access;%el%ControlledFolderAccess;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %spmwd%\%wd% Exploit Guard\Network Protection;%el%NetworkProtection;DWORD;^0>>"%temp%\%ASN%machine.txt"
:EndRealMachinePolList
%ifNdef% ForRestore %ifNdef% Registry goto :EndRegistryMachinePolList
echo %smw%\%cv%\AppHost;%el%WebContentEvaluation;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %smw%\%cv%\Shell Extensions\Blocked;{09A47860-11B0-4DA5-AFA5-26D86198A780};SZ; >>"%temp%\%ASN%machine.txt"
echo %scl%\exefile\shell\open;No%ss%;SZ; >>"%temp%\%ASN%machine.txt"
echo %scl%\exefile\shell\runas;No%ss%;SZ; >>"%temp%\%ASN%machine.txt"
echo %scl%\exefile\shell\runasuser;No%ss%;SZ; >>"%temp%\%ASN%machine.txt"
%ifNdef% NotDisableSecHealth (
	echo %smwd% Security Center\Notifications;%dl%EnhancedNotifications;DWORD;^1>>"%temp%\%ASN%machine.txt"
	echo %smwd% Security Center\Virus and threat protection;FilesBlockedNotification%dl%d;DWORD;^1>>"%temp%\%ASN%machine.txt"
	echo %smwd% Security Center\Virus and threat protection;NoActionNotification%dl%d;DWORD;^1>>"%temp%\%ASN%machine.txt"
	echo %smwd% Security Center\Virus and threat protection;SummaryNotification%dl%d;DWORD;^1>>"%temp%\%ASN%machine.txt"
)
echo %smwd%;%dl%AntiSpyware;DWORD;^1>>"%temp%\%ASN%machine.txt"
echo %smwd%;%dl%AntiVirus;DWORD;^1>>"%temp%\%ASN%machine.txt"
echo %smwd%;HybridMode%el%d;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %smwd%;PUAProtection;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %smwd%;ProductStatus;DWORD;^2>>"%temp%\%ASN%machine.txt"
echo %smwd%;ProductType;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %smwd%\CoreService;%dl%CoreService1DSTelemetry;DWORD;^1>>"%temp%\%ASN%machine.txt"
echo %smwd%\CoreService;%dl%CoreServiceECSIntegration;DWORD;^1>>"%temp%\%ASN%machine.txt"
echo %smwd%\CoreService;Md%dl%ResController;DWORD;^1>>"%temp%\%ASN%machine.txt"
echo %smwd%\Features;%el%CACS;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %smwd%\Features;Protection;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %smwd%\Features;TamperProtection;DWORD;^4>>"%temp%\%ASN%machine.txt"
echo %smwd%\Features;TamperProtectionSource;DWORD;^2>>"%temp%\%ASN%machine.txt"
echo %smwd%\Features\EcsConfigs;%el%AdsSymlinkMitigation_MpRamp;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %smwd%\Features\EcsConfigs;%el%BmProcessInfoMetastoreMaintenance_MpRamp;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %smwd%\Features\EcsConfigs;%el%CIWorkaroundOnCFA%el%d_MpRamp;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %smwd%\Features\EcsConfigs;Md%dl%ResController;DWORD;^1>>"%temp%\%ASN%machine.txt"
echo %smwd%\Features\EcsConfigs;Mp%dl%PropBagNotification;DWORD;^1>>"%temp%\%ASN%machine.txt"
echo %smwd%\Features\EcsConfigs;Mp%dl%ResourceMonitoring;DWORD;^1>>"%temp%\%ASN%machine.txt"
echo %smwd%\Features\EcsConfigs;Mp%el%NoMetaStoreProcessInfoContainer;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %smwd%\Features\EcsConfigs;Mp%el%PurgeHipsCache;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %smwd%\Features\EcsConfigs;MpFC_AdvertiseLogonMinutesFeature;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %smwd%\Features\EcsConfigs;MpFC_%el%CommonMetricsEvents;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %smwd%\Features\EcsConfigs;MpFC_%el%ImpersonationOnNetworkResourceScan;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %smwd%\Features\EcsConfigs;MpFC_%el%PersistedScanV2;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %smwd%\Features\EcsConfigs;MpFC_Kernel_%el%FolderGuardOnPostCreate;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %smwd%\Features\EcsConfigs;MpFC_Kernel_SystemIoRequestWorkOnBehalfOf;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %smwd%\Features\EcsConfigs;MpFC_Md%dl%1ds;DWORD;^1>>"%temp%\%ASN%machine.txt"
echo %smwd%\Features\EcsConfigs;MpFC_Md%el%CoreService;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %smwd%\Features\EcsConfigs;MpFC_Rtp%el%%df%erConfigMonitoring;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %smwd%\Features\EcsConfigs;MpForceDllHostScanExeOnOpen;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %smwd%\Real-Time Protection;%dl%AsyncScanOnOpen;DWORD;^1>>"%temp%\%ASN%machine.txt"
echo %smwd%\Real-Time Protection;%dl%RealtimeMonitoring;DWORD;^1>>"%temp%\%ASN%machine.txt"
echo %smwd%\Real-Time Protection;Dpa%dl%d;DWORD;^1>>"%temp%\%ASN%machine.txt"
echo %smwd%\Scan;AvgCPULoadFactor;DWORD;^10>>"%temp%\%ASN%machine.txt"
echo %smwd%\Scan;%dl%ArchiveScanning;DWORD;^1>>"%temp%\%ASN%machine.txt"
echo %smwd%\Scan;%dl%EmailScanning;DWORD;^1>>"%temp%\%ASN%machine.txt"
echo %smwd%\Scan;%dl%RemovableDriveScanning;DWORD;^1>>"%temp%\%ASN%machine.txt"
echo %smwd%\Scan;%dl%ScanningMappedNetworkDrivesForFullScan;DWORD;^1>>"%temp%\%ASN%machine.txt"
echo %smwd%\Scan;%dl%ScanningNetworkFiles;DWORD;^1>>"%temp%\%ASN%machine.txt"
echo %smwd%\Scan;LowCpuPriority;DWORD;^1>>"%temp%\%ASN%machine.txt"
echo %smwd%\Spynet;MAPSconcurrency;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %smwd%\Spynet;SpyNetReporting;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %smwd%\Spynet;SubmitSamplesConsent;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %smwd%\Threats\ThreatSeverityDefaultAction;0;DWORD;^9>>"%temp%\%ASN%machine.txt"
echo %smwd%\Threats\ThreatSeverityDefaultAction;1;DWORD;^9>>"%temp%\%ASN%machine.txt"
echo %smwd%\Threats\ThreatSeverityDefaultAction;2;DWORD;^9>>"%temp%\%ASN%machine.txt"
echo %smwd%\Threats\ThreatSeverityDefaultAction;3;DWORD;^9>>"%temp%\%ASN%machine.txt"
echo %smwd%\Threats\ThreatSeverityDefaultAction;4;DWORD;^9>>"%temp%\%ASN%machine.txt"
echo %smwd%\Threats\ThreatSeverityDefaultAction;5;DWORD;^9>>"%temp%\%ASN%machine.txt"
echo SOFTWARE\Microsoft\RemovalTools\MpGears;HeartbeatTrackingIndex;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %smwd%\%wd% Exploit Guard\ASR;%el%ASRConsumers;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %smwd%\%wd% Exploit Guard\Controlled Folder Access;%el%ControlledFolderAccess;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %smwd%\%wd% Exploit Guard\Network Protection;%el%NetworkProtection;DWORD;^0>>"%temp%\%ASN%machine.txt"
%ifNdef% NotDisableSecHealth (echo %smw%\%cv%\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance;%el%d;DWORD;^0>>"%temp%\%ASN%machine.txt")
echo %scc%\CI\Policy;VerifiedAndReputablePolicyState;DWORD;^0>>"%temp%\%ASN%machine.txt"
%ifdef% DisableCIPolicies echo %scc%\CI\Config;VulnerableDriverBlocklistEnable;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %smwd%;SmartLockerMode;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %smwd%;VerifiedAndReputableTrustMode%el%d;DWORD;^0>>"%temp%\%ASN%machine.txt"
%ifNdef% NotDisableSecHealth (echo %smwd% Security Center\Device security;UILockdown;DWORD;^1>>"%temp%\%ASN%machine.txt")
echo %sccd%;%el%VirtualizationBasedSecurity;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %sccd%;RequirePlatformSecurityFeatures;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %sccd%;RequireMicrosoftSignedBootChain;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %sccd%;Locked;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %sccd%\Scenarios\CredentialGuard;%el%d;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %sccd%\Scenarios\HypervisorEnforcedCodeIntegrity;%el%d;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %sccd%\Scenarios\HypervisorEnforcedCodeIntegrity;HVCIMATRequired;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %sccd%\Scenarios\HypervisorEnforcedCodeIntegrity;Locked;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %sccd%\Scenarios\KernelShadowStacks;%el%d;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %sccd%\Scenarios\KernelShadowStacks;AuditMode%el%d;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %sccd%\Scenarios\KernelShadowStacks;Was%el%dBy;DWORD;^4>>"%temp%\%ASN%machine.txt"
echo %scc%\Lsa;LsaCfgFlags;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %scc%\Lsa;RunAsPPL;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %scc%\Lsa;RunAsPPLBoot;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %smw%\%cv%\%evt%%wd%\Operational;%el%d;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %smw%\%cv%\%evt%%wd%\WHC;%el%d;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %scc%\WMI\Autologger\%df%erApiLogger;Start;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %scc%\WMI\Autologger\%df%erAuditLogger;Start;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %smw%\%cv%\Explorer;%ss%%el%d;SZ;Off>>"%temp%\%ASN%machine.txt"
echo %smw%\%cv%\Explorer;Aic%el%d;SZ;Anywhere>>"%temp%\%ASN%machine.txt"
echo %smw%\%cv%\WTDS\Components;Service%el%d;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %smw%\%cv%\WTDS\Components;NotifyUnsafeApp;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %smw%\%cv%\WTDS\Components;NotifyPasswordReuse;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %smw%\%cv%\WTDS\Components;NotifyMalicious;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %smw%\%cv%\WTDS\Components;CaptureThreatWindow;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %smw%\%cv%\WTDS\FeatureFlags;BlockUxDisabled;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %smw%\%cv%\WTDS\FeatureFlags;TelemetryCalls%el%d;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %smw%\Windows Error Reporting;%dl%d;DWORD;^1>>"%temp%\%ASN%machine.txt"
echo %smw%\%cv%\%evt%AppID/Operational;%el%d;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %smw%\%cv%\%evt%AppLocker/EXE and DLL;%el%d;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %smw%\%cv%\%evt%AppLocker/MSI and Script;%el%d;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %smw%\%cv%\%evt%AppLocker/Packaged app-Deployment;%el%d;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %smw%\%cv%\%evt%AppLocker/Packaged app-Execution;%el%d;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %smw%\%cv%\%evt%CodeIntegrity/Operational;%el%d;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %smw%\%cv%\%evt%DeviceGuard/Operational;%el%d;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %smw%\%cv%\%evt%Security-Adminless/Operational;%el%d;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %smw%\%cv%\%evt%Security-Audit-Configuration-Client/Operational;%el%d;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %smw%\%cv%\%evt%Security-EnterpriseData-FileRevocationManager/Operational;%el%d;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %smw%\%cv%\%evt%Security-Isolation-BrokeringFileSystem/Operational;%el%d;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %smw%\%cv%\%evt%Security-LessPrivilegedAppContainer/Operational;%el%d;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %smw%\%cv%\%evt%Security-Mitigations/KernelMode;%el%d;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %smw%\%cv%\%evt%Security-Mitigations/UserMode;%el%d;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %smw%\%cv%\%evt%Security-Netlogon/Operational;%el%d;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %smw%\%cv%\%evt%Security-SPP-UX-GenuineCenter-Logging/Operational;%el%d;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %smw%\%cv%\%evt%Security-SPP-UX-Notifications/ActionCenter;%el%d;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %smw%\%cv%\%evt%Security-UserConsentVerifier/Audit;%el%d;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %smw%\%cv%\%evt%SecurityMitigationsBroker/Operational;%el%d;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %smw%\%cv%\%evt%SENSE/Operational;%el%d;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %smw%\%cv%\%evt%SenseIR/Operational;%el%d;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %smw%\%cv%\%evt%WDAG-PolicyEvaluator-CSP/Operational;%el%d;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %smw%\%cv%\%evt%WDAG-PolicyEvaluator-GP/Operational;%el%d;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %smw%\%cv%\%evt%%wd%/Operational;%el%d;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %smw%\%cv%\%evt%%wd%/WHC;%el%d;DWORD;^0>>"%temp%\%ASN%machine.txt"
echo %smw%\%cv%\%evt%Windows Firewall With Advanced Security/ConnectionSecurity;%el%d;DWORD;^0>>"%temp%\%ASN%machine.txt"
:EndRegistryMachinePolList
%ifNdef% ForRestore %ifNdef% Services goto :EndServicesMachinePolList
for %%s in (Win%df% MDCoreSvc WdNisSvc Sense webthreatdefsvc webthreatdefusersvc WdNisDrv WdBoot WdDevFlt WdFilter MsSecWfp MsSecFlt MsSecCore wtd KslD AppID AppIDSvc applockerfltr) do (echo %scs%\%%~s;Start;DWORD;^4>>"%temp%\%ASN%machine.txt")
%ifNdef% NotDisableSecHealth for %%s in (SecurityHealthService SgrmBroker SgrmAgent) do (echo %scs%\%%~s;Start;DWORD;^4>>"%temp%\%ASN%machine.txt")
%ifNdef% NotDisableSecHealth (%rq% "HKLM\%scs%\wscsvc">nul 2>&1)&&(%ifNdef% NotDisableWscsvc echo %scs%\wscsvc;Start;DWORD;^4>>"%temp%\%ASN%machine.txt")
echo %scs%\WdFilter\Instances\WdFilter Instance;Altitude;SZ;^0>>"%temp%\%ASN%machine.txt"
echo %scs%\Win%df%;Start;DWORD;^4>>"%temp%\%ASN%machine.txt"
echo %scs%\WdBoot;Start;DWORD;^4>>"%temp%\%ASN%machine.txt"
echo %scs%\WdFilter;Start;DWORD;^4>>"%temp%\%ASN%machine.txt"
:EndServicesMachinePolList
%ifNdef% ForRestore %ifNdef% Block goto :EndBlockMachinePolList
echo %smwci%\ConfigSecurityPolicy.exe;Debugger;SZ;dllhost.exe>>"%temp%\%ASN%machine.txt"
echo %smwci%\DlpUserAgent.exe;Debugger;SZ;dllhost.exe>>"%temp%\%ASN%machine.txt"
echo %smwci%\%df%erbootstrapper.exe;Debugger;SZ;dllhost.exe>>"%temp%\%ASN%machine.txt"
echo %smwci%\mpam-d.exe;Debugger;SZ;dllhost.exe>>"%temp%\%ASN%machine.txt"
echo %smwci%\mpam-fe.exe;Debugger;SZ;dllhost.exe>>"%temp%\%ASN%machine.txt"
echo %smwci%\mpam-fe_bd.exe;Debugger;SZ;dllhost.exe>>"%temp%\%ASN%machine.txt"
echo %smwci%\mpas-d.exe;Debugger;SZ;dllhost.exe>>"%temp%\%ASN%machine.txt"
echo %smwci%\mpas-fe.exe;Debugger;SZ;dllhost.exe>>"%temp%\%ASN%machine.txt"
echo %smwci%\mpas-fe_bd.exe;Debugger;SZ;dllhost.exe>>"%temp%\%ASN%machine.txt"
echo %smwci%\mpav-d.exe;Debugger;SZ;dllhost.exe>>"%temp%\%ASN%machine.txt"
echo %smwci%\mpav-fe.exe;Debugger;SZ;dllhost.exe>>"%temp%\%ASN%machine.txt"
echo %smwci%\mpav-fe_bd.exe;Debugger;SZ;dllhost.exe>>"%temp%\%ASN%machine.txt"
echo %smwci%\UpdatePlatform.amd64fre.exe;Debugger;SZ;dllhost.exe>>"%temp%\%ASN%machine.txt"
echo %smwci%\MpCmdRun.exe;Debugger;SZ;dllhost.exe>>"%temp%\%ASN%machine.txt"
echo %smwci%\MpCopyAccelerator.exe;Debugger;SZ;dllhost.exe>>"%temp%\%ASN%machine.txt"
echo %smwci%\Mp%df%erCoreService.exe;Debugger;SZ;dllhost.exe>>"%temp%\%ASN%machine.txt"
echo %smwci%\MpDlpCmd.exe;Debugger;SZ;dllhost.exe>>"%temp%\%ASN%machine.txt"
echo %smwci%\MpDlpService.exe;Debugger;SZ;dllhost.exe>>"%temp%\%ASN%machine.txt"
echo %smwci%\mpextms.exe;Debugger;SZ;dllhost.exe>>"%temp%\%ASN%machine.txt"
echo %smwci%\MpSigStub.exe;Debugger;SZ;dllhost.exe>>"%temp%\%ASN%machine.txt"
echo %smwci%\MsMpEng.exe;Debugger;SZ;dllhost.exe>>"%temp%\%ASN%machine.txt"
echo %smwci%\MsMpEngCP.exe;Debugger;SZ;dllhost.exe>>"%temp%\%ASN%machine.txt"
echo %smwci%\MsSense.exe;Debugger;SZ;dllhost.exe>>"%temp%\%ASN%machine.txt"
echo %smwci%\NisSrv.exe;Debugger;SZ;dllhost.exe>>"%temp%\%ASN%machine.txt"
echo %smwci%\OfflineScannerShell.exe;Debugger;SZ;dllhost.exe>>"%temp%\%ASN%machine.txt"
echo %smwci%\SecureKernel.exe;Debugger;SZ;dllhost.exe>>"%temp%\%ASN%machine.txt"
%ifNdef% NotDisableSecHealth (
	echo %smwci%\SecurityHealthHost.exe;Debugger;SZ;dllhost.exe>>"%temp%\%ASN%machine.txt"
	echo %smwci%\SecurityHealthService.exe;Debugger;SZ;dllhost.exe>>"%temp%\%ASN%machine.txt"
	echo %smwci%\SecurityHealthSystray.exe;Debugger;SZ;dllhost.exe>>"%temp%\%ASN%machine.txt"
	echo %smwci%\SgrmBroker.exe;Debugger;SZ;dllhost.exe>>"%temp%\%ASN%machine.txt"
)
echo %smwci%\SenseAP.exe;Debugger;SZ;dllhost.exe>>"%temp%\%ASN%machine.txt"
echo %smwci%\SenseAPToast.exe;Debugger;SZ;dllhost.exe>>"%temp%\%ASN%machine.txt"
echo %smwci%\SenseCM.exe;Debugger;SZ;dllhost.exe>>"%temp%\%ASN%machine.txt"
echo %smwci%\SenseGPParser.exe;Debugger;SZ;dllhost.exe>>"%temp%\%ASN%machine.txt"
echo %smwci%\SenseIdentity.exe;Debugger;SZ;dllhost.exe>>"%temp%\%ASN%machine.txt"
echo %smwci%\SenseImdsCollector.exe;Debugger;SZ;dllhost.exe>>"%temp%\%ASN%machine.txt"
echo %smwci%\SenseIR.exe;Debugger;SZ;dllhost.exe>>"%temp%\%ASN%machine.txt"
echo %smwci%\SenseNdr.exe;Debugger;SZ;dllhost.exe>>"%temp%\%ASN%machine.txt"
echo %smwci%\SenseSampleUploader.exe;Debugger;SZ;dllhost.exe>>"%temp%\%ASN%machine.txt"
echo %smwci%\SenseTVM.exe;Debugger;SZ;dllhost.exe>>"%temp%\%ASN%machine.txt"
echo %smwci%\SenseCE.exe;Debugger;SZ;dllhost.exe>>"%temp%\%ASN%machine.txt"
echo %smwci%\%ss%.exe;Debugger;SZ;dllhost.exe>>"%temp%\%ASN%machine.txt"
if exist "%sysdir%MRT.exe" echo %smwci%\MRT.exe;Debugger;SZ;dllhost.exe>>"%temp%\%ASN%machine.txt"
:EndBlockMachinePolList
exit /b

:ApplyPol
del /f /q "%temp%\%ASN%pol.ps1">nul 2>&1
chcp 437 >nul 2>&1
%powershell% -MTA -NoP -NoL -NonI -EP Bypass -c "$null|Out-File -FilePath '%temp%\%ASN%pol.ps1' -Encoding UTF8">nul 2>&1
chcp 65001 >nul 2>&1
echo $csharpCode=@'>>"%temp%\%ASN%pol.ps1"
echo using System;using System.Collections.Generic;using System.IO;using System.Text; public class PolRec{public string Key;public string ValueName;public uint Type;public byte[] Data;} public static class PolHandler{ public static List^<PolRec^> Read(string f){ var l=new List^<PolRec^>(); if(!File.Exists(f)^|^|new FileInfo(f).Length^<8)return l; try{ using(var br=new BinaryReader(File.OpenRead(f),Encoding.Unicode)){ if(br.ReadUInt32()!=0x67655250^|^|br.ReadUInt32()!=1)return l; while(br.BaseStream.Position^<br.BaseStream.Length){ if(br.ReadChar()!='[')continue; var r=new PolRec{Key=RS(br)}; if(br.ReadChar()!=';')break; r.ValueName=RS(br); if(br.ReadChar()!=';')break; r.Type=br.ReadUInt32(); if(br.ReadChar()!=';')break; uint sz=br.ReadUInt32(); if(br.ReadChar()!=';')break; if(br.BaseStream.Position+sz^>br.BaseStream.Length)break; r.Data=br.ReadBytes((int)sz); if(br.ReadChar()!=']')break; l.Add(r); } } }catch{} return l; } public static void Write(string f,ICollection^<PolRec^> d){ Directory.CreateDirectory(Path.GetDirectoryName(f)); using(var bw=new BinaryWriter(File.Open(f,FileMode.Create),Encoding.Unicode)){ bw.Write((uint)0x67655250);bw.Write((uint)1); foreach(var r in d){ bw.Write('[');SS(bw,r.Key);bw.Write(';');SS(bw,r.ValueName);bw.Write(';'); bw.Write(r.Type);bw.Write(';');bw.Write((uint)r.Data.Length);bw.Write(';'); bw.Write(r.Data);bw.Write(']'); } } } private static string RS(BinaryReader br){var sb=new StringBuilder();char c;while((c=br.ReadChar())!=0)sb.Append(c);return sb.ToString();} private static void SS(BinaryWriter bw,string v){bw.Write(v.ToCharArray());bw.Write((char)0);} }>>"%temp%\%ASN%pol.ps1"
echo '@>>"%temp%\%ASN%pol.ps1"
echo Add-Type -TypeDefinition $csharpCode -Language CSharp>>"%temp%\%ASN%pol.ps1"
echo $polFile=$env:PolOut>>"%temp%\%ASN%pol.ps1"
echo $policies=[System.Collections.Generic.Dictionary[string,PolRec]]::new([StringComparer]::OrdinalIgnoreCase)>>"%temp%\%ASN%pol.ps1"
echo [PolHandler]::Read($polFile)^|%%{$policies["$($_.Key);$($_.ValueName)"]=$_}>>"%temp%\%ASN%pol.ps1"
echo if($env:PolWork -eq 'Del'){[System.IO.File]::ReadAllLines($env:PolIn)^|?{-not[string]::IsNullOrWhiteSpace($_)}^|%%{$parts=$_.Split(';');$key="$($parts[0]);$($parts[1])";$policies.Remove($key)}}else{[System.IO.File]::ReadAllLines($env:PolIn)^|?{-not[string]::IsNullOrWhiteSpace($_)}^|%%{$parts=$_.Split(';');$key="$($parts[0]);$($parts[1])";$type=$parts[2];$val=$parts[3];$rec=[PolRec]::new();$rec.Key=$parts[0];$rec.ValueName=$parts[1];if($type.Equals("DWORD",4)){$rec.Type=4;$rec.Data=[BitConverter]::GetBytes([uint32]::Parse($val))}else{$rec.Type=1;$rec.Data=[Text.Encoding]::Unicode.GetBytes($val+[char]0)};$policies[$key]=$rec}}>>"%temp%\%ASN%pol.ps1"
echo $finalPolicies=[System.Collections.Generic.List[PolRec]]::new($policies.Values)>>"%temp%\%ASN%pol.ps1"
echo [PolHandler]::Write($polFile,$finalPolicies)>>"%temp%\%ASN%pol.ps1"
exit /b

:Policies
%msg% "Generation of auxiliary policy lists..." "Генерация вспомогательных списков политик..."
call :ApplyPol
call :UserPolList
call :MachinePolList
%msg% "Processing GroupPolicy\User\Registry.pol..." "Обработка GroupPolicy\User\Registry.pol..."
set PolWork=Add
set "PolIn=%temp%\%ASN%user.txt"
set "PolOut=%sysdir%GroupPolicy\User\Registry.pol"
chcp 437 >nul 2>&1
%powershell% -MTA -NoP -NoL -NonI -EP Bypass -f "%temp%\%ASN%pol.ps1">nul 2>&1
chcp 65001 >nul 2>&1
%msg% "Processing GroupPolicy\Machine\Registry.pol..." "Обработка GroupPolicy\Machine\Registry.pol..."
set "PolIn=%temp%\%ASN%machine.txt"
set "PolOut=%sysdir%GroupPolicy\Machine\Registry.pol"
chcp 437 >nul 2>&1
%powershell% -MTA -NoP -NoL -NonI -EP Bypass -f "%temp%\%ASN%pol.ps1">nul 2>&1
chcp 65001 >nul 2>&1
del /f /q "%temp%\%ASN%pol.ps1">nul 2>&1
del /f /q "%temp%\%ASN%user.txt">nul 2>&1
del /f /q "%temp%\%ASN%machine.txt">nul 2>&1
exit /b

:PoliciesHKU
%ra% "HKU\%~1\%smw%\%cv%\Policies\Attachments" /v "SaveZoneInformation" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKU\%~1\%smw%\%cv%\Policies\Attachments" /v "HideZoneInfoOnProperties" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKU\%~1\%smw%\%cv%\Policies\Attachments" /v "ScanWithAntiVirus" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKU\%~1\%smw%\%cv%\Policies\Associations" /v "DefaultFileTypeRisk" /t %dw% /d 6152 /f>nul 2>&1
%ra% "HKU\%~1\%spm%\Edge" /v "%ss%%el%d" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKU\%~1\%spm%\Edge" /v "%ss%Pua%el%d" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKU\%~1\%spm%\Edge" /v "PreventOverride" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKU\%~1%smw%\%cv%\AppHost" /v "%el%WebContentEvaluation" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKU\%~1\%spm%\Windows\%cv%\Internet Settings\Zones\3" /v "180F" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKU\%~1\%spm%\Windows\%cv%\Internet Settings\Lockdown_Zones\3" /v "180F" /t %dw% /d 0 /f>nul 2>&1
exit /b

:PoliciesReg
%msg% "Applying group policies in registry..." "Применение групповых политик в реестре..."
%ra% "HKLM\%smwd%\Features" /v "TamperProtection" /t %dw% /d 4 /f>nul 2>&1
%ra% "HKLM\%smwd%\Features" /v "TamperProtectionSource" /t %dw% /d 2 /f>nul 2>&1 
%ra% "HKLM\%sccd%\Scenarios\HypervisorEnforcedCodeIntegrity" /v "%el%d" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%sccd%" /v "%el%VirtualizationBasedSecurity" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%scc%\CI\Policy" /v "VerifiedAndReputablePolicyState" /t %dw% /d 0 /f>nul 2>&1
%ifdef% DisableCIPolicies %ra% "HKLM\%scc%\CI\Config" /v "VulnerableDriverBlocklistEnable" /t %dw% /d 0 /f>nul 2>&1
call :CheckAV||%ifNdef% SAFEBOOT_OPTION goto :SkipPolReg
%ra% "HKLM\%spmwd%" /v "%dl%AntiSpyware" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM\%spmwd%" /v "%dl%Antivirus" /t %dw% /d 1 /f>nul 2>&1
:SkipPolReg
%ra% "HKLM\%spmwd%" /v "AllowFastServiceStartup" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%spmwd%" /v "%dl%LocalAdminMerge" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM\%spmwd%" /v "%dl%RoutinelyTakingAction" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM\%spmwd%" /v "PUAProtection" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%spmwd%" /v "RandomizeScheduleTaskTimes" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%spmwd%" /v "ServiceKeepAlive" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Device Control" /v "DefaultEnforcement" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Exclusions" /v "%dl%AutoExclusions" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Features" /v "DeviceControl%el%d" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Features" /v "PassiveRemediation" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Features" /v "TDTFeature%el%d" /t %dw% /d 2 /f>nul 2>&1
%ra% "HKLM\%spmwd%\MpEngine" /v "%dl%GradualRelease" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%spmwd%\MpEngine" /v "%el%FileHashComputation" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%spmwd%\MpEngine" /v "MpBafsExtendedTimeout" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%spmwd%\MpEngine" /v "MpCloudBlockLevel" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%spmwd%\MpEngine" /v "Mp%el%Pus" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%spmwd%\NIS" /v "%dl%DatagramProcessing" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM\%spmwd%\NIS" /v "%dl%ProtocolRecognition" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM\%spmwd%\NIS" /v "AllowSwitchToAsyncInspection" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%spmwd%\NIS" /v "%el%ConvertWarnToBlock" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%spmwd%\NIS\Consumers\IPS" /v "%dl%ProtocolRecognition" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM\%spmwd%\NIS\Consumers\IPS" /v "%dl%SignatureRetirement" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM\%spmwd%\NIS\Consumers\IPS" /v "ThrottleDetectionEventsRate" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Policy Manager" /v "%dl%ScanningNetworkFiles" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Real-Time Protection" /v "%dl%AsyncScanOnOpen" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Real-Time Protection" /v "%dl%BehaviorMonitoring" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Real-Time Protection" /v "%dl%InformationProtectionControl" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Real-Time Protection" /v "%dl%IntrusionPreventionSystem" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Real-Time Protection" /v "%dl%IOAVProtection" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Real-Time Protection" /v "%dl%OnAccessProtection" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Real-Time Protection" /v "%dl%RawWriteNotification" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Real-Time Protection" /v "%dl%RealtimeMonitoring" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Real-Time Protection" /v "%dl%ScanOnRealtime%el%" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Real-Time Protection" /v "%dl%ScriptScanning" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Real-Time Protection" /v "IOAVMaxSize" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Real-Time Protection" /v "LocalSettingOverride%dl%BehaviorMonitoring" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Real-Time Protection" /v "LocalSettingOverride%dl%IntrusionPreventionSystem" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Real-Time Protection" /v "LocalSettingOverride%dl%IOAVProtection" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Real-Time Protection" /v "LocalSettingOverride%dl%OnAccessProtection" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Real-Time Protection" /v "LocalSettingOverride%dl%RealtimeMonitoring" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Real-Time Protection" /v "LocalSettingOverrideRealtimeScanDirection" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Real-Time Protection" /v "Oobe%el%RtpAndSigUpdate" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Real-Time Protection" /v "RealtimeScanDirection" /t %dw% /d 2 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Spynet" /v "%dl%BlockAtFirstSeen" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Spynet" /v "LocalSettingOverrideSpynetReporting" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Spynet" /v "SpynetReporting" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Spynet" /v "SubmitSamplesConsent" /t %dw% /d 2 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Signature Updates" /v "%dl%ScanOnUpdate" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Signature Updates" /v "%dl%ScheduledSignatureUpdateOnBattery" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Signature Updates" /v "%dl%UpdateOnStartupWithoutEngine" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Signature Updates" /v "ForceUpdateFromMU" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Signature Updates" /v "MeteredConnectionUpdates" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Signature Updates" /v "RealtimeSignatureDelivery" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Signature Updates" /v "ScheduleTime" /t %dw% /d 1440 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Signature Updates" /v "SharedSignatureRootUpdateAtScheduledTimeOnly" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Signature Updates" /v "Signature%dl%Notification" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Signature Updates" /v "SignatureUpdateCatchupInterval" /t %dw% /d 2 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Signature Updates" /v "UpdateOnStartUp" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Remediation\Behavioral Network Blocks\Brute Force Protection" /v "BruteForceProtectionConfiguredState" /t %dw% /d 4 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Remediation\Behavioral Network Blocks\Remote Encryption Protection" /v "RemoteEncryptionProtectionConfiguredState" /t %dw% /d 4 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Reporting" /v "%dl%EnhancedNotifications" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Reporting" /v "%dl%GenericRePorts" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Reporting" /v "%el%DynamicSignatureDroppedEventReporting" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Reporting" /v "WppTracingComponents" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Reporting" /v "WppTracingLevel" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Scan" /v "%dl%ArchiveScanning" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Scan" /v "%dl%CatchupFullScan" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Scan" /v "%dl%CatchupQuickScan" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Scan" /v "%dl%EmailScanning" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Scan" /v "%dl%Heuristics" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Scan" /v "%dl%PackedExeScanning" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Scan" /v "%dl%RemovableDriveScanning" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Scan" /v "%dl%ReparsePointScanning" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Scan" /v "%dl%RestorePoint" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Scan" /v "%dl%ScanningMappedNetworkDrivesForFullScan" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Scan" /v "%dl%ScanningNetworkFiles" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Scan" /v "AllowPause" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Scan" /v "ArchiveMaxDepth" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Scan" /v "ArchiveMaxSize" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Scan" /v "AvgCPULoadFactor" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Scan" /v "CheckForSignaturesBeforeRunningScan" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Scan" /v "LocalSettingOverrideAvgCPULoadFactor" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Scan" /v "LocalSettingOverrideScanParameters" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Scan" /v "LocalSettingOverrideScheduleDay" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Scan" /v "LocalSettingOverrideScheduleQuickScanTime" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Scan" /v "LocalSettingOverrideScheduleTime" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Scan" /v "LowCpuPriority" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Scan" /v "PurgeItemsAfterDelay" /t %dw% /d 30 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Scan" /v "QuickScanIncludeExclusions" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Scan" /v "ScanOnlyIfIdle" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM\%spmwd%\Scan" /v "ThrottleForScheduledScanOnly" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%spmwd%\%wd% Exploit Guard\ASR" /v "ExploitGuard_ASR_Rules" /t %dw% /d 0 /f>nul 2>&1
%rd% "HKLM\%spmwd%\%wd% Exploit Guard\ASR" /v "ExploitGuard_ASR_ASROnlyPerRuleExclusions" /f>nul 2>&1
%ra% "HKLM\%spmwd%\%wd% Exploit Guard\Controlled Folder Access" /v "%el%ControlledFolderAccess" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%spmwd%\%wd% Exploit Guard\Network Protection" /v "%el%NetworkProtection" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%spmwd% Security Center\App and Browser protection" /v "DisallowExploitProtectionOverride" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM\%spm%\Edge" /v "%ss%%el%d" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%spm%\Edge" /v "PreventOverride" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%spm%\MicrosoftEdge\PhishingFilter" /v "%el%dV9" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%spm%\MicrosoftEdge\PhishingFilter" /v "PreventOverride" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%spm%\MicrosoftEdge\PhishingFilter" /v "PreventOverrideAppRepUnknown" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%spm%\Windows\System" /v "%el%%ss%" /t %dw% /d 0 /f>nul 2>&1
%rd% "HKLM\%spm%\Windows\System" /v "Shell%ss%Level" /f>nul 2>&1
%ra% "HKLM\%spmwd%\%ss%" /v "ConfigureAppInstallControl%el%d" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM\%spmwd%\%ss%" /v "ConfigureAppInstallControl" /t %sz% /d "Anywhere" /f>nul 2>&1
%ra% "HKLM\%spm%\Windows\WTDS\Components" /v "Service%el%d" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%spm%\Windows\WTDS\Components" /v "NotifyUnsafeApp" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%spm%\Windows\WTDS\Components" /v "NotifyMalicious" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%spm%\Windows\WTDS\Components" /v "NotifyPasswordReuse" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%spm%\Windows\WTDS\Components" /v "CaptureThreatWindow" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%spm%\Windows\DeviceGuard" /v "DeployConfigCIPolicy" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%spm%\Windows\DeviceGuard" /v "%el%VirtualizationBasedSecurity" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%spm%\Windows\DeviceGuard" /v "HVCIMATRequired" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%spm%\Windows\DeviceGuard" /v "HypervisorEnforcedCodeIntegrity" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%spm%\Windows\DeviceGuard" /v "LsaCfgFlags" /t %dw% /d 0 /f>nul 2>&1
%rd% "HKLM\%spm%\Windows\DeviceGuard" /v "ConfigCIPolicyFilePath" /f>nul 2>&1
%rd% "HKLM\%spm%\Windows\DeviceGuard" /v "ConfigureKernelShadowStacksLaunch" /f>nul 2>&1
%rd% "HKLM\%spm%\Windows\DeviceGuard" /v "MachineIdentityIsolation" /f>nul 2>&1
%ra% "HKLM\%spm%\Windows\System" /v "RunAsPPL" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%spm%\Windows\%cv%\Internet Settings\Zones\3" /v "180F" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%spm%\Windows\%cv%\Internet Settings\Lockdown_Zones\3" /v "180F" /t %dw% /d 0 /f>nul 2>&1
%ifNdef% NotDisableSecHealth (
	%msg% "Hide some security pages..." "Скрытие некоторых страниц безопасности..."
	%ra% "HKLM\%spmwd% Security Center\Account protection" /v "UILockdown" /t %dw% /d 1 /f>nul 2>&1	
	%ra% "HKLM\%spmwd% Security Center\Device performance and health" /v "UILockdown" /t %dw% /d 1 /f>nul 2>&1
	%ra% "HKLM\%spmwd% Security Center\Family options" /v "UILockdown" /t %dw% /d 1 /f>nul 2>&1
	%ra% "HKLM\%spmwd% Security Center\Firewall and network protection" /v "UILockdown" /t %dw% /d 1 /f>nul 2>&1
	%ra% "HKLM\%spmwd% Security Center\Notifications" /v "%dl%Notifications" /t %dw% /d 1 /f>nul 2>&1
	%ra% "HKLM\%spmwd%\UX Configuration" /v "UILockdown" /t %dw% /d 1 /f>nul 2>&1
	%ra% "HKLM\%spmwd%\UX Configuration" /v "Notification_Suppress" /t %dw% /d 1 /f>nul 2>&1
	%ra% "HKLM\%spmwd%\UX Configuration" /v "SuppressRebootNotification" /t %dw% /d 1 /f>nul 2>&1
)
%ifNdef% NotHideSystray %ra% "HKLM\%spmwd% Security Center\Systray" /v "HideSystray" /t %dw% /d 1 /f>nul 2>&1
%ifdef% DisableCIPolicies %ra% "HKLM\%spmwd% Security Center\Device security" /v "UILockdown" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM\%spmwd% Security Center\App and Browser protection" /v "UILockdown" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM\%spmwd% Security Center\Virus and threat protection" /v "UILockdown" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM\%spm%\MRT" /v "DontOfferThroughWUAU" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM\%spm%\MRT" /v "DontReportInfectionInformation" /t %dw% /d 1 /f>nul 2>&1

%ra% "HKLM\%smw%\%cv%\Policies\System\Audit" /v "ProcessCreationIncludeCmdLine_%el%d" /t %dw% /d 0 /f>nul 2>&1

%ra% "HKLM\System\CurrentControlSet\Policies\EarlyLaunch" /v "DriverLoadPolicy" /t %dw% /d 7 /f>nul 2>&1
%ifdef% NotDisableSecHealth goto :EndHideSetting
%msg% "Hide some settings..." "Скрытие некоторых настроек..."
set "HidePath=HKLM\%smw%\%cv%\Policies\Explorer"
%rq% "%HidePath%" /v "SettingsPageVisibility">nul 2>&1||(%ra% "%HidePath%" /v "SettingsPageVisibility" /t %sz% /d "hide:windows%df%er" /f>nul 2>&1&goto :EndHideSetting)
for /f "tokens=2*" %%a in ('%rq% "%HidePath%" /v "SettingsPageVisibility" 2^>nul') do set "SettingsPageVisibility=%%b"
if "%SettingsPageVisibility%"==";" set SettingsPageVisibility=
if "%SettingsPageVisibility%"=="hide:" set SettingsPageVisibility=
%ifNdef% SettingsPageVisibility %ra% "%HidePath%" /v "SettingsPageVisibility" /t %sz% /d "hide:windows%df%er" /f>nul 2>&1
echo %SettingsPageVisibility% | %find% /i "windows%df%er">nul 2>&1&&goto :EndHideSetting
%ra% "%HidePath%" /v "SettingsPageVisibility" /t %sz% /d "%SettingsPageVisibility%;windows%df%er" /f>nul 2>&1
:EndHideSetting
exit /b

:TasksDisable
%msg% "Disabling tasks in the scheduler..." "Отключение заданий в планировщике..."
%schtasks% /Change /TN "Microsoft\Windows\%wd%\%wd% Cache Maintenance" /%dl%>nul 2>&1
%schtasks% /Change /TN "Microsoft\Windows\%wd%\%wd% Cleanup" /%dl%>nul 2>&1
%schtasks% /Change /TN "Microsoft\Windows\%wd%\%wd% Scheduled Scan" /%dl%>nul 2>&1
%schtasks% /Change /TN "Microsoft\Windows\%wd%\%wd% Verification" /%dl%>nul 2>&1
%schtasks% /Change /TN "Microsoft\Windows\%wd%\%wd% Update" /%dl%>nul 2>&1
%schtasks% /Change /TN "Microsoft\Windows\AppID\%ss%Specific" /%dl%>nul 2>&1
%schtasks% /Change /TN "Microsoft\Windows\AppID\PolicyConverter" /%dl%>nul 2>&1
%schtasks% /Change /TN "Microsoft\Windows\AppID\VerifiedPublisherCertStoreCheck" /%dl%>nul 2>&1
%schtasks% /Change /TN "Microsoft\Windows\ExploitGuard\ExploitGuard MDM policy Refresh" /%dl%>nul 2>&1
%schtasks% /Change /TN "Microsoft\Windows\Windows Error Reporting\QueueReporting" /%dl%>nul 2>&1
exit /b

:TasksForReDisabling
%msg% "Adding tasks to the scheduler for re-disabling after updates..." "Добавление заданий в планировщик для пере-отключения после обновлений..."
%schtasks% /Query 2>nul | %findstr% /C:"ReDisabling %df%er">nul 2>&1&&(chcp 437 >nul 2>&1&%powershell% -MTA -NoP -NoL -NonI -EP Bypass -c "Get-ScheduledTask -TaskPath \"\ReDisabling %df%er\*\" | Unregister-ScheduledTask -Confirm:$false">nul 2>&1&chcp 65001 >nul 2>&1)
%schtasks% /Delete /tn "ReDisabling %df%er\Events" /f>nul 2>&1
%schtasks% /Delete /tn "ReDisabling %df%er\Tasks" /f>nul 2>&1
%schtasks% /Delete /tn "ReDisabling %df%er" /f>nul 2>&1                
%schtasks% /Create /tn "ReDisabling %df%er\Group Policies Update"                                             /tr "powershell.exe -NoP -Wi H -C gpupdate /force" /sc onlogon /ru "NT SERVICE\TrustedInstaller" /rl HIGHEST /f>nul 2>&1
%schtasks% /Create /tn "ReDisabling %df%er\Smartscreen ReDisable"                                             /tr "reg.exe delete \"HKLM\%scl%\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}\" /f" /sc ONSTART /ru "NT SERVICE\TrustedInstaller" /rl HIGHEST /f>nul 2>&1 
%schtasks% /Create /tn "ReDisabling %df%er\Tasks\%wd% Cache Maintenance"                                      /tr "schtasks /change /tn \"Microsoft\Windows\%wd%\%wd% Cache Maintenance\" /disable" /sc ONSTART /ru "NT SERVICE\TrustedInstaller" /rl HIGHEST /f>nul 2>&1
%schtasks% /Create /tn "ReDisabling %df%er\Tasks\%wd% Cleanup"                                                /tr "schtasks /change /tn \"Microsoft\Windows\%wd%\%wd% Cleanup\" /disable"           /sc ONSTART /ru "NT SERVICE\TrustedInstaller" /rl HIGHEST /f>nul 2>&1
%schtasks% /Create /tn "ReDisabling %df%er\Tasks\%wd% Scheduled Scan"                                         /tr "schtasks /change /tn \"Microsoft\Windows\%wd%\%wd% Scheduled Scan\" /disable"    /sc ONSTART /ru "NT SERVICE\TrustedInstaller" /rl HIGHEST /f>nul 2>&1
%schtasks% /Create /tn "ReDisabling %df%er\Tasks\%wd% Verification"                                           /tr "schtasks /change /tn \"Microsoft\Windows\%wd%\%wd% Verification\" /disable"      /sc ONSTART /ru "NT SERVICE\TrustedInstaller" /rl HIGHEST /f>nul 2>&1
%schtasks% /Create /tn "ReDisabling %df%er\Tasks\%wd% Update"                                                 /tr "schtasks /change /tn \"Microsoft\Windows\%wd%\%wd% Update\" /disable"            /sc ONSTART /ru "NT SERVICE\TrustedInstaller" /rl HIGHEST /f>nul 2>&1
%schtasks% /Create /tn "ReDisabling %df%er\Tasks\AppID SmartscreenSpecific"                                   /tr "schtasks /change /tn \"Microsoft\Windows\AppID\SmartscreenSpecific\" /disable"                           /sc ONSTART /ru "NT SERVICE\TrustedInstaller" /rl HIGHEST /f>nul 2>&1
%schtasks% /Create /tn "ReDisabling %df%er\Tasks\AppID PolicyConverter"                                       /tr "schtasks /change /tn \"Microsoft\Windows\AppID\PolicyConverter\" /disable"                               /sc ONSTART /ru "NT SERVICE\TrustedInstaller" /rl HIGHEST /f>nul 2>&1
%schtasks% /Create /tn "ReDisabling %df%er\Tasks\AppID VerifiedPublisherCertStoreCheck"                       /tr "schtasks /change /tn \"Microsoft\Windows\AppID\VerifiedPublisherCertStoreCheck\" /disable"               /sc ONSTART /ru "NT SERVICE\TrustedInstaller" /rl HIGHEST /f>nul 2>&1
%schtasks% /Create /tn "ReDisabling %df%er\Tasks\ExploitGuard MDM policy Refresh OFF"                         /tr "schtasks /change /tn \"Microsoft\Windows\ExploitGuard\ExploitGuard MDM policy Refresh\" /disable"        /sc ONSTART /ru "NT SERVICE\TrustedInstaller" /rl HIGHEST /f>nul 2>&1
%schtasks% /Create /tn "ReDisabling %df%er\Tasks\Windows Error Reporting QueueReporting"                      /tr "schtasks /change /tn \"Microsoft\Windows\Windows Error Reporting\QueueReporting\" /disable"              /sc ONSTART /ru "NT SERVICE\TrustedInstaller" /rl HIGHEST /f>nul 2>&1
%schtasks% /Create /tn "ReDisabling %df%er\Events\AppID Operational"                                          /tr "reg.exe add \"HKLM\%smw%\%cv%\%evt%AppID/Operational\" /v \"%el%d\" /t %dw% /d 0 /f" /sc ONSTART /ru "NT SERVICE\TrustedInstaller" /rl HIGHEST /f>nul 2>&1
%schtasks% /Create /tn "ReDisabling %df%er\Events\AppLocker EXE and DLL"                                      /tr "reg.exe add \"HKLM\%smw%\%cv%\%evt%AppLocker/EXE and DLL\" /v \"%el%d\" /t %dw% /d 0 /f" /sc ONSTART /ru "NT SERVICE\TrustedInstaller" /rl HIGHEST /f>nul 2>&1
%schtasks% /Create /tn "ReDisabling %df%er\Events\AppLocker MSI and Script"                                   /tr "reg.exe add \"HKLM\%smw%\%cv%\%evt%AppLocker/MSI and Script\" /v \"%el%d\" /t %dw% /d 0 /f" /sc ONSTART /ru "NT SERVICE\TrustedInstaller" /rl HIGHEST /f>nul 2>&1
%schtasks% /Create /tn "ReDisabling %df%er\Events\AppLocker Packaged app-Deployment"                          /tr "reg.exe add \"HKLM\%smw%\%cv%\%evt%AppLocker/Packaged app-Deployment\" /v \"%el%d\" /t %dw% /d 0 /f" /sc ONSTART /ru "NT SERVICE\TrustedInstaller" /rl HIGHEST /f>nul 2>&1
%schtasks% /Create /tn "ReDisabling %df%er\Events\AppLocker Packaged app-Execution"                           /tr "reg.exe add \"HKLM\%smw%\%cv%\%evt%AppLocker/Packaged app-Execution\" /v \"%el%d\" /t %dw% /d 0 /f" /sc ONSTART /ru "NT SERVICE\TrustedInstaller" /rl HIGHEST /f>nul 2>&1
%schtasks% /Create /tn "ReDisabling %df%er\Events\CodeIntegrity Operational"                                  /tr "reg.exe add \"HKLM\%smw%\%cv%\%evt%CodeIntegrity/Operational\" /v \"%el%d\" /t %dw% /d 0 /f" /sc ONSTART /ru "NT SERVICE\TrustedInstaller" /rl HIGHEST /f>nul 2>&1
%schtasks% /Create /tn "ReDisabling %df%er\Events\DeviceGuard Operational"                                    /tr "reg.exe add \"HKLM\%smw%\%cv%\%evt%DeviceGuard/Operational\" /v \"%el%d\" /t %dw% /d 0 /f" /sc ONSTART /ru "NT SERVICE\TrustedInstaller" /rl HIGHEST /f>nul 2>&1
%schtasks% /Create /tn "ReDisabling %df%er\Events\Security-Adminless Operational"                             /tr "reg.exe add \"HKLM\%smw%\%cv%\%evt%Security-Adminless/Operational\" /v \"%el%d\" /t %dw% /d 0 /f" /sc ONSTART /ru "NT SERVICE\TrustedInstaller" /rl HIGHEST /f>nul 2>&1
%schtasks% /Create /tn "ReDisabling %df%er\Events\Security-Audit-Configuration-Client Operational"            /tr "reg.exe add \"HKLM\%smw%\%cv%\%evt%Security-Audit-Configuration-Client/Operational\" /v \"%el%d\" /t %dw% /d 0 /f" /sc ONSTART /ru "NT SERVICE\TrustedInstaller" /rl HIGHEST /f>nul 2>&1
%schtasks% /Create /tn "ReDisabling %df%er\Events\Security-EnterpriseData-FileRevocationManager Operational"  /tr "reg.exe add \"HKLM\%smw%\%cv%\%evt%Security-EnterpriseData-FileRevocationManager/Operational\" /v \"%el%d\" /t %dw% /d 0 /f" /sc ONSTART /ru "NT SERVICE\TrustedInstaller" /rl HIGHEST /f>nul 2>&1
%schtasks% /Create /tn "ReDisabling %df%er\Events\Security-Isolation-BrokeringFileSystem Operational"         /tr "reg.exe add \"HKLM\%smw%\%cv%\%evt%Security-Isolation-BrokeringFileSystem/Operational\" /v \"%el%d\" /t %dw% /d 0 /f" /sc ONSTART /ru "NT SERVICE\TrustedInstaller" /rl HIGHEST /f>nul 2>&1
%schtasks% /Create /tn "ReDisabling %df%er\Events\Security-LessPrivilegedAppContainer Operational"            /tr "reg.exe add \"HKLM\%smw%\%cv%\%evt%Security-LessPrivilegedAppContainer/Operational\" /v \"%el%d\" /t %dw% /d 0 /f" /sc ONSTART /ru "NT SERVICE\TrustedInstaller" /rl HIGHEST /f>nul 2>&1
%schtasks% /Create /tn "ReDisabling %df%er\Events\Security-Mitigations KernelMode"                            /tr "reg.exe add \"HKLM\%smw%\%cv%\%evt%Security-Mitigations/KernelMode\" /v \"%el%d\" /t %dw% /d 0 /f" /sc ONSTART /ru "NT SERVICE\TrustedInstaller" /rl HIGHEST /f>nul 2>&1
%schtasks% /Create /tn "ReDisabling %df%er\Events\Security-Mitigations UserMode"                              /tr "reg.exe add \"HKLM\%smw%\%cv%\%evt%Security-Mitigations/UserMode\" /v \"%el%d\" /t %dw% /d 0 /f" /sc ONSTART /ru "NT SERVICE\TrustedInstaller" /rl HIGHEST /f>nul 2>&1
%schtasks% /Create /tn "ReDisabling %df%er\Events\Security-Netlogon Operational"                              /tr "reg.exe add \"HKLM\%smw%\%cv%\%evt%Security-Netlogon/Operational\" /v \"%el%d\" /t %dw% /d 0 /f" /sc ONSTART /ru "NT SERVICE\TrustedInstaller" /rl HIGHEST /f>nul 2>&1
%schtasks% /Create /tn "ReDisabling %df%er\Events\Security-SPP-UX-GenuineCenter-Logging Operational"          /tr "reg.exe add \"HKLM\%smw%\%cv%\%evt%Security-SPP-UX-GenuineCenter-Logging/Operational\" /v \"%el%d\" /t %dw% /d 0 /f" /sc ONSTART /ru "NT SERVICE\TrustedInstaller" /rl HIGHEST /f>nul 2>&1
%schtasks% /Create /tn "ReDisabling %df%er\Events\Security-SPP-UX-Notifications ActionCenter"                 /tr "reg.exe add \"HKLM\%smw%\%cv%\%evt%Security-SPP-UX-Notifications/ActionCenter\" /v \"%el%d\" /t %dw% /d 0 /f" /sc ONSTART /ru "NT SERVICE\TrustedInstaller" /rl HIGHEST /f>nul 2>&1
%schtasks% /Create /tn "ReDisabling %df%er\Events\Security-UserConsentVerifier Audit"                         /tr "reg.exe add \"HKLM\%smw%\%cv%\%evt%Security-UserConsentVerifier/Audit\" /v \"%el%d\" /t %dw% /d 0 /f" /sc ONSTART /ru "NT SERVICE\TrustedInstaller" /rl HIGHEST /f>nul 2>&1
%schtasks% /Create /tn "ReDisabling %df%er\Events\SecurityMitigationsBroker Operational"                      /tr "reg.exe add \"HKLM\%smw%\%cv%\%evt%SecurityMitigationsBroker/Operational\" /v \"%el%d\" /t %dw% /d 0 /f" /sc ONSTART /ru "NT SERVICE\TrustedInstaller" /rl HIGHEST /f>nul 2>&1
%schtasks% /Create /tn "ReDisabling %df%er\Events\SENSE Operational"                                          /tr "reg.exe add \"HKLM\%smw%\%cv%\%evt%SENSE/Operational\" /v \"%el%d\" /t %dw% /d 0 /f" /sc ONSTART /ru "NT SERVICE\TrustedInstaller" /rl HIGHEST /f>nul 2>&1
%schtasks% /Create /tn "ReDisabling %df%er\Events\SenseIR Operational"                                        /tr "reg.exe add \"HKLM\%smw%\%cv%\%evt%SenseIR/Operational\" /v \"%el%d\" /t %dw% /d 0 /f" /sc ONSTART /ru "NT SERVICE\TrustedInstaller" /rl HIGHEST /f>nul 2>&1
%schtasks% /Create /tn "ReDisabling %df%er\Events\WDAG-PolicyEvaluator-CSP Operational"                       /tr "reg.exe add \"HKLM\%smw%\%cv%\%evt%WDAG-PolicyEvaluator-CSP/Operational\" /v \"%el%d\" /t %dw% /d 0 /f" /sc ONSTART /ru "NT SERVICE\TrustedInstaller" /rl HIGHEST /f>nul 2>&1
%schtasks% /Create /tn "ReDisabling %df%er\Events\WDAG-PolicyEvaluator-GP Operational"                        /tr "reg.exe add \"HKLM\%smw%\%cv%\%evt%WDAG-PolicyEvaluator-GP/Operational\" /v \"%el%d\" /t %dw% /d 0 /f" /sc ONSTART /ru "NT SERVICE\TrustedInstaller" /rl HIGHEST /f>nul 2>&1
%schtasks% /Create /tn "ReDisabling %df%er\Events\%wd% Operational"                                           /tr "reg.exe add \"HKLM\%smw%\%cv%\%evt%%wd%/Operational\" /v \"%el%d\" /t %dw% /d 0 /f" /sc ONSTART /ru "NT SERVICE\TrustedInstaller" /rl HIGHEST /f>nul 2>&1
%schtasks% /Create /tn "ReDisabling %df%er\Events\%wd% WHC"                                                   /tr "reg.exe add \"HKLM\%smw%\%cv%\%evt%%wd%/WHC\" /v \"%el%d\" /t %dw% /d 0 /f" /sc ONSTART /ru "NT SERVICE\TrustedInstaller" /rl HIGHEST /f>nul 2>&1
%schtasks% /Create /tn "ReDisabling %df%er\Events\Windows Firewall With Advanced Security ConnectionSecurity" /tr "reg.exe add \"HKLM\%smw%\%cv%\%evt%Windows Firewall With Advanced Security/ConnectionSecurity\" /v \"%el%d\" /t %dw% /d 0 /f" /sc ONSTART /ru "NT SERVICE\TrustedInstaller" /rl HIGHEST /f>nul 2>&1
echo @echo off >"%sysdir%Re%dl%%df%er.cmd"
echo chcp 65001 >>"%sysdir%Re%dl%%df%er.cmd"
echo set df=Defend>>"%sysdir%Re%dl%%df%er.cmd"
echo set dl=Disable>>"%sysdir%Re%dl%%df%er.cmd"
%ifdef% NotDisableSecHealth  echo set "procs='MsMpEng.exe','MsMpEngCP.exe','NisSrv.exe','smartscreen.exe','MsSense.exe','MpCmdRun.exe','Mp%%df%%erCoreService.exe'">>"%sysdir%Re%dl%%df%er.cmd"
%ifNdef% NotDisableSecHealth echo set "procs='SecurityHealthService.exe','SecurityHealthHost.exe','SecHealthUI.exe','SecurityHealthSystray.exe','MsMpEng.exe','MsMpEngCP.exe','NisSrv.exe','smartscreen.exe','MsSense.exe','MpCmdRun.exe','Mp%%df%%erCoreService.exe'">>"%sysdir%Re%dl%%df%er.cmd"
%ifdef% NotDisableSecHealth  echo set "servs='Win%%df%%','MDCoreSvc','MsSecCore','WdNisSvc','Sense','SgrmBroker','webthreatdefsvc','webthreatdefusersvc','WdNisDrv','WdBoot','WdDevFlt','WdFilter','SgrmAgent','MsSecWfp','MsSecFlt','wtd','KslD','AppID','AppIDSvc','applockerfltr','wscsvc'">>"%sysdir%Re%dl%%df%er.cmd"
%ifNdef% NotDisableSecHealth echo set "servs='SecurityHealthService','Win%%df%%','MDCoreSvc','MsSecCore','WdNisSvc','Sense','SgrmBroker','webthreatdefsvc','webthreatdefusersvc','WdNisDrv','WdBoot','WdDevFlt','WdFilter','SgrmAgent','MsSecWfp','MsSecFlt','wtd','KslD','AppID','AppIDSvc','applockerfltr','wscsvc'">>"%sysdir%Re%dl%%df%er.cmd"
echo powershell -MTA -NoP -NoL -NonI -EP Bypass -c "$procs = %%procs%%; $servs = %%servs%%; foreach ($p in $procs) {gwmi -Query \"SELECT * FROM win32_process WHERE Name='$p'\" | ForEach-Object { $_.Terminate() } };foreach ($s in $servs) { Get-WmiObject Win32_Service -Filter \"Name='$s'\" | ForEach-Object { $_.StopService() } };foreach ($p in $procs) {gwmi -Query \"SELECT * FROM win32_process WHERE Name='$p'\" | ForEach-Object { $_.Terminate() } }; foreach ($s in $servs) { Get-WmiObject Win32_Service -Filter \"Name='$s'\" | ForEach-Object { $_.StopService() } }">>"%sysdir%Re%dl%%df%er.cmd"
%ifNdef% NotDisableSecHealth echo for %%%%s in (SecurityHealthService.exe SecurityHealthHost.exe SecurityHealthSystray.exe SecHealthUI.exe MsMpEng.exe MsMpEngCP.exe NisSrv.exe smartscreen.exe MsSense.exe MpCmdRun.exe Mp%%df%%erCoreService.exe) do taskkill /im %%%%~s /t /f>>"%sysdir%Re%dl%%df%er.cmd"
%ifdef% NotDisableSecHealth  echo for %%%%s in (MsMpEng.exe MsMpEngCP.exe NisSrv.exe smartscreen.exe MsSense.exe MpCmdRun.exe Mp%%df%%erCoreService.exe) do taskkill /im %%%%~s /t /f>>"%sysdir%Re%dl%%df%er.cmd"
%ifNdef% NotDisableSecHealth echo for %%%%s in (webthreatdefsvc webthreatdefusersvc wtd AppID AppIDSvc applockerfltr wscsvc) do sc stop %%%%~s>>"%sysdir%Re%dl%%df%er.cmd"
%ifdef% NotDisableSecHealth  echo for %%%%s in (SecurityHealthService webthreatdefsvc webthreatdefusersvc wtd AppID AppIDSvc applockerfltr wscsvc) do sc stop %%%%~s>>"%sysdir%Re%dl%%df%er.cmd"
echo reg add "HKLM\SOFTWARE\Microsoft\Windows %%df%%er" /v "%%dl%%AntiSpyware" /t REG_DWORD /d 1 /f>>"%sysdir%Re%dl%%df%er.cmd"
echo reg add "HKLM\SOFTWARE\Microsoft\Windows %%df%%er" /v "%%dl%%AntiVirus" /t REG_DWORD /d 1 /f>>"%sysdir%Re%dl%%df%er.cmd"
echo reg add "HKLM\SOFTWARE\Microsoft\Windows %%df%%er" /v "HybridModeEnabled" /t REG_DWORD /d 0 /f>>"%sysdir%Re%dl%%df%er.cmd"
echo reg delete "HKLM\SOFTWARE\Microsoft\Windows %%df%%er" /v "IsServiceRunning" /f>>"%sysdir%Re%dl%%df%er.cmd"
echo reg add "HKLM\SOFTWARE\Microsoft\Windows %%df%%er" /v "PUAProtection" /t REG_DWORD /d 0 /f>>"%sysdir%Re%dl%%df%er.cmd"
echo reg add "HKLM\SOFTWARE\Microsoft\Windows %%df%%er" /v "ProductStatus" /t REG_DWORD /d 2 /f>>"%sysdir%Re%dl%%df%er.cmd"
echo reg add "HKLM\SOFTWARE\Microsoft\Windows %%df%%er" /v "ProductType" /t REG_DWORD /d 0 /f>>"%sysdir%Re%dl%%df%er.cmd"
echo reg add "HKLM\SOFTWARE\Microsoft\Windows %%df%%er\Features" /v "Protection" /t REG_DWORD /d 0 /f>>"%sysdir%Re%dl%%df%er.cmd"
echo reg add "HKLM\SOFTWARE\Microsoft\Windows %%df%%er\Features" /v "TamperProtection" /t REG_DWORD /d 4 /f>>"%sysdir%Re%dl%%df%er.cmd"
echo reg add "HKLM\SOFTWARE\Microsoft\Windows %%df%%er\Features" /v "TamperProtectionSource" /t REG_DWORD /d 2 /f>>"%sysdir%Re%dl%%df%er.cmd"
echo reg add "HKLM\SOFTWARE\Microsoft\Windows %%df%%er\Real-Time Protection" /v "%%dl%%RealtimeMonitoring" /t REG_DWORD /d 1 /f>>"%sysdir%Re%dl%%df%er.cmd"
echo reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows %%df%%er" /v "%%dl%%AntiSpyware" /t REG_DWORD /d 1 /f>>"%sysdir%Re%dl%%df%er.cmd"
echo reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows %%df%%er" /v "%%dl%%Antivirus" /t REG_DWORD /d 1 /f>>"%sysdir%Re%dl%%df%er.cmd"
echo reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows %%df%%er" /v "PUAProtection" /t REG_DWORD /d 0 /f>>"%sysdir%Re%dl%%df%er.cmd"
echo reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows %%df%%er\Real-Time Protection" /v "%%dl%%AsyncScanOnOpen" /t REG_DWORD /d 0 /f>>"%sysdir%Re%dl%%df%er.cmd"
echo reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows %%df%%er\Real-Time Protection" /v "%%dl%%BehaviorMonitoring" /t REG_DWORD /d 1 /f>>"%sysdir%Re%dl%%df%er.cmd"
echo reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows %%df%%er\Real-Time Protection" /v "%%dl%%InformationProtectionControl" /t REG_DWORD /d 1 /f>>"%sysdir%Re%dl%%df%er.cmd"
echo reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows %%df%%er\Real-Time Protection" /v "%%dl%%IntrusionPreventionSystem" /t REG_DWORD /d 1 /f>>"%sysdir%Re%dl%%df%er.cmd"
echo reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows %%df%%er\Real-Time Protection" /v "%%dl%%IOAVProtection" /t REG_DWORD /d 1 /f>>"%sysdir%Re%dl%%df%er.cmd"
echo reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows %%df%%er\Real-Time Protection" /v "%%dl%%OnAccessProtection" /t REG_DWORD /d 1 /f>>"%sysdir%Re%dl%%df%er.cmd"
echo reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows %%df%%er\Real-Time Protection" /v "%%dl%%RawWriteNotification" /t REG_DWORD /d 1 /f>>"%sysdir%Re%dl%%df%er.cmd"
echo reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows %%df%%er\Real-Time Protection" /v "%%dl%%RealtimeMonitoring" /t REG_DWORD /d 1 /f>>"%sysdir%Re%dl%%df%er.cmd"
echo reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows %%df%%er\Real-Time Protection" /v "%%dl%%ScanOnRealtimeEnable" /t REG_DWORD /d 1 /f>>"%sysdir%Re%dl%%df%er.cmd"
echo reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows %%df%%er\Real-Time Protection" /v "%%dl%%ScriptScanning" /t REG_DWORD /d 1 /f>>"%sysdir%Re%dl%%df%er.cmd"
echo reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows %%df%%er\Real-Time Protection" /v "RealtimeScanDirection" /t REG_DWORD /d 2 /f>>"%sysdir%Re%dl%%df%er.cmd"
%ifNdef% NotResetPlatform if [%build%] geq [22000] echo "%sys%:\Program Files\%wd%\MpCmdRun.exe" -ResetPlatform>>"%sysdir%Re%dl%%df%er.cmd"
%ifdef% Services echo for %%%%s in (Win%%df%% MDCoreSvc MsSecCore WdNisSvc Sense webthreatdefsvc webthreatdefusersvc WdNisDrv WdBoot WdDevFlt WdFilter MsSecWfp MsSecFlt wtd KslD AppID AppIDSvc applockerfltr) do reg query "HKLM\SYSTEM\CurrentControlSet\Services\%%%%~s"^&^&reg add "HKLM\SYSTEM\CurrentControlSet\Services\%%%%~s" /v "Start" /t REG_DWORD /d 4 /f>>"%sysdir%Re%dl%%df%er.cmd"
%ifdef% Services %ifNdef% NotDisableSecHealth %ifNdef% NotDisableWscsvc echo for %%%%s in (SecurityHealthService SgrmBroker SgrmAgent wscsvc) do reg query "HKLM\SYSTEM\CurrentControlSet\Services\%%%%~s"^&^&reg add "HKLM\SYSTEM\CurrentControlSet\Services\%%%%~s" /v "Start" /t REG_DWORD /d 4 /f>>"%sysdir%Re%dl%%df%er.cmd"
%ifdef% Services %ifNdef% NotDisableSecHealth %ifdef% NotDisableWscsvc echo for %%%%s in (SecurityHealthService SgrmBroker SgrmAgent) do reg query "HKLM\SYSTEM\CurrentControlSet\Services\%%%%~s"^&^&reg add "HKLM\SYSTEM\CurrentControlSet\Services\%%%%~s" /v "Start" /t REG_DWORD /d 4 /f>>"%sysdir%Re%dl%%df%er.cmd"
%ifNdef% DisableCIPolicies goto :SkipReDisableCI
echo set "efi=">>"%sysdir%Re%dl%%df%er.cmd"
echo for %%%%a in (Z Y X W V U T S R Q P O N M L K J I H G F E D) do if not exist %%%%a:\nul set "efi=%%%%a:"^&goto :FoundFreeDiskCI>>"%sysdir%Re%dl%%df%er.cmd"
echo :FoundFreeDiskCI>>"%sysdir%Re%dl%%df%er.cmd"
echo if defined efi (>>"%sysdir%Re%dl%%df%er.cmd"
echo	mountvol %%efi%% /s >>"%sysdir%Re%dl%%df%er.cmd"
echo	md "%%efi%%\EFI\Microsoft\Boot\CIPolicies\%%dl%%d">>"%sysdir%Re%dl%%df%er.cmd"
%ifdef% DisablePkcsPolicies echo	move /y "%%efi%%\EFI\Microsoft\Boot\*.p7b" "%%efi%%\EFI\Microsoft\Boot\CIPolicies\%%dl%%d\">>"%sysdir%Re%dl%%df%er.cmd"
echo	move /y "%%efi%%\EFI\Microsoft\Boot\CIPolicies\Active\*.cip" "%%efi%%\EFI\Microsoft\Boot\CIPolicies\%%dl%%d\">>"%sysdir%Re%dl%%df%er.cmd"
echo	mountvol %%efi%% /d >>"%sysdir%Re%dl%%df%er.cmd"
echo ) >>"%sysdir%Re%dl%%df%er.cmd"
echo md "%sysdir%CodeIntegrity\CIPolicies\%%dl%%d">>"%sysdir%Re%dl%%df%er.cmd"
%ifdef% DisablePkcsPolicies echo move /y "%sysdir%CodeIntegrity\*.p7b" "%sysdir%CodeIntegrity\CIPolicies\%%dl%%d\" >>"%sysdir%Re%dl%%df%er.cmd"
%ifdef% DisablePkcsPolicies echo bcdedit ^| find "hypervisorlaunchtype    Auto" ^&^& set hyperv^=1 ^|^| set "hyperv^=">>"%sysdir%Re%dl%%df%er.cmd"
%ifdef% DisablePkcsPolicies echo if defined hyperv move /y "%sysdir%CodeIntegrity\CIPolicies\%%dl%%d\VbsSiPolicy.p7b" "%sysdir%CodeIntegrity\" >>"%sysdir%Re%dl%%df%er.cmd"
echo move /y "%sysdir%CodeIntegrity\CIPolicies\Active\*.cip" "%sysdir%CodeIntegrity\CIPolicies\%%dl%%d\">>"%sysdir%Re%dl%%df%er.cmd"
echo move /y "%sysdir%CodeIntegrity\CIPolicies\%%dl%%d\{60FD87F8-4593-44A0-91B0-2E0DA022F248}.cip" "%sysdir%CodeIntegrity\CIPolicies\Active">>"%sysdir%Re%dl%%df%er.cmd"
:SkipReDisableCI
echo set "UWP=chxapp">>"%sysdir%Re%dl%%df%er.cmd"
echo set UwpName=>>"%sysdir%Re%dl%%df%er.cmd"
echo reg query "%uwpsearch%" /f "*%%UWP%%*" /k^&^&for /f "tokens=2" %%%%a in ('reg query "%uwpsearch%" /f "*%%UWP%%*" /k^^^|^^^|goto :EndSearchBlockUWPchxapp') do (set "UwpName=%%%%~nxa"^&goto :EndSearchBlockUWPchxapp)>>"%sysdir%Re%dl%%df%er.cmd"
echo :EndSearchBlockUWPchxapp>>"%sysdir%Re%dl%%df%er.cmd"
echo if not defined UwpName goto :EndBlockUWPchxapp>>"%sysdir%Re%dl%%df%er.cmd"
echo reg add "HKLM\%smw%\%cv%\Appx\AppxAllUserStore\Deprovisioned\%%UwpName%%" /f>>"%sysdir%Re%dl%%df%er.cmd"
echo reg add "HKLM\%smw%\%cv%\Appx\AppxAllUserStore\EndOfLife\S-1-5-18\%%UwpName%%" /f>>"%sysdir%Re%dl%%df%er.cmd"
echo for /f "tokens=*" %%%%a in ('reg query "HKLM\%smw%\%cv%\Appx\AppxAllUserStore" ^^^| findstr /R /C:"S-1-5-21-*"') do (>>"%sysdir%Re%dl%%df%er.cmd"
echo 	reg add "HKLM\%smw%\%cv%\Appx\AppxAllUserStore\EndOfLife\%%%%~nxa\%%UwpName%%" /f>>"%sysdir%Re%dl%%df%er.cmd"
echo 	reg add "HKLM\%smw%\%cv%\Appx\AppxAllUserStore\Deleted\EndOfLife\%%%%~nxa\%%UwpName%%" /f>>"%sysdir%Re%dl%%df%er.cmd"
echo ) >>"%sysdir%Re%dl%%df%er.cmd"
echo :EndBlockUWPchxapp>>"%sysdir%Re%dl%%df%er.cmd"
%ifdef% NotDisableSecHealth goto :SkipReDisableSecHealth
echo set "UWP=sechealth">>"%sysdir%Re%dl%%df%er.cmd"
echo set UwpName= >>"%sysdir%Re%dl%%df%er.cmd"
echo reg query "%uwpsearch%" /f "*%%UWP%%*" /k^&^&for /f "tokens=2" %%%%a in ('reg query "%uwpsearch%" /f "*%%UWP%%*" /k^^^|^^^|goto :EndSearchBlockUWPsechealth') do (set "UwpName=%%%%~nxa"^&goto :EndSearchBlockUWPsechealth)>>"%sysdir%Re%dl%%df%er.cmd"
echo :EndSearchBlockUWPsechealth>>"%sysdir%Re%dl%%df%er.cmd"
echo if not defined UwpName goto :EndBlockUWPsechealth>>"%sysdir%Re%dl%%df%er.cmd"
echo reg add "HKLM\%smw%\%cv%\Appx\AppxAllUserStore\Deprovisioned\%%UwpName%%" /f>>"%sysdir%Re%dl%%df%er.cmd"
echo reg add "HKLM\%smw%\%cv%\Appx\AppxAllUserStore\EndOfLife\S-1-5-18\%%UwpName%%" /f>>"%sysdir%Re%dl%%df%er.cmd"
echo for /f "tokens=*" %%%%a in ('reg query "HKLM\%smw%\%cv%\Appx\AppxAllUserStore" ^^^| findstr /R /C:"S-1-5-21-*"') do (>>"%sysdir%Re%dl%%df%er.cmd"
echo 	reg add "HKLM\%smw%\%cv%\Appx\AppxAllUserStore\EndOfLife\%%%%~nxa\%%UwpName%%" /f>>"%sysdir%Re%dl%%df%er.cmd"
echo 	reg add "HKLM\%smw%\%cv%\Appx\AppxAllUserStore\Deleted\EndOfLife\%%%%~nxa\%%UwpName%%" /f>>"%sysdir%Re%dl%%df%er.cmd"
echo ) >>"%sysdir%Re%dl%%df%er.cmd"
echo :EndBlockUWPsechealth>>"%sysdir%Re%dl%%df%er.cmd"
:SkipReDisableSecHealth
%schtasks% /Create /tn "ReDisabling %df%er\Re%dl%%df%erCmd" /tr "cmd.exe /c \"%sysdir%Re%dl%%df%er.cmd\"" /sc onstart /ru "NT SERVICE\TrustedInstaller" /rl HIGHEST /f >nul 2>&1
exit /b

:RegistryHKU
%ra% "HKU\%~1\%smw%\%cv%\AppHost" /v "%el%WebContentEvaluation" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKU\%~1\%smw%\%cv%\AppHost" /v "PreventOverride" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKU\%~1\Software\Microsoft\Edge\%ss%%el%d" /ve /t %dw%  /d "0" /f>nul 2>&1
%ra% "HKU\%~1\Software\Microsoft\Edge\%ss%Pua%el%d" /ve /t %dw%  /d "0" /f>nul 2>&1
%ra% "HKU\%~1\%smw% Security Health\State" /v "AppAndBrowser_Edge%ss%Off" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKU\%~1\%smw% Security Health\State" /v "AppAndBrowser_StoreApps%ss%Off" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKU\%~1\%smw% Security Health\State" /v "AppAndBrowser_Pua%ss%Off" /t %dw% /d 1 /f>nul 2>&1
%ifNdef% NotDisableSecHealth %ra% "HKU\%~1\%smw%\%cv%\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance" /v "%el%d" /t %dw% /d 0 /f>nul 2>&1
exit /b

:ASRdel
set "ASRs="
set "ASRd="
set /a ASRn=0
for /f "tokens=1" %%i in ('%rq% "HKLM\%smwd%\%wd% Exploit Guard\ASR\Rules" 2^>nul ^| %findstr% /B /C:"    "') do call :addrule "%%i"
if %ASRn% gtr 0 %msg% "Disabling attack surface reduction rules ASR..." "Отключение правил сокращения направлений атак ASR..."
chcp 437 >nul 2>&1
if %ASRn% gtr 0 %powershell% -MTA -NoP -NoL -NonI -EP Bypass -c "%sp% -AttackSurfaceReductionRules_Ids %ASRs% -AttackSurfaceReductionRules_Actions %ASRd%">nul 2>&1
chcp 65001 >nul 2>&1
exit /b

:addrule
%rd% "HKLM\%smwd%\%wd% Exploit Guard\ASR\Rules" /v "%~1" /f>nul 2>&1
%ifdef% ASRs (set "ASRs=%ASRs%,%~1"&set "ASRd=%ASRd%,Disabled"&set /a ASRn+=1)
%ifNdef% ASRs (set "ASRs=%~1"&set "ASRd=Disabled"&set /a ASRn=1)
exit /b

:UnregDll
%msg% "Unregistering security libraries..." "Отмена регистрaции библиотек безопасности..."
start "" %regsvr32% /u "%sys%:\Program Files\%wd%\shellext.dll" /s>nul 2>&1
start "" %regsvr32% /u "%sys%:\Program Files\%wd%\AMMonitoringProvider.dll" /s>nul 2>&1
start "" %regsvr32% /u "%sys%:\Program Files\%wd%\%df%CSP.dll" /s>nul 2>&1
start "" %regsvr32% /u "%sys%:\Program Files\%wd%\MpOAV.dll" /s>nul 2>&1
start "" %regsvr32% /u "%sys%:\Program Files\%wd%\MpProvider.dll" /s>nul 2>&1
start "" %regsvr32% /u "%sys%:\Program Files\%wd%\MpUxAgent.dll" /s>nul 2>&1
start "" %regsvr32% /u "%sys%:\Program Files\%wd%\MsMpCom.dll" /s>nul 2>&1
start "" %regsvr32% /u "%sys%:\Program Files\%wd%\ProtectionManagement.dll" /s>nul 2>&1
start "" %regsvr32% /u "%sys%:\Program Files\%wd% Advanced Threat Protection\Classification\cmicarabicwordbreaker.dll" /s>nul 2>&1
start "" %regsvr32% /u "%sys%:\Program Files\%wd% Advanced Threat Protection\Classification\korwbrkr.dll" /s>nul 2>&1
start "" %regsvr32% /u "%sys%:\Program Files\%wd% Advanced Threat Protection\Classification\mce.dll" /s>nul 2>&1
start "" %regsvr32% /u "%sys%:\Program Files\%wd% Advanced Threat Protection\Classification\upe.dll" /s>nul 2>&1
start "" %regsvr32% /u "%sysdir%%ss%ps.dll" /s>nul 2>&1
start "" %regsvr32% /u "%sysdir%ieapfltr.dll" /s>nul 2>&1
start "" %regsvr32% /u "%sysdir%ThreatResponseEngine.dll" /s>nul 2>&1
start "" %regsvr32% /u "%sysdir%webthreatdefsvc.dll" /s>nul 2>&1
if exist "%ProgramData%\Microsoft\%wd%\Platform" for /d %%D in ("%ProgramData%\Microsoft\%wd%\Platform\*") do (
	start "" %regsvr32% /u "%%D\shellext.dll" /s>nul 2>&1
	start "" %regsvr32% /u "%%D\AMMonitoringProvider.dll" /s>nul 2>&1
	start "" %regsvr32% /u "%%D\%df%CSP.dll" /s>nul 2>&1
	start "" %regsvr32% /u "%%D\MpOAV.dll" /s>nul 2>&1
	start "" %regsvr32% /u "%%D\MpProvider.dll" /s>nul 2>&1
	start "" %regsvr32% /u "%%D\MpUxAgent.dll" /s>nul 2>&1
	start "" %regsvr32% /u "%%D\MsMpCom.dll" /s>nul 2>&1
	start "" %regsvr32% /u "%%D\ProtectionManagement.dll" /s>nul 2>&1
)
if exist "%ProgramData%\Microsoft\%wd% Advanced Threat Protection\Platform" for /d %%D in ("%ProgramData%\Microsoft\%wd% Advanced Threat Protection\Platform\*") do (
	start "" %regsvr32% /u "%%D\cmicarabicwordbreaker.dll" /s>nul 2>&1
	start "" %regsvr32% /u "%%D\korwbrkr.dll" /s>nul 2>&1
	start "" %regsvr32% /u "%%D\mce.dll" /s>nul 2>&1
	start "" %regsvr32% /u "%%D\upe.dll" /s>nul 2>&1
)
%ifdef% NotDisableSecHealth goto :SkipHealthDll
start "" %regsvr32% /u "%sysdir%SecurityHealthAgent.dll" /s>nul 2>&1
start "" %regsvr32% /u "%sysdir%SecurityHealthProxyStub.dll" /s>nul 2>&1
if exist "%sysdir%SecurityHealth" for /d %%D in ("%sysdir%SecurityHealth\*") do (
  start "" %regsvr32% /u "%%D\SecurityHealthAgent.dll" /s>nul 2>&1
  start "" %regsvr32% /u "%%D\SecurityHealthProxyStub.dll" /s>nul 2>&1
)
%ifNdef% NotDisableWscsvc start "" %regsvr32% /u "%sysdir%SecurityCenterBrokerPS.dll" /s>nul 2>&1
:SkipHealthDll
if exist %regsvr% start "" %regsvr% /u "%syswow%\%ss%ps.dll" /s>nul 2>&1
if exist %regsvr% start "" %regsvr% /u "%syswow%\ieapfltr.dll" /s>nul 2>&1
exit /b

:Registry
%msg% "Applying registry settings..." "Применение настроек реестра..."
%ra% "HKLM\%smw%\%cv%\AppHost" /v "%el%WebContentEvaluation" /t %dw% /d 0 /f>nul 2>&1

%rd% "HKLM\%smw%\%cv%\Shell Extensions\Approved" /v "{09A47860-11B0-4DA5-AFA5-26D86198A780}" /f>nul 2>&1
%ra% "HKLM\%smw%\%cv%\Shell Extensions\Blocked" /v "{09A47860-11B0-4DA5-AFA5-26D86198A780}" /t %sz% /d "" /f>nul 2>&1

%ra% "HKLM\%scl%\exefile\shell\open" /v "No%ss%" /t %sz% /d "" /f>nul 2>&1
%ra% "HKLM\%scl%\exefile\shell\runas" /v "No%ss%" /t %sz% /d "" /f>nul 2>&1
%ra% "HKLM\%scl%\exefile\shell\runasuser" /v "No%ss%" /t %sz% /d "" /f>nul 2>&1

%ifNdef% NotDisableSecHealth (
	%ra% "HKLM\%smwd% Security Center\Notifications" /v "%dl%EnhancedNotifications" /t %dw% /d 1 /f>nul 2>&1
	%ra% "HKLM\%smwd% Security Center\Virus and threat protection" /v "FilesBlockedNotification%dl%d" /t %dw% /d 1 /f>nul 2>&1
	%ra% "HKLM\%smwd% Security Center\Virus and threat protection" /v "NoActionNotification%dl%d" /t %dw% /d 1 /f>nul 2>&1
	%ra% "HKLM\%smwd% Security Center\Virus and threat protection" /v "SummaryNotification%dl%d" /t %dw% /d 1 /f>nul 2>&1
)
call :CheckAV||%ifNdef% SAFEBOOT_OPTION goto :SkipRegAV
%ra% "HKLM\%smwd%" /v "%dl%AntiSpyware" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM\%smwd%" /v "%dl%AntiVirus" /t %dw% /d 1 /f>nul 2>&1
:SkipRegAV
%ra% "HKLM\%smwd%" /v "HybridMode%el%d" /t %dw% /d 0 /f>nul 2>&1
%rd% "HKLM\%smwd%" /v "IsServiceRunning" /f>nul 2>&1
%ra% "HKLM\%smwd%" /v "PUAProtection" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%smwd%" /v "ProductStatus" /t %dw% /d 2 /f>nul 2>&1
%ra% "HKLM\%smwd%" /v "ProductType" /t %dw% /d 0 /f>nul 2>&1
%rq% "HKLM\%smwd%\CoreService">nul 2>&1||goto :SkipCoreService
%ra% "HKLM\%smwd%\CoreService" /v "%dl%CoreService1DSTelemetry" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM\%smwd%\CoreService" /v "%dl%CoreServiceECSIntegration" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM\%smwd%\CoreService" /v "Md%dl%ResController" /t %dw% /d 1 /f>nul 2>&1
:SkipCoreService
%ra% "HKLM\%smwd%\Features" /v "%el%CACS" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%smwd%\Features" /v "Protection" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%smwd%\Features" /v "TamperProtection" /t %dw% /d 4 /f>nul 2>&1
%ra% "HKLM\%smwd%\Features" /v "TamperProtectionSource" /t %dw% /d 2 /f>nul 2>&1
%ra% "HKLM\%smwd%\Features" /v "MpPlatformKillbitsFromEngine" /t REG_BINARY /d "0000000000000000" /f>nul 2>&1
%ra% "HKLM\%smwd%\Features" /v "MpCapability" /t REG_BINARY /d "0000000000000000" /f>nul 2>&1
%rq% "HKLM\%smwd%\EcsConfigs">nul 2>&1||goto :SkipEcsConfigs
%ra% "HKLM\%smwd%\Features\EcsConfigs" /v "%el%AdsSymlinkMitigation_MpRamp" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%smwd%\Features\EcsConfigs" /v "%el%BmProcessInfoMetastoreMaintenance_MpRamp" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%smwd%\Features\EcsConfigs" /v "%el%CIWorkaroundOnCFA%el%d_MpRamp" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%smwd%\Features\EcsConfigs" /v "Md%dl%ResController" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM\%smwd%\Features\EcsConfigs" /v "Mp%dl%PropBagNotification" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM\%smwd%\Features\EcsConfigs" /v "Mp%dl%ResourceMonitoring" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM\%smwd%\Features\EcsConfigs" /v "Mp%el%NoMetaStoreProcessInfoContainer" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%smwd%\Features\EcsConfigs" /v "Mp%el%PurgeHipsCache" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%smwd%\Features\EcsConfigs" /v "MpFC_AdvertiseLogonMinutesFeature" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%smwd%\Features\EcsConfigs" /v "MpFC_%el%CommonMetricsEvents" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%smwd%\Features\EcsConfigs" /v "MpFC_%el%ImpersonationOnNetworkResourceScan" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%smwd%\Features\EcsConfigs" /v "MpFC_%el%PersistedScanV2" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%smwd%\Features\EcsConfigs" /v "MpFC_Kernel_%el%FolderGuardOnPostCreate" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%smwd%\Features\EcsConfigs" /v "MpFC_Kernel_SystemIoRequestWorkOnBehalfOf" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%smwd%\Features\EcsConfigs" /v "MpFC_Md%dl%1ds" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM\%smwd%\Features\EcsConfigs" /v "MpFC_Md%el%CoreService" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%smwd%\Features\EcsConfigs" /v "MpFC_Rtp%el%%df%erConfigMonitoring" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%smwd%\Features\EcsConfigs" /v "MpForceDllHostScanExeOnOpen" /t %dw% /d 0 /f>nul 2>&1
:SkipEcsConfigs
%ra% "HKLM\%smwd%\Real-Time Protection" /v "%dl%AsyncScanOnOpen" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM\%smwd%\Real-Time Protection" /v "%dl%RealtimeMonitoring" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM\%smwd%\Real-Time Protection" /v "Dpa%dl%d" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM\%smwd%\Scan" /v "AvgCPULoadFactor" /t %dw% /d "10" /f>nul 2>&1
%ra% "HKLM\%smwd%\Scan" /v "%dl%ArchiveScanning" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM\%smwd%\Scan" /v "%dl%EmailScanning" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM\%smwd%\Scan" /v "%dl%RemovableDriveScanning" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM\%smwd%\Scan" /v "%dl%ScanningMappedNetworkDrivesForFullScan" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM\%smwd%\Scan" /v "%dl%ScanningNetworkFiles" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM\%smwd%\Scan" /v "LowCpuPriority" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM\%smwd%\Spynet" /v "MAPSconcurrency" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%smwd%\Spynet" /v "SpyNetReporting" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%smwd%\Spynet" /v "SpyNetReportingLocation" /t %msz% /d "https://0.0.0.0" /f>nul 2>&1
%ra% "HKLM\%smwd%\Spynet" /v "SubmitSamplesConsent" /t %dw% /d 0 /f>nul 2>&1
%rd% "HKLM\%smwd%\Threats\ThreatIDDefaultAction" /f>nul 2>&1
%ra% "HKLM\%smwd%\Threats\ThreatSeverityDefaultAction" /v "0" /t %dw% /d 9 /f>nul 2>&1
%ra% "HKLM\%smwd%\Threats\ThreatSeverityDefaultAction" /v "1" /t %dw% /d 9 /f>nul 2>&1
%ra% "HKLM\%smwd%\Threats\ThreatSeverityDefaultAction" /v "2" /t %dw% /d 9 /f>nul 2>&1
%ra% "HKLM\%smwd%\Threats\ThreatSeverityDefaultAction" /v "3" /t %dw% /d 9 /f>nul 2>&1
%ra% "HKLM\%smwd%\Threats\ThreatSeverityDefaultAction" /v "4" /t %dw% /d 9 /f>nul 2>&1
%ra% "HKLM\%smwd%\Threats\ThreatSeverityDefaultAction" /v "5" /t %dw% /d 9 /f>nul 2>&1
%rd% "HKLM\%smwd%\Threats\ThreatTypeDefaultAction" /f>nul 2>&1
%ra% "HKLM\SOFTWARE\Microsoft\RemovalTools\MpGears" /v "HeartbeatTrackingIndex" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%smwd%\%wd% Exploit Guard\ASR" /v "%el%ASRConsumers" /t %dw% /d 0 /f>nul 2>&1
%rd% "HKLM\%smwd%\%wd% Exploit Guard\ASR\Rules" /f>nul 2>&1
%ra% "HKLM\%smwd%\%wd% Exploit Guard\Controlled Folder Access" /v "%el%ControlledFolderAccess" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%smwd%\%wd% Exploit Guard\Network Protection" /v "%el%NetworkProtection" /t %dw% /d 0 /f>nul 2>&1

%ifNdef% NotDisableSecHealth (%rq% "HKLM\%smw%\%cv%\Run" /v "SecurityHealth">nul 2>&1)&&(
	%rd% "HKLM\%smw%\%cv%\Run" /v "SecurityHealth" /f>nul 2>&1
	%ra% "HKLM\%smw%\%cv%\Run\Autoruns%dl%d" /v "SecurityHealth" /t REG_EXPAND_SZ /d "^%windir^%\system32\SecurityHealthSystray.exe" /f>nul 2>&1
	%ra% "HKLM\%smw%\%cv%\Explorer\StartupApproved\Run" /v "SecurityHealth" /t REG_BINARY /d "FFFFFFFFFFFFFFFFFFFFFFFF" /f>nul 2>&1
)

%ifNdef% NotDisableSecHealth (%ra% "HKLM\%smw%\%cv%\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance" /v "%el%d" /t %dw% /d 0 /f>nul 2>&1)

%ra% "HKLM\%scc%\CI\Policy" /v "VerifiedAndReputablePolicyState" /t %dw% /d 0 /f>nul 2>&1
%ifdef% DisableCIPolicies %ra% "HKLM\%scc%\CI\Config" /v "VulnerableDriverBlocklistEnable" /t %dw% /d 0 /f>nul 2>&1
%rd% "HKLM\%scc%\CI\State" /f>nul 2>&1
%ra% "HKLM\%smwd%" /v "SmartLockerMode" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%smwd%" /v "VerifiedAndReputableTrustMode%el%d" /t %dw% /d 0 /f>nul 2>&1

%ifNdef% NotDisableSecHealth (%ra% "HKLM\%smwd% Security Center\Device security" /v "UILockdown" /t %dw% /d 1 /f>nul 2>&1)
%rd% "HKLM\%sccd%\Scenarios\HypervisorEnforcedCodeIntegrity" /v "Was%el%dBy" /f>nul 2>&1
%rd% "HKLM\%sccd%\Scenarios\HypervisorEnforcedCodeIntegrity" /v "Was%el%dBySysprep" /f>nul 2>&1
%ra% "HKLM\%sccd%" /v "%el%VirtualizationBasedSecurity" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%sccd%" /v "RequirePlatformSecurityFeatures" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%sccd%" /v "RequireMicrosoftSignedBootChain" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%sccd%" /v "Locked" /t %dw% /d 0 /f>nul 2>&1
%rd% "HKLM\%sccd%\Capabilities" /f>nul 2>&1
%ra% "HKLM\%sccd%\Scenarios\CredentialGuard" /v "%el%d" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%sccd%\Scenarios\HypervisorEnforcedCodeIntegrity" /v "%el%d" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%sccd%\Scenarios\HypervisorEnforcedCodeIntegrity" /v "HVCIMATRequired" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%sccd%\Scenarios\HypervisorEnforcedCodeIntegrity" /v "Locked" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%sccd%\Scenarios\KernelShadowStacks" /v "%el%d" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%sccd%\Scenarios\KernelShadowStacks" /v "AuditMode%el%d" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%sccd%\Scenarios\KernelShadowStacks" /v "Was%el%dBy" /t %dw% /d 4 /f>nul 2>&1

%ra% "HKLM\%scc%\Lsa" /v "LsaCfgFlags" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%scc%\Lsa" /v "RunAsPPL" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%scc%\Lsa" /v "RunAsPPLBoot" /t %dw% /d 0 /f>nul 2>&1
%rd% "HKLM\%smwci%\LSASS.exe" /v "AuditLevel" /f>nul 2>&1

%ra% "HKLM\%smw%\%cv%\%evt%%wd%\Operational" /v "%el%d" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%smw%\%cv%\%evt%%wd%\WHC" /v "%el%d" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%scc%\WMI\Autologger\%df%erApiLogger" /v "Start" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%scc%\WMI\Autologger\%df%erAuditLogger" /v "Start" /t %dw% /d 0 /f>nul 2>&1

%rd% "HKLM\%scs%\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System" /v "WebThreatDefSvc_Allow_In" /f>nul 2>&1
%rd% "HKLM\%scs%\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System" /v "WebThreatDefSvc_Allow_Out" /f>nul 2>&1
%rd% "HKLM\%scs%\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System" /v "WebThreatDefSvc_Block_In" /f>nul 2>&1
%rd% "HKLM\%scs%\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System" /v "WebThreatDefSvc_Block_Out" /f>nul 2>&1
%rd% "HKLM\%scs%\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System" /v "Windows%df%er-1" /f>nul 2>&1
%rd% "HKLM\%scs%\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System" /v "Windows%df%er-2" /f>nul 2>&1
%rd% "HKLM\%scs%\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System" /v "Windows%df%er-3" /f>nul 2>&1

%rd% "HKLM\%scc%\Ubpm" /v "CriticalMaintenance_%df%erCleanup" /f>nul 2>&1
%rd% "HKLM\%scc%\Ubpm" /v "CriticalMaintenance_%df%erVerification" /f>nul 2>&1

%tk% /im %ss%.exe /t /f>nul 2>&1
%rd% "HKLM\%scl%\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}" /f>nul 2>&1
%rd% "HKLM\%scl%\WOW6432Node\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}" /f>nul 2>&1
%rd% "HKLM\SOFTWARE\WOW6432Node\Classes\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}" /f>nul 2>&1

%ra% "HKLM\%smw%\%cv%\Explorer" /v "%ss%%el%d" /t %sz% /d "Off" /f>nul 2>&1
%ra% "HKLM\%smw%\%cv%\Explorer" /v "Aic%el%d" /t %sz% /d "Anywhere" /f>nul 2>&1

%ra% "HKLM\%smw%\%cv%\WTDS\Components" /v "Service%el%d" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%smw%\%cv%\WTDS\Components" /v "NotifyUnsafeApp" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%smw%\%cv%\WTDS\Components" /v "NotifyPasswordReuse" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%smw%\%cv%\WTDS\Components" /v "NotifyMalicious" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%smw%\%cv%\WTDS\Components" /v "CaptureThreatWindow" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%smw%\%cv%\WTDS\FeatureFlags" /v "BlockUxDisabled" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%smw%\%cv%\WTDS\FeatureFlags" /v "TelemetryCalls%el%d" /t %dw% /d 0 /f>nul 2>&1

%ra% "HKLM\%smw%Mitigation" /v "UserPreference" /t %dw% /d 2 /f>nul 2>&1
%ra% "HKLM\%scc%\Session Manager\kernel" /v "MitigationAuditOptions" /t REG_BINARY /d "000000000000202200000000000000200000000000000000" /f>nul 2>&1
%ra% "HKLM\%scc%\Session Manager\kernel" /v "MitigationOptions" /t REG_BINARY /d "002222202220222220000000002000200000000000000000" /f>nul 2>&1
%ra% "HKLM\%scc%\Session Manager\kernel" /v "KernelSEHOP%el%d" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\%scc%\Session Manager\kernel" /v "%dl%ExceptionChainValidation" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM\%scc%\SCMConfig" /v "%el%SvchostMitigationPolicy" /t REG_BINARY /d "0000000000000000" /f>nul 2>&1

%ra% "HKLM\%smw%\Windows Error Reporting" /v "%dl%d" /t %dw% /d "1" /f>nul 2>&1

%ra% "HKLM\%scs%\ConDrv" /v Start /t %dw% /d 1 /f>nul 2>&1
call :EventsWork 0
call :CleanCaches

%msg% "Disabling UWP apps..." "Отключение UWP приложений..."
%ifNdef% NotDisableSecHealth call :BlockUWP sechealth
call :BlockUWP chxapp
exit /b

:EventsWork
if "%~1"=="0" %msg% "Disabling security event logs..." "Отключение журналов событий безопасности..."
if "%~1"=="1" %msg% "Enabling security event logs..." "Включение журналов событий безопасности..."
%rq% "HKLM\%smw%\%cv%\%evt%AppID/Operational">nul 2>&1&&%ra% "HKLM\%smw%\%cv%\%evt%AppID/Operational" /v "%el%d" /t %dw% /d %~1 /f>nul 2>&1
%rq% "HKLM\%smw%\%cv%\%evt%AppLocker/EXE and DLL">nul 2>&1&&%ra% "HKLM\%smw%\%cv%\%evt%AppLocker/EXE and DLL" /v "%el%d" /t %dw% /d %~1 /f>nul 2>&1
%rq% "HKLM\%smw%\%cv%\%evt%AppLocker/MSI and Script">nul 2>&1&&%ra% "HKLM\%smw%\%cv%\%evt%AppLocker/MSI and Script" /v "%el%d" /t %dw% /d %~1 /f>nul 2>&1
%rq% "HKLM\%smw%\%cv%\%evt%AppLocker/Packaged app-Deployment">nul 2>&1&&%ra% "HKLM\%smw%\%cv%\%evt%AppLocker/Packaged app-Deployment" /v "%el%d" /t %dw% /d %~1 /f>nul 2>&1
%rq% "HKLM\%smw%\%cv%\%evt%AppLocker/Packaged app-Execution">nul 2>&1&&%ra% "HKLM\%smw%\%cv%\%evt%AppLocker/Packaged app-Execution" /v "%el%d" /t %dw% /d %~1 /f>nul 2>&1
%rq% "HKLM\%smw%\%cv%\%evt%CodeIntegrity/Operational">nul 2>&1&&%ra% "HKLM\%smw%\%cv%\%evt%CodeIntegrity/Operational" /v "%el%d" /t %dw% /d %~1 /f>nul 2>&1
%rq% "HKLM\%smw%\%cv%\%evt%DeviceGuard/Operational">nul 2>&1&&%ra% "HKLM\%smw%\%cv%\%evt%DeviceGuard/Operational" /v "%el%d" /t %dw% /d %~1 /f>nul 2>&1
%rq% "HKLM\%smw%\%cv%\%evt%Security-Adminless/Operational">nul 2>&1&&%ra% "HKLM\%smw%\%cv%\%evt%Security-Adminless/Operational" /v "%el%d" /t %dw% /d %~1 /f>nul 2>&1
%rq% "HKLM\%smw%\%cv%\%evt%Security-Audit-Configuration-Client/Operational">nul 2>&1&&%ra% "HKLM\%smw%\%cv%\%evt%Security-Audit-Configuration-Client/Operational" /v "%el%d" /t %dw% /d %~1 /f>nul 2>&1
%rq% "HKLM\%smw%\%cv%\%evt%Security-EnterpriseData-FileRevocationManager/Operational">nul 2>&1&&%ra% "HKLM\%smw%\%cv%\%evt%Security-EnterpriseData-FileRevocationManager/Operational" /v "%el%d" /t %dw% /d %~1 /f>nul 2>&1
%rq% "HKLM\%smw%\%cv%\%evt%Security-Isolation-BrokeringFileSystem/Operational">nul 2>&1&&%ra% "HKLM\%smw%\%cv%\%evt%Security-Isolation-BrokeringFileSystem/Operational" /v "%el%d" /t %dw% /d %~1 /f>nul 2>&1
%rq% "HKLM\%smw%\%cv%\%evt%Security-LessPrivilegedAppContainer/Operational">nul 2>&1&&%ra% "HKLM\%smw%\%cv%\%evt%Security-LessPrivilegedAppContainer/Operational" /v "%el%d" /t %dw% /d %~1 /f>nul 2>&1
%rq% "HKLM\%smw%\%cv%\%evt%Security-Mitigations/KernelMode">nul 2>&1&&%ra% "HKLM\%smw%\%cv%\%evt%Security-Mitigations/KernelMode" /v "%el%d" /t %dw% /d %~1 /f>nul 2>&1
%rq% "HKLM\%smw%\%cv%\%evt%Security-Mitigations/UserMode">nul 2>&1&&%ra% "HKLM\%smw%\%cv%\%evt%Security-Mitigations/UserMode" /v "%el%d" /t %dw% /d %~1 /f>nul 2>&1
%rq% "HKLM\%smw%\%cv%\%evt%Security-Netlogon/Operational">nul 2>&1&&%ra% "HKLM\%smw%\%cv%\%evt%Security-Netlogon/Operational" /v "%el%d" /t %dw% /d %~1 /f>nul 2>&1
%rq% "HKLM\%smw%\%cv%\%evt%Security-SPP-UX-GenuineCenter-Logging/Operational">nul 2>&1&&%ra% "HKLM\%smw%\%cv%\%evt%Security-SPP-UX-GenuineCenter-Logging/Operational" /v "%el%d" /t %dw% /d %~1 /f>nul 2>&1
%rq% "HKLM\%smw%\%cv%\%evt%Security-SPP-UX-Notifications/ActionCenter">nul 2>&1&&%ra% "HKLM\%smw%\%cv%\%evt%Security-SPP-UX-Notifications/ActionCenter" /v "%el%d" /t %dw% /d %~1 /f>nul 2>&1
%rq% "HKLM\%smw%\%cv%\%evt%Security-UserConsentVerifier/Audit">nul 2>&1&&%ra% "HKLM\%smw%\%cv%\%evt%Security-UserConsentVerifier/Audit" /v "%el%d" /t %dw% /d %~1 /f>nul 2>&1
%rq% "HKLM\%smw%\%cv%\%evt%SecurityMitigationsBroker/Operational">nul 2>&1&&%ra% "HKLM\%smw%\%cv%\%evt%SecurityMitigationsBroker/Operational" /v "%el%d" /t %dw% /d %~1 /f>nul 2>&1
%rq% "HKLM\%smw%\%cv%\%evt%SENSE/Operational">nul 2>&1&&%ra% "HKLM\%smw%\%cv%\%evt%SENSE/Operational" /v "%el%d" /t %dw% /d %~1 /f>nul 2>&1
%rq% "HKLM\%smw%\%cv%\%evt%SenseIR/Operational">nul 2>&1&&%ra% "HKLM\%smw%\%cv%\%evt%SenseIR/Operational" /v "%el%d" /t %dw% /d %~1 /f>nul 2>&1
%rq% "HKLM\%smw%\%cv%\%evt%WDAG-PolicyEvaluator-CSP/Operational">nul 2>&1&&%ra% "HKLM\%smw%\%cv%\%evt%WDAG-PolicyEvaluator-CSP/Operational" /v "%el%d" /t %dw% /d %~1 /f>nul 2>&1
%rq% "HKLM\%smw%\%cv%\%evt%WDAG-PolicyEvaluator-GP/Operational">nul 2>&1&&%ra% "HKLM\%smw%\%cv%\%evt%WDAG-PolicyEvaluator-GP/Operational" /v "%el%d" /t %dw% /d %~1 /f>nul 2>&1
%rq% "HKLM\%smw%\%cv%\%evt%%wd%/Operational">nul 2>&1&&%ra% "HKLM\%smw%\%cv%\%evt%%wd%/Operational" /v "%el%d" /t %dw% /d %~1 /f>nul 2>&1
%rq% "HKLM\%smw%\%cv%\%evt%%wd%/WHC">nul 2>&1&&%ra% "HKLM\%smw%\%cv%\%evt%%wd%/WHC" /v "%el%d" /t %dw% /d %~1 /f>nul 2>&1
%rq% "HKLM\%smw%\%cv%\%evt%Windows Firewall With Advanced Security/ConnectionSecurity">nul 2>&1&&%ra% "HKLM\%smw%\%cv%\%evt%Windows Firewall With Advanced Security/ConnectionSecurity" /v "%el%d" /t %dw% /d %~1 /f>nul 2>&1
exit /b

:EventsCount
set /a eventscount=0
set /a eventenabled=0
%rq% "HKLM\%smw%\%cv%\%evt%AppID/Operational" /v "Type">nul 2>&1&&(set /a eventscount+=1&(%rq% "HKLM\%smw%\%cv%\%evt%AppID/Operational" /v "%el%d" 2>nul|%find% "0x1">nul 2>&1)&&set /a eventenabled+=1)
%rq% "HKLM\%smw%\%cv%\%evt%AppLocker/EXE and DLL" /v "Type">nul 2>&1&&(set /a eventscount+=1&(%rq% "HKLM\%smw%\%cv%\%evt%AppLocker/EXE and DLL" /v "%el%d" 2>nul|%find% "0x1">nul 2>&1)&&set /a eventenabled+=1)
%rq% "HKLM\%smw%\%cv%\%evt%AppLocker/MSI and Script" /v "Type">nul 2>&1&&(set /a eventscount+=1&(%rq% "HKLM\%smw%\%cv%\%evt%AppLocker/MSI and Script" /v "%el%d" 2>nul|%find% "0x1">nul 2>&1)&&set /a eventenabled+=1)
%rq% "HKLM\%smw%\%cv%\%evt%AppLocker/Packaged app-Deployment" /v "Type">nul 2>&1&&(set /a eventscount+=1&(%rq% "HKLM\%smw%\%cv%\%evt%AppLocker/Packaged app-Deployment" /v "%el%d" 2>nul|%find% "0x1">nul 2>&1)&&set /a eventenabled+=1)
%rq% "HKLM\%smw%\%cv%\%evt%AppLocker/Packaged app-Execution" /v "Type">nul 2>&1&&(set /a eventscount+=1&(%rq% "HKLM\%smw%\%cv%\%evt%AppLocker/Packaged app-Execution" /v "%el%d" 2>nul|%find% "0x1">nul 2>&1)&&set /a eventenabled+=1)
%rq% "HKLM\%smw%\%cv%\%evt%CodeIntegrity/Operational" /v "Type">nul 2>&1&&(set /a eventscount+=1&(%rq% "HKLM\%smw%\%cv%\%evt%CodeIntegrity/Operational" /v "%el%d" 2>nul|%find% "0x1">nul 2>&1)&&set /a eventenabled+=1)
%rq% "HKLM\%smw%\%cv%\%evt%DeviceGuard/Operational" /v "Type">nul 2>&1&&(set /a eventscount+=1&(%rq% "HKLM\%smw%\%cv%\%evt%DeviceGuard/Operational" /v "%el%d" 2>nul|%find% "0x1">nul 2>&1)&&set /a eventenabled+=1)
%rq% "HKLM\%smw%\%cv%\%evt%Security-Adminless/Operational" /v "Type">nul 2>&1&&(set /a eventscount+=1&(%rq% "HKLM\%smw%\%cv%\%evt%Security-Adminless/Operational" /v "%el%d" 2>nul|%find% "0x1">nul 2>&1)&&set /a eventenabled+=1)
%rq% "HKLM\%smw%\%cv%\%evt%Security-Audit-Configuration-Client/Operational" /v "Type">nul 2>&1&&(set /a eventscount+=1&(%rq% "HKLM\%smw%\%cv%\%evt%Security-Audit-Configuration-Client/Operational" /v "%el%d" 2>nul|%find% "0x1">nul 2>&1)&&set /a eventenabled+=1)
%rq% "HKLM\%smw%\%cv%\%evt%Security-EnterpriseData-FileRevocationManager/Operational" /v "Type">nul 2>&1&&(set /a eventscount+=1&(%rq% "HKLM\%smw%\%cv%\%evt%Security-EnterpriseData-FileRevocationManager/Operational" /v "%el%d" 2>nul|%find% "0x1">nul 2>&1)&&set /a eventenabled+=1)
%rq% "HKLM\%smw%\%cv%\%evt%Security-Isolation-BrokeringFileSystem/Operational" /v "Type">nul 2>&1&&(set /a eventscount+=1&(%rq% "HKLM\%smw%\%cv%\%evt%Security-Isolation-BrokeringFileSystem/Operational" /v "%el%d" 2>nul|%find% "0x1">nul 2>&1)&&set /a eventenabled+=1)
%rq% "HKLM\%smw%\%cv%\%evt%Security-LessPrivilegedAppContainer/Operational" /v "Type">nul 2>&1&&(set /a eventscount+=1&(%rq% "HKLM\%smw%\%cv%\%evt%Security-LessPrivilegedAppContainer/Operational" /v "%el%d" 2>nul|%find% "0x1">nul 2>&1)&&set /a eventenabled+=1)
%rq% "HKLM\%smw%\%cv%\%evt%Security-Mitigations/KernelMode" /v "Type">nul 2>&1&&(set /a eventscount+=1&(%rq% "HKLM\%smw%\%cv%\%evt%Security-Mitigations/KernelMode" /v "%el%d" 2>nul|%find% "0x1">nul 2>&1)&&set /a eventenabled+=1)
%rq% "HKLM\%smw%\%cv%\%evt%Security-Mitigations/UserMode" /v "Type">nul 2>&1&&(set /a eventscount+=1&(%rq% "HKLM\%smw%\%cv%\%evt%Security-Mitigations/UserMode" /v "%el%d" 2>nul|%find% "0x1">nul 2>&1)&&set /a eventenabled+=1)
%rq% "HKLM\%smw%\%cv%\%evt%Security-Netlogon/Operational" /v "Type">nul 2>&1&&(set /a eventscount+=1&(%rq% "HKLM\%smw%\%cv%\%evt%Security-Netlogon/Operational" /v "%el%d" 2>nul|%find% "0x1">nul 2>&1)&&set /a eventenabled+=1)
%rq% "HKLM\%smw%\%cv%\%evt%Security-SPP-UX-GenuineCenter-Logging/Operational" /v "Type">nul 2>&1&&(set /a eventscount+=1&(%rq% "HKLM\%smw%\%cv%\%evt%Security-SPP-UX-GenuineCenter-Logging/Operational" /v "%el%d" 2>nul|%find% "0x1">nul 2>&1)&&set /a eventenabled+=1)
%rq% "HKLM\%smw%\%cv%\%evt%Security-SPP-UX-Notifications/ActionCenter" /v "Type">nul 2>&1&&(set /a eventscount+=1&(%rq% "HKLM\%smw%\%cv%\%evt%Security-SPP-UX-Notifications/ActionCenter" /v "%el%d" 2>nul|%find% "0x1">nul 2>&1)&&set /a eventenabled+=1)
%rq% "HKLM\%smw%\%cv%\%evt%Security-UserConsentVerifier/Audit" /v "Type">nul 2>&1&&(set /a eventscount+=1&(%rq% "HKLM\%smw%\%cv%\%evt%Security-UserConsentVerifier/Audit" /v "%el%d" 2>nul|%find% "0x1">nul 2>&1)&&set /a eventenabled+=1)
%rq% "HKLM\%smw%\%cv%\%evt%SecurityMitigationsBroker/Operational" /v "Type">nul 2>&1&&(set /a eventscount+=1&(%rq% "HKLM\%smw%\%cv%\%evt%SecurityMitigationsBroker/Operational" /v "%el%d" 2>nul|%find% "0x1">nul 2>&1)&&set /a eventenabled+=1)
%rq% "HKLM\%smw%\%cv%\%evt%SENSE/Operational" /v "Type">nul 2>&1&&(set /a eventscount+=1&(%rq% "HKLM\%smw%\%cv%\%evt%SENSE/Operational" /v "%el%d" 2>nul|%find% "0x1">nul 2>&1)&&set /a eventenabled+=1)
%rq% "HKLM\%smw%\%cv%\%evt%SenseIR/Operational" /v "Type">nul 2>&1&&(set /a eventscount+=1&(%rq% "HKLM\%smw%\%cv%\%evt%SenseIR/Operational" /v "%el%d" 2>nul|%find% "0x1">nul 2>&1)&&set /a eventenabled+=1)
%rq% "HKLM\%smw%\%cv%\%evt%WDAG-PolicyEvaluator-CSP/Operational" /v "Type">nul 2>&1&&(set /a eventscount+=1&(%rq% "HKLM\%smw%\%cv%\%evt%WDAG-PolicyEvaluator-CSP/Operational" /v "%el%d" 2>nul|%find% "0x1">nul 2>&1)&&set /a eventenabled+=1)
%rq% "HKLM\%smw%\%cv%\%evt%WDAG-PolicyEvaluator-GP/Operational" /v "Type">nul 2>&1&&(set /a eventscount+=1&(%rq% "HKLM\%smw%\%cv%\%evt%WDAG-PolicyEvaluator-GP/Operational" /v "%el%d" 2>nul|%find% "0x1">nul 2>&1)&&set /a eventenabled+=1)
%rq% "HKLM\%smw%\%cv%\%evt%%wd%/Operational" /v "Type">nul 2>&1&&(set /a eventscount+=1&(%rq% "HKLM\%smw%\%cv%\%evt%%wd%/Operational" /v "%el%d" 2>nul|%find% "0x1">nul 2>&1)&&set /a eventenabled+=1)
%rq% "HKLM\%smw%\%cv%\%evt%%wd%/WHC" /v "Type">nul 2>&1&&(set /a eventscount+=1&(%rq% "HKLM\%smw%\%cv%\%evt%%wd%/WHC" /v "%el%d" 2>nul|%find% "0x1">nul 2>&1)&&set /a eventenabled+=1)
%rq% "HKLM\%smw%\%cv%\%evt%Windows Firewall With Advanced Security/ConnectionSecurity" /v "Type">nul 2>&1&&(set /a eventscount+=1&(%rq% "HKLM\%smw%\%cv%\%evt%Windows Firewall With Advanced Security/ConnectionSecurity" /v "%el%d" 2>nul|%find% "0x1">nul 2>&1)&&set /a eventenabled+=1)
exit /b

:Services
%msg% "Disabling the launch of services and drivers..." "Отключение запуска служб и драйверов..."
for %%s in (Win%df% MDCoreSvc WdNisSvc Sense webthreatdefsvc webthreatdefusersvc WdNisDrv WdBoot WdDevFlt WdFilter MsSecWfp MsSecFlt MsSecCore wtd KslD AppID AppIDSvc applockerfltr) do %rq% "HKLM\%scs%\%%~s">nul 2>&1&&%ra% "HKLM\%scs%\%%~s" /v "Start" /t %dw% /d 4 /f>nul 2>&1
%ifNdef% NotDisableSecHealth for %%s in (SecurityHealthService SgrmBroker SgrmAgent) do %rq% "HKLM\%scs%\%%~s">nul 2>&1&&%ra% "HKLM\%scs%\%%~s" /v "Start" /t %dw% /d 4 /f>nul 2>&1
%ifNdef% NotDisableSecHealth (%rq% "HKLM\%scs%\wscsvc">nul 2>&1)&&(%ifNdef% NotDisableWscsvc %ra% "HKLM\%scs%\wscsvc" /v "Start" /t %dw% /d 4 /f>nul 2>&1)

%rd% "HKLM\%smw% NT\%cv%\Svchost" /v "WebThreatDefense" /f>nul 2>&1
exit /b

:Block
%msg% "Blocking process launch via fake debugger..." "Блокировка запуска процессов через поддельный отладчик..."
%ra% "HKLM\%smwci%\ConfigSecurityPolicy.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM\%smwci%\DlpUserAgent.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM\%smwci%\%df%erbootstrapper.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM\%smwci%\mpam-d.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM\%smwci%\mpam-fe.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM\%smwci%\mpam-fe_bd.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM\%smwci%\mpas-d.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM\%smwci%\mpas-fe.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM\%smwci%\mpas-fe_bd.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM\%smwci%\mpav-d.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM\%smwci%\mpav-fe.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM\%smwci%\mpav-fe_bd.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM\%smwci%\UpdatePlatform.amd64fre.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM\%smwci%\MpCmdRun.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM\%smwci%\MpCopyAccelerator.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM\%smwci%\Mp%df%erCoreService.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM\%smwci%\MpDlpCmd.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM\%smwci%\MpDlpService.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM\%smwci%\mpextms.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM\%smwci%\MpSigStub.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM\%smwci%\MsMpEng.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM\%smwci%\MsMpEngCP.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM\%smwci%\MsSense.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM\%smwci%\NisSrv.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM\%smwci%\OfflineScannerShell.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM\%smwci%\SecureKernel.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ifNdef% NotDisableSecHealth (
	%ra% "HKLM\%smwci%\SecurityHealthHost.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
	%ra% "HKLM\%smwci%\SecurityHealthService.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
	%ra% "HKLM\%smwci%\SecurityHealthSystray.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
	%ra% "HKLM\%smwci%\SgrmBroker.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
)
%ra% "HKLM\%smwci%\SenseAP.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM\%smwci%\SenseAPToast.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM\%smwci%\SenseCM.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM\%smwci%\SenseGPParser.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM\%smwci%\SenseIdentity.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM\%smwci%\SenseImdsCollector.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM\%smwci%\SenseIR.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM\%smwci%\SenseNdr.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM\%smwci%\SenseSampleUploader.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM\%smwci%\SenseTVM.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM\%smwci%\SenseCE.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM\%smwci%\%ss%.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
if exist "%sysdir%MRT.exe" %ra% "HKLM\%smwci%\MRT.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%msg% "Blocking services via fake dependency..." "Блокировка сервисов через поддельную зависимость..."
for %%s in (Win%df% MDCoreSvc WdNisSvc Sense webthreatdefsvc webthreatdefusersvc WdNisDrv WdBoot WdDevFlt WdFilter MsSecWfp MsSecFlt MsSecCore wtd KslD AppID AppIDSvc applockerfltr) do call :BrokeService "%%~s"
%ifNdef% NotDisableSecHealth for %%s in (SecurityHealthService SgrmBroker SgrmAgent) do call :BrokeService "%%~s"
%ifNdef% NotDisableSecHealth (%rq% "HKLM\%scs%\wscsvc">nul 2>&1)&&(%ifNdef% NotDisableWscsvc call :BrokeService "wscsvc")
exit /b

:BrokeService
setlocal EnableDelayedExpansion
%rq% "HKLM\%scs%\%~1" >nul 2>&1 && (
	set "DependOnServiceValue="
    (%rq% "HKLM\%scs%\%~1" /v "DependOnService" 2>nul|%find% "OFF">nul 2>&1)||for /f "tokens=3,*" %%a in ('%rq% "HKLM\%scs%\%~1" /v "DependOnService" 2^>nul') do set "DependOnServiceValue=%%a"
    if not "!DependOnServiceValue!"=="" %ra% "HKLM\%scs%\%~1" /v "DependOnServiceOriginal" /t %msz% /d "!DependOnServiceValue!" /f >nul 2>&1
	%ra% "HKLM\%scs%\%~1" /v "DependOnService" /t %msz% /d "OFF" /f >nul 2>&1
)
endlocal
exit /b

:CIPolicies
%msg% "Disabling code integrity policies..." "Отключение политик целостности кода..."
set "efi="
for %%a in (Z Y X W V U T S R Q P O N M L K J I H G F E D) do if not exist %%a:\nul set "efi=%%a:"&goto :FoundFreeDiskCI
:FoundFreeDiskCI
%ifdef% efi (
	%mountvol% %efi% /s >nul 2>&1
	md "%efi%\EFI\Microsoft\Boot\CIPolicies\%dl%d">nul 2>&1
	%ifdef% DisablePkcsPolicies move /y "%efi%\EFI\Microsoft\Boot\*.p7b" "%efi%\EFI\Microsoft\Boot\CIPolicies\%dl%d\">nul 2>&1
	move /y "%efi%\EFI\Microsoft\Boot\CIPolicies\Active\*.cip" "%efi%\EFI\Microsoft\Boot\CIPolicies\%dl%d\">nul 2>&1
	%mountvol% %efi% /d >nul 2>&1
)
md "%sysdir%CodeIntegrity\CIPolicies\%dl%d">nul 2>&1
%ifdef% DisablePkcsPolicies move /y "%sysdir%CodeIntegrity\*.p7b" "%sysdir%CodeIntegrity\CIPolicies\%dl%d\">nul 2>&1
%ifdef% DisablePkcsPolicies %bcdedit%|%find% "hypervisorlaunchtype    Auto">nul 2>&1&&set hyperv=1||set "hyperv="
%ifdef% DisablePkcsPolicies %ifdef% hyperv move /y "%sysdir%CodeIntegrity\CIPolicies\%dl%d\VbsSiPolicy.p7b" "%sysdir%CodeIntegrity\">nul 2>&1
move /y "%sysdir%CodeIntegrity\CIPolicies\Active\*.cip" "%sysdir%CodeIntegrity\CIPolicies\%dl%d\">nul 2>&1
move /y "%sysdir%CodeIntegrity\CIPolicies\%dl%d\{60FD87F8-4593-44A0-91B0-2E0DA022F248}.cip" "%sysdir%CodeIntegrity\CIPolicies\Active">nul 2>&1
exit /b

:BlockProcess
%ra% "HKLM\%smwci%\%~1" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
exit /b %errorlevel%

:UnBlockProcess
set "unbl=HKLM\%smwci%\%~1"
%rd% "%unbl%" /v "Debugger" /f>nul 2>&1
%rq% "%unbl%" /v *>nul 2>&1
if %errorlevel%==1 %rd% "%unbl%" /f>nul 2>&1
exit /b %errorlevel%

:RestoreCurrentUser
call :StopTelemetry
if [%build%] lss [19045] goto :SkipRegsvr
%msg% "Register security libraries..." "Регистрация библиотек безопасности..."
%regsvr32% /s "%sys%:\Program Files\%wd%\shellext.dll">nul 2>&1
%regsvr32% /s "%sys%:\Program Files\%wd%\AMMonitoringProvider.dll">nul 2>&1
%regsvr32% /s "%sys%:\Program Files\%wd%\%df%CSP.dll">nul 2>&1
%regsvr32% /s "%sys%:\Program Files\%wd%\MpOAV.dll">nul 2>&1
%regsvr32% /s "%sys%:\Program Files\%wd%\MpProvider.dll">nul 2>&1
%regsvr32% /s "%sys%:\Program Files\%wd%\MpUxAgent.dll">nul 2>&1
%regsvr32% /s "%sys%:\Program Files\%wd%\MsMpCom.dll">nul 2>&1
%regsvr32% /s "%sys%:\Program Files\%wd%\ProtectionManagement.dll">nul 2>&1
%regsvr32% /s "%sys%:\Program Files\%wd% Advanced Threat Protection\Classification\cmicarabicwordbreaker.dll">nul 2>&1
%regsvr32% /s "%sys%:\Program Files\%wd% Advanced Threat Protection\Classification\korwbrkr.dll">nul 2>&1
%regsvr32% /s "%sys%:\Program Files\%wd% Advanced Threat Protection\Classification\mce.dll">nul 2>&1
%regsvr32% /s "%sys%:\Program Files\%wd% Advanced Threat Protection\Classification\upe.dll">nul 2>&1
%regsvr32% /s "%sysdir%%ss%ps.dll">nul 2>&1
%regsvr32% /s "%sysdir%ieapfltr.dll">nul 2>&1
%regsvr32% /s "%sysdir%ThreatResponseEngine.dll">nul 2>&1
%regsvr32% /s "%sysdir%webthreatdefsvc.dll">nul 2>&1
if exist "%ProgramData%\Microsoft\%wd%\Platform" for /d %%D in ("%ProgramData%\Microsoft\%wd%\Platform\*") do (
	%regsvr32% /s "%%D\shellext.dll">nul 2>&1
	%regsvr32% /s "%%D\AMMonitoringProvider.dll">nul 2>&1
	%regsvr32% /s "%%D\%df%CSP.dll">nul 2>&1
	%regsvr32% /s "%%D\MpOAV.dll">nul 2>&1
	%regsvr32% /s "%%D\MpProvider.dll">nul 2>&1
	%regsvr32% /s "%%D\MpUxAgent.dll">nul 2>&1
	%regsvr32% /s "%%D\MsMpCom.dll">nul 2>&1
	%regsvr32% /s "%%D\ProtectionManagement.dll">nul 2>&1
)
if exist "%ProgramData%\Microsoft\%wd% Advanced Threat Protection\Platform" for /d %%D in ("%ProgramData%\Microsoft\%wd% Advanced Threat Protection\Platform\*") do (
	%regsvr32% /s "%%D\cmicarabicwordbreaker.dll">nul 2>&1
	%regsvr32% /s "%%D\korwbrkr.dll">nul 2>&1
	%regsvr32% /s "%%D\mce.dll">nul 2>&1
	%regsvr32% /s "%%D\upe.dll">nul 2>&1
)
%regsvr32% /s "%sysdir%SecurityHealthAgent.dll">nul 2>&1
%regsvr32% /s "%sysdir%SecurityHealthProxyStub.dll">nul 2>&1
if exist "%sysdir%SecurityHealth" for /d %%D in ("%sysdir%SecurityHealth\*") do (
  %regsvr32% /s "%%D\SecurityHealthAgent.dll">nul 2>&1
  %regsvr32% /s "%%D\SecurityHealthProxyStub.dll">nul 2>&1
)
%regsvr32% /s "%sysdir%SecurityCenterBrokerPS.dll">nul 2>&1
if exist %regsvr% %regsvr% /s "%syswow%\%ss%ps.dll">nul 2>&1
if exist %regsvr% %regsvr% /s "%syswow%\ieapfltr.dll">nul 2>&1
:SkipRegsvr
%msg% "Enabling tasks in the scheduler..." "Включение заданий в планировщике..."  
%schtasks% /Change /TN "Microsoft\Windows\%wd%\%wd% Cache Maintenance" /%el%>nul 2>&1
%schtasks% /Change /TN "Microsoft\Windows\%wd%\%wd% Cleanup" /%el%>nul 2>&1
%schtasks% /Change /TN "Microsoft\Windows\%wd%\%wd% Scheduled Scan" /%el%>nul 2>&1
%schtasks% /Change /TN "Microsoft\Windows\%wd%\%wd% Verification" /%el%>nul 2>&1
%schtasks% /Change /TN "Microsoft\Windows\%wd%\%wd% Update" /%el%>nul 2>&1
%schtasks% /Change /TN "Microsoft\Windows\AppID\%ss%Specific" /%el%>nul 2>&1
%schtasks% /Change /TN "Microsoft\Windows\AppID\PolicyConverter" /%el%>nul 2>&1
%schtasks% /Change /TN "Microsoft\Windows\AppID\VerifiedPublisherCertStoreCheck" /%el%>nul 2>&1
%schtasks% /Change /TN "Microsoft\Windows\ExploitGuard\ExploitGuard MDM policy Refresh" /%el%>nul 2>&1
%msg% "Deleting tasks in the scheduler for re-disabling after updates..." "Удаление заданий в планировщике для пере-отключения после обновлений..."
%schtasks% /Query 2>nul | %findstr% /C:"ReDisabling %df%er">nul 2>&1&&(
	chcp 437 >nul 2>&1
	%powershell% -MTA -NoP -NoL -NonI -EP Bypass -c "Get-ScheduledTask -TaskPath \"\ReDisabling %df%er\*\" | Unregister-ScheduledTask -Confirm:$false">nul 2>&1
	chcp 65001 >nul 2>&1>nul 2>&1
	%schtasks% /Delete /tn "ReDisabling %df%er\Events" /f>nul 2>&1
	%schtasks% /Delete /tn "ReDisabling %df%er\Tasks" /f>nul 2>&1
	%schtasks% /Delete /tn "ReDisabling %df%er" /f>nul 2>&1  )
del /f /q "%sysdir%Re%dl%%df%er.cmd">nul 2>&1        
%msg% "Restore default setting for current user..." "Восстановление настроек по умолчанию для текущего пользователя..."
%rd% "HKCU\%smw% Security Health\State" /v "AppAndBrowser_Edge%ss%Off" /f>nul 2>&1
%rd% "HKCU\%smw% Security Health\State" /v "AppAndBrowser_Pua%ss%Off" /f>nul 2>&1
%rd% "HKCU\%smw% Security Health\State" /v "AppAndBrowser_StoreApps%ss%Off" /f>nul 2>&1
%ra% "HKCU\%smw%\%cv%\AppHost" /v "%el%WebContentEvaluation" /t %dw% /d "1" /f>nul 2>&1
%rd% "HKCU\%smw%\%cv%\AppHost" /v "PreventOverride" /f>nul 2>&1
%rd% "HKCU\%smw%\%cv%\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance" /v "%el%d" /f>nul 2>&1
%rd% "HKCU\%smw%\%cv%\Policies\Attachments" /f>nul 2>&1
%rd% "HKCU\%smw%\%cv%\Policies\Associations" /v "DefaultFileTypeRisk" /f>nul 2>&1
%rd% "HKCU\%spm%\Edge" /f>nul 2>&1
%ra% "HKCU\Software\Microsoft\Edge\%ss%%el%d" /ve /t %dw%  /d "1" /f>nul 2>&1
%ra% "HKCU\Software\Microsoft\Edge\%ss%Pua%el%d" /ve /t %dw%  /d "1" /f>nul 2>&1
for /f "tokens=7 delims=\" %%a in ('%rq% "%plist%" ^| %findstr% /R /C:"S-1-5-21-*"') do (
	%rd% "HKU\%%a\%smw% Security Health\State" /v "AppAndBrowser_Edge%ss%Off" /f>nul 2>&1
	%rd% "HKU\%%a\%smw% Security Health\State" /v "AppAndBrowser_Pua%ss%Off" /f>nul 2>&1
	%rd% "HKU\%%a\%smw% Security Health\State" /v "AppAndBrowser_StoreApps%ss%Off" /f>nul 2>&1
	%ra% "HKU\%%a\%smw%\%cv%\AppHost" /v "%el%WebContentEvaluation" /t %dw% /d "1" /f>nul 2>&1
	%rd% "HKU\%%a\%smw%\%cv%\AppHost" /v "PreventOverride" /f>nul 2>&1
	%rd% "HKU\%%a\%smw%\%cv%\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance" /v "%el%d" /f>nul 2>&1
	%rd% "HKU\%%a\%smw%\%cv%\Policies\Attachments" /f>nul 2>&1
	%rd% "HKU\%%a\%smw%\%cv%\Policies\Associations" /v "DefaultFileTypeRisk" /f>nul 2>&1
	%rd% "HKU\%%a\%spm%\Edge" /f>nul 2>&1
	%ra% "HKU\%%a\Software\Microsoft\Edge\%ss%%el%d" /ve /t %dw%  /d "1" /f>nul 2>&1
	%ra% "HKU\%%a\Software\Microsoft\Edge\%ss%Pua%el%d" /ve /t %dw%  /d "1" /f>nul 2>&1
)
%msg% "Enabling UWP apps..." "Включение UWP приложений..."
call :UnBlockUWP chxapp
call :UnBlockUWP sechealth
if exist "%save%MySecurityDefaults.reg" %reg% import "%save%MySecurityDefaults.reg">nul 2>&1
exit /b

:Restore
%msg% "Restore default setting for system..." "Восстановление настроек по умолчанию для всей системы..."
set ForRestore=1
%msg% "Generation of auxiliary policy lists..." "Генерация вспомогательных списков политик..."
call :ApplyPol
call :UserPolList
call :MachinePolList
%msg% "Processing GroupPolicy\User\Registry.pol..." "Обработка GroupPolicy\User\Registry.pol..."
set PolWork=Del
set "PolIn=%temp%\%ASN%user.txt"
set "PolOut=%sysdir%GroupPolicy\User\Registry.pol"
chcp 437 >nul 2>&1
%powershell% -MTA -NoP -NoL -NonI -EP Bypass -f "%temp%\%ASN%pol.ps1">nul 2>&1
chcp 65001 >nul 2>&1
%msg% "Processing GroupPolicy\Machine\Registry.pol..." "Обработка GroupPolicy\Machine\Registry.pol..."
set "PolIn=%temp%\%ASN%machine.txt"
set "PolOut=%sysdir%GroupPolicy\Machine\Registry.pol"
chcp 437 >nul 2>&1
%powershell% -MTA -NoP -NoL -NonI -EP Bypass -f "%temp%\%ASN%pol.ps1">nul 2>&1
chcp 65001 >nul 2>&1
del /f /q "%temp%\%ASN%pol.ps1">nul 2>&1
del /f /q "%temp%\%ASN%user.txt">nul 2>&1
del /f /q "%temp%\%ASN%machine.txt">nul 2>&1
if exist "%save%GroupPolicy\Machine\Registry.pol" copy /b /y "%save%GroupPolicy\Machine\Registry.pol" "%sysdir%GroupPolicy\Machine\Registry.pol">nul 2>&1
if exist "%save%GroupPolicy\User\Registry.pol" copy /b /y "%save%GroupPolicy\User\Registry.pol" "%sysdir%GroupPolicy\User\Registry.pol">nul 2>&1
%ifNdef% SAFEBOOT_OPTION (if exist "%gpupdate%" (%msg% "Updating policy..." "Обновление политик...")&("%gpupdate%" /force>nul 2>&1||"%gpupdate%" /force>nul 2>&1)) else (if exist "%gpupdate%" %ra% "HKLM\%smw%\%cv%\RunOnce" /v "gpupdate" /t %sz% /d "%gpupdate% /force" /f>nul 2>&1)
set "HidePath=HKLM\%smw%\%cv%\Policies\Explorer"
for /f "tokens=2*" %%a in ('%rq% "%HidePath%" /v "SettingsPageVisibility" 2^>nul') do set "SettingsPageVisibility=%%b"
%ifNdef% SettingsPageVisibility goto :SkipRestoreVisibility
echo %SettingsPageVisibility% | %find% /i "windows%df%er">nul 2>&1||goto :SkipRestoreVisibility
set SettingsPageVisibility=%SettingsPageVisibility:windowsdefender;=%
set SettingsPageVisibility=%SettingsPageVisibility:windowsdefender=%
if "%SettingsPageVisibility%"=="hide:" set SettingsPageVisibility=
%ra% "%HidePath%" /v "SettingsPageVisibility" /t %sz% /d "%SettingsPageVisibility%" /f>nul 2>&1
:SkipRestoreVisibility
%ra% "HKLM\%scl%\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}" /ve /t %sz% /d "%ss%" /f>nul 2>&1
%ra% "HKLM\%scl%\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}" /v "AppID" /t %sz% /d "{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}" /f>nul 2>&1
%ra% "HKLM\%scl%\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}\InProcServer32" /ve /t %sz% /d "%windir%\System32\%ss%ps.dll" /f>nul 2>&1
%ra% "HKLM\%scl%\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}\InProcServer32" /v "ThreadingModel" /t %sz% /d "Both" /f>nul 2>&1
%ra% "HKLM\%scl%\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}\LocalServer32" /ve /t %sz% /d "%windir%\System32\%ss%.exe" /f>nul 2>&1
%ifNdef% ProgramFiles(x86) goto :SkipRestoreSmartScreen
%ra% "HKLM\%scl%\WOW6432Node\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}" /ve /t %sz% /d "%ss%" /f>nul 2>&1
%ra% "HKLM\%scl%\WOW6432Node\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}" /v "AppID" /t %sz% /d "{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}" /f>nul 2>&1
%ra% "HKLM\%scl%\WOW6432Node\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}\InProcServer32" /ve /t %sz% /d "%windir%\SysWOW64\%ss%ps.dll" /f>nul 2>&1
%ra% "HKLM\%scl%\WOW6432Node\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}\InProcServer32" /v "ThreadingModel" /t %sz% /d "Both" /f>nul 2>&1
%ra% "HKLM\%scl%\WOW6432Node\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}\LocalServer32" /ve /t %sz% /d "%windir%\SysWOW64\%ss%.exe" /f>nul 2>&1
:SkipRestoreSmartScreen
%rd% "HKLM\%scl%\exefile\shell\open" /v "No%ss%" /f>nul 2>&1
%rd% "HKLM\%scl%\exefile\shell\runas" /v "No%ss%" /f>nul 2>&1
%rd% "HKLM\%scl%\exefile\shell\runasuser" /v "No%ss%" /f>nul 2>&1
%ra% "HKLM\SOFTWARE\Microsoft\RemovalTools\MpGears" /v "HeartbeatTrackingIndex" /t %dw% /d "2" /f>nul 2>&1
%rd% "HKLM\%smwd% Security Center\Device security" /v "UILockdown" /f>nul 2>&1
%rd% "HKLM\%smwd% Security Center\Notifications" /v "%dl%EnhancedNotifications" /f>nul 2>&1
%rd% "HKLM\%smwd% Security Center\Virus and threat protection" /v "FilesBlockedNotification%dl%d" /f>nul 2>&1
%rd% "HKLM\%smwd% Security Center\Virus and threat protection" /v "NoActionNotification%dl%d" /f>nul 2>&1
%rd% "HKLM\%smwd% Security Center\Virus and threat protection" /v "SummaryNotification%dl%d" /f>nul 2>&1
%ra% "HKLM\%smwd%" /v "%dl%AntiSpyware" /t %dw% /d "0" /f>nul 2>&1
%ra% "HKLM\%smwd%" /v "%dl%AntiVirus" /t %dw% /d "0" /f>nul 2>&1
%ra% "HKLM\%smwd%" /v "HybridMode%el%d" /t %dw% /d "1" /f>nul 2>&1
%ra% "HKLM\%smwd%" /v "IsServiceRunning" /t %dw% /d "1" /f>nul 2>&1
%ra% "HKLM\%smwd%" /v "ProductStatus" /t %dw% /d "0" /f>nul 2>&1
%ra% "HKLM\%smwd%" /v "ProductType" /t %dw% /d "2" /f>nul 2>&1
%ra% "HKLM\%smwd%" /v "PUAProtection" /t %dw% /d "1" /f>nul 2>&1
%ra% "HKLM\%smwd%" /v "SmartLockerMode" /t %dw% /d "1" /f>nul 2>&1
%ra% "HKLM\%smwd%" /v "VerifiedAndReputableTrustMode%el%d" /t %dw% /d "1" /f>nul 2>&1
%ra% "HKLM\%smwd%" /v "SacLearningModeSwitch" /t %dw% /d "0" /f>nul 2>&1
%rq% "HKLM\%smwd%\CoreService">nul 2>&1||goto :SkipRestoreCoreService
%ra% "HKLM\%smwd%\CoreService" /v "%dl%CoreService1DSTelemetry" /t %dw% /d "0" /f>nul 2>&1
%ra% "HKLM\%smwd%\CoreService" /v "%dl%CoreServiceECSIntegration" /t %dw% /d "0" /f>nul 2>&1
%ra% "HKLM\%smwd%\CoreService" /v "Md%dl%ResController" /t %dw% /d "0" /f>nul 2>&1
:SkipRestoreCoreService
%ra% "HKLM\%smwd%\Features" /v "%el%CACS" /t %dw% /d "0" /f>nul 2>&1
%rd% "HKLM\%smwd%\Features" /v "Protection" /f>nul 2>&1
%ra% "HKLM\%smwd%\Features" /v "TamperProtection" /t %dw% /d "1" /f>nul 2>&1
%ra% "HKLM\%smwd%\Features" /v "TamperProtectionSource" /t %dw% /d "5" /f>nul 2>&1
%ra% "HKLM\%smwd%\Features" /v "MpPlatformKillbitsFromEngine" /t REG_BINARY /d "0000000400000000" /f>nul 2>&1
%ra% "HKLM\%smwd%\Features" /v "MpCapability" /t REG_BINARY /d "ff01000000000000" /f>nul 2>&1
%rq% "HKLM\%smwd%\EcsConfigs">nul 2>&1||goto :SkipRestoreEcsConfigs
%ra% "HKLM\%smwd%\Features\EcsConfigs" /v "%el%AdsSymlinkMitigation_MpRamp" /t %dw% /d "1" /f>nul 2>&1
%ra% "HKLM\%smwd%\Features\EcsConfigs" /v "%el%BmProcessInfoMetastoreMaintenance_MpRamp" /t %dw% /d "1" /f>nul 2>&1
%ra% "HKLM\%smwd%\Features\EcsConfigs" /v "%el%CIWorkaroundOnCFA%el%d_MpRamp" /t %dw% /d "1" /f>nul 2>&1
%ra% "HKLM\%smwd%\Features\EcsConfigs" /v "Md%dl%ResController" /t %dw% /d "0" /f>nul 2>&1
%ra% "HKLM\%smwd%\Features\EcsConfigs" /v "Mp%dl%PropBagNotification" /t %dw% /d "0" /f>nul 2>&1
%ra% "HKLM\%smwd%\Features\EcsConfigs" /v "Mp%dl%ResourceMonitoring" /t %dw% /d "0" /f>nul 2>&1
%ra% "HKLM\%smwd%\Features\EcsConfigs" /v "Mp%el%NoMetaStoreProcessInfoContainer" /t %dw% /d "1" /f>nul 2>&1
%ra% "HKLM\%smwd%\Features\EcsConfigs" /v "Mp%el%PurgeHipsCache" /t %dw% /d "1" /f>nul 2>&1
%rd% "HKLM\%smwd%\Features\EcsConfigs" /v "MpFC_AdvertiseLogonMinutesFeature" /f>nul 2>&1
%ra% "HKLM\%smwd%\Features\EcsConfigs" /v "MpFC_%el%CommonMetricsEvents" /t %dw% /d "1" /f>nul 2>&1
%ra% "HKLM\%smwd%\Features\EcsConfigs" /v "MpFC_%el%ImpersonationOnNetworkResourceScan" /t %dw% /d "1" /f>nul 2>&1
%ra% "HKLM\%smwd%\Features\EcsConfigs" /v "MpFC_%el%PersistedScanV2" /t %dw% /d "1" /f>nul 2>&1
%ra% "HKLM\%smwd%\Features\EcsConfigs" /v "MpFC_Kernel_%el%FolderGuardOnPostCreate" /t %dw% /d "1" /f>nul 2>&1
%ra% "HKLM\%smwd%\Features\EcsConfigs" /v "MpFC_Kernel_SystemIoRequestWorkOnBehalfOf" /t %dw% /d "1" /f>nul 2>&1
%ra% "HKLM\%smwd%\Features\EcsConfigs" /v "MpFC_Md%dl%1ds" /t %dw% /d "0" /f>nul 2>&1
%ra% "HKLM\%smwd%\Features\EcsConfigs" /v "MpFC_Md%el%CoreService" /t %dw% /d "1" /f>nul 2>&1
%ra% "HKLM\%smwd%\Features\EcsConfigs" /v "MpFC_Rtp%el%%df%erConfigMonitoring" /t %dw% /d "1" /f>nul 2>&1
%ra% "HKLM\%smwd%\Features\EcsConfigs" /v "MpForceDllHostScanExeOnOpen" /t %dw% /d "1" /f>nul 2>&1
:SkipRestoreEcsConfigs
%ra% "HKLM\%smwd%\Real-Time Protection" /v "%dl%AsyncScanOnOpen" /t %dw% /d "0" /f>nul 2>&1
%ra% "HKLM\%smwd%\Real-Time Protection" /v "%dl%RealtimeMonitoring" /t %dw% /d "0" /f>nul 2>&1
%ra% "HKLM\%smwd%\Real-Time Protection" /v "Dpa%dl%d" /t %dw% /d "0" /f>nul 2>&1
%rd% "HKLM\%smwd%\Scan" /v "AvgCPULoadFactor" /f>nul 2>&1
%ra% "HKLM\%smwd%\Scan" /v "%dl%ArchiveScanning" /t %dw% /d "0" /f>nul 2>&1
%ra% "HKLM\%smwd%\Scan" /v "%dl%EmailScanning" /t %dw% /d "0" /f>nul 2>&1
%ra% "HKLM\%smwd%\Scan" /v "%dl%RemovableDriveScanning" /t %dw% /d "0" /f>nul 2>&1
%ra% "HKLM\%smwd%\Scan" /v "%dl%ScanningMappedNetworkDrivesForFullScan" /t %dw% /d "0" /f>nul 2>&1
%ra% "HKLM\%smwd%\Scan" /v "%dl%ScanningNetworkFiles" /f>nul 2>&1
%rd% "HKLM\%smwd%\Scan" /v "LowCpuPriority" /f>nul 2>&1
%ra% "HKLM\%smwd%\Spynet" /v "MAPSconcurrency" /t %dw% /d "1" /f>nul 2>&1
%ra% "HKLM\%smwd%\Spynet" /v "SpyNetReporting" /t %dw% /d "2" /f>nul 2>&1
%ra% "HKLM\%smwd%\Spynet" /v "SpyNetReportingLocation" /t %sz% /d "SOAP:https://wdcp.microsoft.com/WdCpSrvc.asmx SOAP:https://wdcpalt.microsoft.com/WdCpSrvc.asmx REST:https://wdcp.microsoft.com/wdcp.svc/submitReport REST:https://wdcpalt.microsoft.com/wdcp.svc/submitReport BOND:https://wdcp.microsoft.com/wdcp.svc/bond/submitreport BOND:https://wdcpalt.microsoft.com/wdcp.svc/bond/submitreport" /f>nul 2>&1
%ra% "HKLM\%smwd%\Spynet" /v "SubmitSamplesConsent" /t %dw% /d "1" /f>nul 2>&1
%rd% "HKLM\%smwd%\%wd% Exploit Guard\ASR" /v "%el%ASRConsumers" /f>nul 2>&1
%rd% "HKLM\%smwd%\%wd% Exploit Guard\Controlled Folder Access" /v "%el%ControlledFolderAccess" /f>nul 2>&1
%ra% "HKLM\%smwd%\%wd% Exploit Guard\Network Protection" /v "%el%NetworkProtection" /t %dw% /d "0" /f>nul 2>&1
%rd% "HKLM\%smwci%\ConfigSecurityPolicy.exe" /f>nul 2>&1
%rd% "HKLM\%smwci%\DlpUserAgent.exe" /f>nul 2>&1
%rd% "HKLM\%smwci%\%df%erbootstrapper.exe" /f>nul 2>&1
%rd% "HKLM\%smwci%\mpam-d.exe" /f>nul 2>&1
%rd% "HKLM\%smwci%\mpam-fe.exe" /f>nul 2>&1
%rd% "HKLM\%smwci%\mpam-fe_bd.exe" /f>nul 2>&1
%rd% "HKLM\%smwci%\mpas-d.exe" /f>nul 2>&1
%rd% "HKLM\%smwci%\mpas-fe.exe" /f>nul 2>&1
%rd% "HKLM\%smwci%\mpas-fe_bd.exe" /f>nul 2>&1
%rd% "HKLM\%smwci%\mpav-d.exe" /f>nul 2>&1
%rd% "HKLM\%smwci%\mpav-fe.exe" /f>nul 2>&1
%rd% "HKLM\%smwci%\mpav-fe_bd.exe" /f>nul 2>&1
%rd% "HKLM\%smwci%\UpdatePlatform.amd64fre.exe" /f>nul 2>&1
%rd% "HKLM\%smwci%\MpCmdRun.exe" /f>nul 2>&1
%rd% "HKLM\%smwci%\MpCopyAccelerator.exe" /f>nul 2>&1
%rd% "HKLM\%smwci%\Mp%df%erCoreService.exe" /f>nul 2>&1
%rd% "HKLM\%smwci%\MpDlpCmd.exe" /f>nul 2>&1
%rd% "HKLM\%smwci%\MpDlpService.exe" /f>nul 2>&1
%rd% "HKLM\%smwci%\mpextms.exe" /f>nul 2>&1
%rd% "HKLM\%smwci%\MpSigStub.exe" /f>nul 2>&1
%rd% "HKLM\%smwci%\MsMpEng.exe" /v "Debugger" /f>nul 2>&1
%rd% "HKLM\%smwci%\MsMpEngCP.exe" /v "Debugger" /f>nul 2>&1
%rd% "HKLM\%smwci%\MsSense.exe" /v "Debugger" /f>nul 2>&1
%rd% "HKLM\%smwci%\NisSrv.exe" /f>nul 2>&1
%rd% "HKLM\%smwci%\OfflineScannerShell.exe" /f>nul 2>&1
%rd% "HKLM\%smwci%\SecureKernel.exe" /f>nul 2>&1
%rd% "HKLM\%smwci%\SecurityHealthHost.exe" /f>nul 2>&1
%rd% "HKLM\%smwci%\SecurityHealthService.exe" /f>nul 2>&1
%rd% "HKLM\%smwci%\SecurityHealthSystray.exe" /f>nul 2>&1
%rd% "HKLM\%smwci%\SenseAP.exe" /f>nul 2>&1
%rd% "HKLM\%smwci%\SenseAPToast.exe" /f>nul 2>&1
%rd% "HKLM\%smwci%\SenseCM.exe" /f>nul 2>&1
%rd% "HKLM\%smwci%\SenseGPParser.exe" /f>nul 2>&1
%rd% "HKLM\%smwci%\SenseIdentity.exe" /f>nul 2>&1
%rd% "HKLM\%smwci%\SenseImdsCollector.exe" /f>nul 2>&1
%rd% "HKLM\%smwci%\SenseIR.exe" /f>nul 2>&1
%rd% "HKLM\%smwci%\SenseNdr.exe" /f>nul 2>&1
%rd% "HKLM\%smwci%\SenseSampleUploader.exe" /f>nul 2>&1
%rd% "HKLM\%smwci%\SenseTVM.exe" /f>nul 2>&1
%rd% "HKLM\%smwci%\SenseCE.exe" /f>nul 2>&1
%rd% "HKLM\%smwci%\SgrmBroker.exe" /f>nul 2>&1
%rd% "HKLM\%smwci%\%ss%.exe" /f>nul 2>&1
%rd% "HKLM\%smwci%\MRT.exe" /v "Debugger" /f>nul 2>&1
%ra% "HKLM\%smw% NT\%cv%\Svchost" /v "WebThreatDefense" /t %msz% /d "webthreatdefsvc" /f>nul 2>&1
for %%s in (Win%df% MDCoreSvc WdNisSvc Sense SgrmBroker webthreatdefsvc webthreatdefusersvc WdNisDrv WdBoot WdDevFlt WdFilter SgrmAgent MsSecWfp MsSecFlt MsSecCore wtd KslD AppID AppIDSvc applockerfltr wscsvc SecurityHealthService) do call :UnBrokeService "%%~s"
%ra% "HKLM\%smw%\%cv%\AppHost" /v "%el%WebContentEvaluation" /t %dw% /d "1" /f>nul 2>&1
%rd% "HKLM\%smw%\%cv%\Explorer" /v "Aic%el%d" /f>nul 2>&1
%rd% "HKLM\%smw%\%cv%\Explorer" /v "%ss%%el%d" /f>nul 2>&1
%ra% "HKLM\%smw%\%cv%\Explorer\StartupApproved\Run" /v "SecurityHealth" /t REG_BINARY /d "040000000000000000000000" /f>nul 2>&1
%rd% "HKLM\%smw%\%cv%\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance" /f>nul 2>&1
%ra% "HKLM\%smw%\%cv%\Run" /v "SecurityHealth" /t %sz% /d "%sysdir%SecurityHealthSystray.exe" /f>nul 2>&1
%rd% "HKLM\%smw%\%cv%\Run\Autoruns%dl%d" /f>nul 2>&1
%ra% "HKLM\%smw%\%cv%\Shell Extensions\Approved" /v "{09A47860-11B0-4DA5-AFA5-26D86198A780}" /t %sz% /d "EPP" /f>nul 2>&1
%rd% "HKLM\%smw%\%cv%\Shell Extensions\Blocked" /f>nul 2>&1
%ra% "HKLM\%smw%\%cv%\%evt%%wd%\Operational" /v "%el%d" /t %dw% /d "1" /f>nul 2>&1
%ra% "HKLM\%smw%\%cv%\%evt%%wd%\WHC" /v "%el%d" /t %dw% /d "1" /f>nul 2>&1
%rd% "HKLM\%smw%\MicrosoftEdge\PhishingFilter" /f>nul 2>&1
%rd% "HKLM\%spmwd% Security Center" /f>nul 2>&1
%rd% "HKLM\%spmwd%" /f>nul 2>&1
%rd% "HKLM\%spm%\Edge" /f>nul 2>&1
%rd% "HKLM\%spm%\MicrosoftEdge\PhishingFilter" /f>nul 2>&1
%rd% "HKLM\%spm%\Windows\DeviceGuard" /f>nul 2>&1
%rd% "HKLM\%spm%\Windows\System" /v "RunAsPPL" /f>nul 2>&1
%rd% "HKLM\%spm%\Windows\System" /v "%el%%ss%" /f>nul 2>&1
%rd% "HKLM\%spm%\Windows\System" /v "Shell%ss%Level" /f>nul 2>&1
%rd% "HKLM\%spm%\Windows\WTDS\Components" /f>nul 2>&1
%ra% "HKLM\SOFTWARE\WOW6432Node\Classes\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}" /ve /t %sz% /d "%ss%" /f>nul 2>&1
%ra% "HKLM\SOFTWARE\WOW6432Node\Classes\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}" /v "AppID" /t %sz% /d "{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}" /f>nul 2>&1
%ra% "HKLM\%scc%\CI\Config" /v "VulnerableDriverBlocklistEnable" /t %dw% /d "1" /f>nul 2>&1
%rd% "HKLM\%scc%\CI\State" /f>nul 2>&1
%rd% "HKLM\%sccd%" /v "%el%VirtualizationBasedSecurity" /f>nul 2>&1
%rd% "HKLM\%sccd%" /v "Locked" /f>nul 2>&1
%rd% "HKLM\%sccd%" /v "RequirePlatformSecurityFeatures" /f>nul 2>&1
%rd% "HKLM\%sccd%" /v "RequireMicrosoftSignedBootChain" /f>nul 2>&1
%rd% "HKLM\%sccd%\Scenarios\CredentialGuard" /f>nul 2>&1
%rd% "HKLM\%sccd%\Scenarios\HypervisorEnforcedCodeIntegrity" /f>nul 2>&1
%rd% "HKLM\%sccd%\Scenarios\KernelShadowStacks" /f>nul 2>&1
%rd% "HKLM\%sccd%\Capabilities" /f>nul 2>&1
%ra% "HKLM\%scc%\Ubpm" /v "CriticalMaintenance_%df%erCleanup" /t %sz% /d "NT Task\Microsoft\Windows\%wd%\%wd% Cleanup" /f>nul 2>&1
%ra% "HKLM\%scc%\Ubpm" /v "CriticalMaintenance_%df%erVerification" /t %sz% /d "NT Task\Microsoft\Windows\%wd%\%wd% Verification" /f>nul 2>&1
%ra% "HKLM\%scc%\WMI\Autologger\%df%erApiLogger" /v "Start" /t %dw% /d "1" /f>nul 2>&1
%ra% "HKLM\%scc%\WMI\Autologger\%df%erAuditLogger" /v "Start" /t %dw% /d "1" /f>nul 2>&1
%ra% "HKLM\%scs%\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System" /v "WebThreatDefSvc_Allow_In" /t %sz% /d "v2.0|Action=Allow|Dir=In|App=%%SystemRoot%%\system32\svchost.exe|Svc=WebThreatDefSvc|LPort=443|Protocol=6|Name=Allow WebThreatDefSvc to receive from port 443|" /f>nul 2>&1
%ra% "HKLM\%scs%\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System" /v "WebThreatDefSvc_Allow_Out" /t %sz% /d "v2.0|Action=Allow|Dir=Out|App=%%SystemRoot%%\system32\svchost.exe|Svc=WebThreatDefSvc|RPort=443|Protocol=6|Name=Allow WebThreatDefSvc to send to port 443|" /f>nul 2>&1
%ra% "HKLM\%scs%\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System" /v "WebThreatDefSvc_Block_In" /t %sz% /d "v2.0|Action=Block|Dir=In|App=%%SystemRoot%%\system32\svchost.exe|Svc=WebThreatDefSvc|Name=Block inbound traffic to WebThreatDefSvc|" /f>nul 2>&1
%ra% "HKLM\%scs%\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System" /v "WebThreatDefSvc_Block_Out" /t %sz% /d "v2.0|Action=Block|Dir=Out|App=%%SystemRoot%%\system32\svchost.exe|Svc=WebThreatDefSvc|Name=Block outbound traffic to WebThreatDefSvc|" /f>nul 2>&1
%ra% "HKLM\%scs%\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System" /v "Windows%df%er-1" /t %sz% /d "v2.0|Action=Allow|Active=TRUE|Dir=Out|Protocol=6|App=%%ProgramFiles%%\%wd%\MsMpEng.exe|Svc=Win%df%|Name=Allow Out TCP traffic from Win%df%|" /f>nul 2>&1
%ra% "HKLM\%scs%\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System" /v "Windows%df%er-2" /t %sz% /d "v2.0|Action=Block|Active=TRUE|Dir=In|App=%%ProgramFiles%%\%wd%\MsMpEng.exe|Svc=Win%df%|Name=Block All In traffic to Win%df%|" /f>nul 2>&1
%ra% "HKLM\%scs%\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System" /v "Windows%df%er-3" /t %sz% /d "v2.0|Action=Block|Active=TRUE|Dir=Out|App=%%ProgramFiles%%\%wd%\MsMpEng.exe|Svc=Win%df%|Name=Block All Out traffic from Win%df%|" /f>nul 2>&1
%rq% "HKLM\%scs%\MDCoreSvc">nul 2>&1&&%ra% "HKLM\%scs%\MDCoreSvc" /v "Start" /t %dw% /d 2 /f>nul 2>&1
%rq% "HKLM\%scs%\MsSecCore">nul 2>&1&&%ra% "HKLM\%scs%\MsSecCore" /v "Start" /t %dw% /d 0 /f>nul 2>&1
%rq% "HKLM\%scs%\MsSecFlt">nul 2>&1&&%ra% "HKLM\%scs%\MsSecFlt" /v "Start" /t %dw% /d 3 /f>nul 2>&1
%rq% "HKLM\%scs%\MsSecWfp">nul 2>&1&&%ra% "HKLM\%scs%\MsSecWfp" /v "Start" /t %dw% /d 3 /f>nul 2>&1
%rq% "HKLM\%scs%\SecurityHealthService">nul 2>&1&&%ra% "HKLM\%scs%\SecurityHealthService" /v "Start" /t %dw% /d 3 /f>nul 2>&1
%rq% "HKLM\%scs%\Sense">nul 2>&1&&%ra% "HKLM\%scs%\Sense" /v "Start" /t %dw% /d 3 /f>nul 2>&1
%rq% "HKLM\%scs%\SgrmAgent">nul 2>&1&&%ra% "HKLM\%scs%\SgrmAgent" /v "Start" /t %dw% /d 0 /f>nul 2>&1
%rq% "HKLM\%scs%\SgrmBroker">nul 2>&1&&%ra% "HKLM\%scs%\SgrmBroker" /v "Start" /t %dw% /d 2 /f>nul 2>&1
%rq% "HKLM\%scs%\WdBoot">nul 2>&1&&%ra% "HKLM\%scs%\WdBoot" /v "Start" /t %dw% /d 0 /f>nul 2>&1
%rq% "HKLM\%scs%\WdDevFlt">nul 2>&1&&%ra% "HKLM\%scs%\WdDevFlt" /v "Start" /t %dw% /d 0 /f>nul 2>&1
%rq% "HKLM\%scs%\WdFilter">nul 2>&1&&%ra% "HKLM\%scs%\WdFilter" /v "Start" /t %dw% /d 0 /f>nul 2>&1
%rq% "HKLM\%scs%\WdNisDrv">nul 2>&1&&%ra% "HKLM\%scs%\WdNisDrv" /v "Start" /t %dw% /d 3 /f>nul 2>&1
%rq% "HKLM\%scs%\WdNisSvc">nul 2>&1&&%ra% "HKLM\%scs%\WdNisSvc" /v "Start" /t %dw% /d 3 /f>nul 2>&1
%rq% "HKLM\%scs%\webthreatdefsvc">nul 2>&1&&%ra% "HKLM\%scs%\webthreatdefsvc" /v "Start" /t %dw% /d 3 /f>nul 2>&1
%rq% "HKLM\%scs%\webthreatdefusersvc">nul 2>&1&&%ra% "HKLM\%scs%\webthreatdefusersvc" /v "Start" /t %dw% /d 2 /f>nul 2>&1
%rq% "HKLM\%scs%\Win%df%">nul 2>&1&&%ra% "HKLM\%scs%\Win%df%" /v "Start" /t %dw% /d 2 /f>nul 2>&1
%rq% "HKLM\%scs%\wscsvc">nul 2>&1&&%ra% "HKLM\%scs%\wscsvc" /v "Start" /t %dw% /d 2 /f>nul 2>&1
%rq% "HKLM\%scs%\wtd">nul 2>&1&&%ra% "HKLM\%scs%\wtd" /v "Start" /t %dw% /d 2 /f>nul 2>&1
%rq% "HKLM\%scs%\KslD">nul 2>&1&&%ra% "HKLM\%scs%\KslD" /v "Start" /t %dw% /d 3 /f>nul 2>&1
%rq% "HKLM\%scs%\AppID">nul 2>&1&&%ra% "HKLM\%scs%\AppID" /v "Start" /t %dw% /d 3 /f>nul 2>&1
%rq% "HKLM\%scs%\AppIDSvc">nul 2>&1&&%ra% "HKLM\%scs%\AppIDSvc" /v "Start" /t %dw% /d 3 /f>nul 2>&1
%rq% "HKLM\%scs%\applockerfltr">nul 2>&1&&%ra% "HKLM\%scs%\applockerfltr" /v "Start" /t %dw% /d 3 /f>nul 2>&1
%ra% "HKLM\%smw%\%cv%\WTDS\Components" /v "Service%el%d" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM\%smw%\%cv%\WTDS\Components" /v "NotifyUnsafeApp" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM\%smw%\%cv%\WTDS\Components" /v "NotifyPasswordReuse" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM\%smw%\%cv%\WTDS\Components" /v "NotifyMalicious" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM\%smw%\%cv%\WTDS\Components" /v "CaptureThreatWindow" /t %dw% /d 1 /f>nul 2>&1
%rd% "HKLM\%spm%\Windows\WTDS" /f>nul 2>&1
%rd% "HKLM\%spm%\MRT" /f>nul 2>&1
%rd% "HKLM\%smw%\%cv%\Policies\System\Audit" /v "ProcessCreationIncludeCmdLine_%el%d" /f>nul 2>&1
%rd% "HKLM\System\CurrentControlSet\Policies\EarlyLaunch" /f>nul 2>&1
%rd% "HKLM\%smw%\Windows Error Reporting" /v "%dl%d" /f>nul 2>&1
%rd% "HKLM\%smw%Mitigation" /f>nul 2>&1
%ra% "HKLM\%scc%\Session Manager\kernel" /v "MitigationAuditOptions" /f>nul 2>&1
%ra% "HKLM\%scc%\Session Manager\kernel" /v "MitigationOptions" /f>nul 2>&1
%ra% "HKLM\%scc%\Session Manager\kernel" /v "KernelSEHOP%el%d" /f>nul 2>&1
%ra% "HKLM\%scc%\Session Manager\kernel" /v "%dl%ExceptionChainValidation" /f>nul 2>&1
%ra% "HKLM\%scc%\SCMConfig" /v "%el%SvchostMitigationPolicy" /f>nul 2>&1
%reg% copy "HKLM\%scc%\SafeBoot\Minimal\Win%df%_off" "HKLM\%scc%\SafeBoot\Minimal\Win%df%"/s /f>nul 2>&1>nul 2>&1
%rd% "HKLM\%scc%\SafeBoot\Minimal\Win%df%_off" /f>nul 2>&1
call :EventsWork 1
%msg% "Restore code integrity policies..." "Восстановление политик целостности кода..."
set "efi="
for %%a in (Z Y X W V U T S R Q P O N M L K J I H G F E D) do if not exist %%a:\nul set "efi=%%a:"&goto :FoundFreeDiskRestore
:FoundFreeDiskRestore
%ifdef% efi (
	%mountvol% %efi% /s >nul 2>&1
	move /y "%efi%\EFI\Microsoft\Boot\CIPolicies\%dl%d\*.p7b" "%efi%\EFI\Microsoft\Boot\" >nul 2>&1
	move /y "%efi%\EFI\Microsoft\Boot\CIPolicies\%dl%d\*.cip" "%efi%\EFI\Microsoft\Boot\CIPolicies\Active\" >nul 2>&1
	rd /s /q "%efi%\EFI\Microsoft\Boot\CIPolicies\%dl%d">nul 2>&1
	%mountvol% %efi% /d >nul 2>&1
)
move /y "%sysdir%CodeIntegrity\CIPolicies\%dl%d\*.p7b" "%sysdir%CodeIntegrity\" >nul 2>&1
move /y "%sysdir%CodeIntegrity\CIPolicies\%dl%d\*.cip" "%sysdir%CodeIntegrity\CIPolicies\Active\" >nul 2>&1
rd /s /q "%sysdir%CodeIntegrity\CIPolicies\%dl%d">nul 2>&1
if exist "%save%MySecurityDefaults.reg" %reg% import "%save%MySecurityDefaults.reg">nul 2>&1
%ra% "HKLM\%scc%\CI\Policy" /v "VerifiedAndReputablePolicyState" /t %dw% /d "0" /f>nul 2>&1
%ra% "HKLM\%sccd%\Scenarios\HypervisorEnforcedCodeIntegrity" /v "%el%d" /t %dw% /d 0 /f>nul 2>&1
%bcdedit% /deletevalue {current} vsmlaunchtype>nul 2>&1
set ForRestore=
%ifdef% NoReboot4restore %msg% "DONE" "ЗАВЕРШЕНО"&%timeout% /t 3&exit
exit /b

:UnBrokeService
setlocal EnableDelayedExpansion
%rq% "HKLM\%scs%\%~1" >nul 2>&1 && (
	set "DependOnServiceValue="
    for /f "tokens=3,*" %%a in ('%rq% "HKLM\%scs%\%~1" /v "DependOnServiceOriginal" 2^>nul') do set "DependOnServiceValue=%%a"
	%rd% "HKLM\%scs%\%~1" /v "DependOnServiceOriginal" /f>nul 2>&1
    (%rq% "HKLM\%scs%\%~1" /v "DependOnService" 2>nul|%find% "OFF">nul 2>&1)&&(%rd% "HKLM\%scs%\%~1" /v "DependOnService" /f>nul 2>&1)
	if not "!DependOnServiceValue!"=="" %ra% "HKLM\%scs%\%~1" /v "DependOnService" /t %msz% /d "!DependOnServiceValue!" /f >nul 2>&1
)
endlocal
exit /b

:ListUWP
set "UWP=%~1"
set UwpName=
%rq% "%uwpsearch%" /f "*%UWP%*" /k>nul 2>&1&&for /f "tokens=*" %%a in ('%rq% "%uwpsearch%" /f "*%UWP%*" /k^|^|goto :EndSearchListUWP') do (set "UwpName=%%~nxa"&goto :EndSearchListUWP)
:EndSearchListUWP
%ifNdef% UwpName exit /b
echo HKLM:\%smw%\%cv%\Appx\AppxAllUserStore\Deprovisioned\%UwpName%>>"%temp%\hkcu.list"
echo HKLM:\%smw%\%cv%\Appx\AppxAllUserStore\EndOfLife\S-1-5-18\%UwpName%>>"%temp%\hkcu.list"
for /f "tokens=*" %%a in ('%rq% "HKLM\%smw%\%cv%\Appx\AppxAllUserStore" ^| %findstr% /R /C:"S-1-5-21-*"') do (
	echo HKLM:\%smw%\%cv%\Appx\AppxAllUserStore\EndOfLife\%%~nxa\%UwpName%>>"%temp%\hkcu.list"
	echo HKLM:\%smw%\%cv%\Appx\AppxAllUserStore\Deleted\EndOfLife\%%~nxa\%UwpName%>>"%temp%\hkcu.list"
	echo HKLM:\%smw%\%cv%\Appx\AppxAllUserStore\%%~nxa\%UwpName%>>"%temp%\hkcu.list")
exit /b

:BlockUWP
set "UWP=%~1"
set UwpName=
%rq% "%uwpsearch%" /f "*%UWP%*" /k>nul 2>&1&&for /f "tokens=2" %%a in ('%rq% "%uwpsearch%" /f "*%UWP%*" /k^|^|goto :EndSearchBlockUWP') do (set "UwpName=%%~nxa"&goto :EndSearchBlockUWP)
:EndSearchBlockUWP
%ifNdef% UwpName exit /b
%ra% "HKLM\%smw%\%cv%\Appx\AppxAllUserStore\Deprovisioned\%UwpName%" /f>nul 2>&1
%ra% "HKLM\%smw%\%cv%\Appx\AppxAllUserStore\EndOfLife\S-1-5-18\%UwpName%" /f>nul 2>&1
for /f "tokens=*" %%a in ('%rq% "HKLM\%smw%\%cv%\Appx\AppxAllUserStore" ^| %findstr% /R /C:"S-1-5-21-*"') do (
	%ra% "HKLM\%smw%\%cv%\Appx\AppxAllUserStore\EndOfLife\%%~nxa\%UwpName%" /f>nul 2>&1
	%ra% "HKLM\%smw%\%cv%\Appx\AppxAllUserStore\Deleted\EndOfLife\%%~nxa\%UwpName%" /f>nul 2>&1
)
exit /b

:UnBlockUWP
set "UWP=%~1"
set UwpName=
set UwpPath=
%rq% "%uwpsearch%" /f "*%UWP%*" /k>nul 2>&1&&for /f "tokens=*" %%a in ('%rq% "%uwpsearch%" /f "*%UWP%*" /k') do (set "UwpName=%%~nxa"&goto :EndSearchUnBlockUWP)
%rq% "HKLM\%smw%\%cv%\Appx\AppxAllUserStore\InboxApplications" /f "*%UWP%*" /k>nul 2>&1&&for /f "tokens=*" %%a in ('%rq% "HKLM\%smw%\%cv%\Appx\AppxAllUserStore\InboxApplications" /f "*%UWP%*" /k') do (set "UwpName=%%~nxa"&goto :EndSearchUnBlockUWP)
%rq% "HKLM\%smw%\%cv%\Appx\AppxAllUserStore\Deprovisioned" /f "*%UWP%*" /k>nul 2>&1&&for /f "tokens=*" %%a in ('%rq% "HKLM\%smw%\%cv%\Appx\AppxAllUserStore\Deprovisioned" /f "*%UWP%*" /k') do (set "UwpName=%%~nxa"&goto :EndSearchUnBlockUWP)
:EndSearchUnBlockUWP
%ifNdef% UwpName exit /b
for /f "tokens=2*" %%a in ('%rq% "%uwpsearch%\%UwpName%" /v "Path" 2^>nul') do set "UwpPath=%%b"
%ifNdef% UwpPath for /f "tokens=2*" %%a in ('%rq% "HKLM\%smw%\%cv%\Appx\AppxAllUserStore\InboxApplications\%UwpName%" /v "Path" 2^>nul') do set "UwpPath=%%b"
%ifNdef% UwpPath for /d %%f in ("%windir%\SystemApps\*%UWP%*") do set "UwpPath=%%f\AppXManifest.xml"
%ifNdef% UwpPath for /d %%f in ("%ProgramFiles%\WindowsApps\*%UWP%*") do set "UwpPath=%%f\AppXManifest.xml"
%rd% "HKLM\%smw%\%cv%\Appx\AppxAllUserStore\Deprovisioned\%UwpName%" /f >nul 2>&1
%rd% "HKLM\%smw%\%cv%\Appx\AppxAllUserStore\EndOfLife\S-1-5-18\%UwpName%" /f >nul 2>&1
for /f "tokens=*" %%a in ('%rq% "HKLM\%smw%\%cv%\Appx\AppxAllUserStore" ^| %findstr% /R /C:"S-1-5-21-*"') do (
	%rd% "HKLM\%smw%\%cv%\Appx\AppxAllUserStore\EndOfLife\%%~nxa\%UwpName%" /f >nul 2>&1
	%rd% "HKLM\%smw%\%cv%\Appx\AppxAllUserStore\Deleted\EndOfLife\%%~nxa\%UwpName%" /f >nul 2>&1
)
chcp 437 >nul 2>&1
%ifdef% UwpPath %powershell% -MTA -NoP -NoL -NonI -EP Bypass -c "Add-AppxPackage -%dl%DevelopmentMode -Register '%UwpPath%'" >nul 2>&1
%ifNdef% SAFEBOOT_OPTION %powershell% -MTA -NoP -NoL -NonI -EP Bypass -c "Reset-AppxPackage -Package %UwpName%" >nul 2>&1
chcp 65001 >nul 2>&1
exit /b

:WinRE
set winre=
for /f "delims=" %%i in ('%reagentc% /info ^| %findstr% /i "%el%d"') do (if not errorlevel 1 (set winre=1))
%ifNdef% winre %reagentc% /enable>nul 2>&1
for /f "delims=" %%i in ('%reagentc% /info ^| %findstr% /i "%el%d"') do (if not errorlevel 1 (set winre=1))
%ifNdef% winre ( 
		%ifNdef% SAFEBOOT_OPTION (
			%msg% "Windows Recovery Environment is missing or cannot be enabled" "В системе отсутствует Среда восстановления Windows или её невозвможно включить"
		    ) else (
			%msg% "You cannot reboot into WinRE from Safe Mode" "Нельзя перезагрузиться в WinRE из безопасного режима"
		    )
)
%ifNdef% winre %ifNdef% arg1 (echo.&pause&goto :Menu7) else (exit)
%reagentc% /boottore>nul 2>&1
%manage-bde% -protectors %sys%: -%dl% -rebootcount 1 >nul 2>&1
%msg% "The computer will now reboot into Windows Recovery Environment" "Компьютер сейчас перезагрузиться в Среду восстановления Windows"
%ifNdef% arg1 (%shutdown% /r /f /t 3 /c "Reboot WinRE") else (%shutdown% /r /f /t 1 /c "Reboot WinRE")
%timeout% 4
exit /b

:SAC
reg load HKLM\sac %sys%:\windows\system32\config\system
reg add HKLM\sac\controlset001\control\ci\policy /v VerifiedAndReputablePolicyState /t REG_DWORD /d 2 /f 
reg add HKLM\sac\controlset001\control\ci\protected /v VerifiedAndReputablePolicyStateMinValueSeen /t REG_DWORD /d 2 /f
reg unload HKLM\sac
reg load HKLM\sac2 %sys%:\windows\system32\config\SOFTWARE
reg add "HKLM\sac2\Microsoft\%wd%" /v SacLearningModeSwitch /t REG_DWORD /d 0 /f
reg unload HKLM\sac2
goto :EOF

:MiniHelp
cls
echo.
%msg% " [32;4mGroup Policies                                                                    [0m" " [32;4mГрупповые политики                                                                [0m"
echo.
%msg% " Legally. Documented. Incomplete." " Легально. Документированно. Неполноценно."
%msg% " Only known group policies are applied through the registry and .pol files." " Применяются только известные групповые политики через реестр и файлы .pol."
%msg% " Drivers, services, and background processes are active," " Драйверы, службы и фоновые процессы активны,"
%msg% " but do not perform any actions." " но не выполняют никаких действий."
echo.
%msg% " [1;33;4mPolicies + Registry Settings                                                      [0m" " [1;33;4mПолитики + Настройки реестра                                                      [0m"
echo.
%msg% " Semi-legally. Almost complete." " Полулегально. Почти полноценно."
%msg% " In addition to policies, known tweaks are applied to %dl%" " В дополнение к политикам применяются известные твики отключающие"
%msg% " various protection aspects." " различные аспекты защит."
%msg% " Only drivers and services are active in the background, performing no actions" " Только драйверы и службы активны в фоне, не выполняют никаких действий"
echo.
%msg% " [33;4mPolicies + Settings + Disabling Services and drivers                              [0m" " [33;4mПолитики + Настройки + Отключение служб и драйверов                               [0m"
echo.
%msg% " Illegally. Complete." " Нелегально. Полноценно."
%msg% " Also %dl%s the startup of all related services and drivers." " Также отключается запуск всех сопутствующих служб и драйверов."
%msg% " No background activities" " Никаких фоновых активностей"
echo.
%ifdef% ViewBlock %msg% " [1;31;4mPolicies + Settings + Disabling Services and drivers + Block launch               [0m" " [1;31;4mПолитики + Настройки + Отключение служб и драйверов + Блокировка запуска          [0m"
%ifdef% ViewBlock echo.
%ifdef% ViewBlock %msg% " Hacker-style. Excessive." " По-хакерски. Избыточно."
%ifdef% ViewBlock %msg% " Blocks the launch of known protection processes by assigning an incorrect debugger" " Блокируется запуск известных процессов защит с помощью назначения неправильного"
%ifdef% ViewBlock %msg% " in the registry and blocking the startup of services using a broken dependency." " дебагера в реестре и блокировка запуска служб с помощью сломанной зависимости."
%ifdef% ViewBlock %msg% " Helps reduce the risk of enabling the %df%er during a Windows update." " Помогает снизить риск включения защитника при обновлении Windows."
%ifdef% ViewBlock %msg% " However, it may cause freezes if the defender is enabled during updates." " Но может привести к зависаниям в случае включения защитника при обновлении."
%msg% " [4;1;30mPress any key to return...                                                        [0m" " [4;1;30mНажмите любую клавишу для возврата...                                             [0m"
pause>nul 2>&1
exit /b

:Status
cls
%msg% "[1;32mSystem analysis...[0m" "[1;32mАнализ системы...[0m"
set ON=[31mON[0m
set OFF=[1;32mOFF[0m
set DEL=[1;35mDEL[0m
set OFFRUN=[32mOFF[0m [1;35mRUNNING[0m
set ONLOCK=[31mON[0m [1;35mLOCKED[0m
set "defend=[4;36mMicrosoft %df%er                                                       [0m "
set "ssn=[4;36mSmartscreen                                                              [0m "
set "secb= [SecureBoot "
set "bitl= [BitLocker "
%ifNdef% Lang (
	set "av= Third-party Antivirus: "
	set "noav= Third-party antivirus is not installed or registered in the security center"
	set "avfilt= Antivirus is installed but not registered in the security center. "
	set "realtime= Real-time protection                                                     "
	set "tamper= Tamper protection                                                        "
	set "smart= Smart App Control                                                        "
	set "vbs= Virtual based security                                                   "
	set "lsa= Local Security Authority protection                                      "
	set "cred= Credential Guard                                                         "
	set "asrr= Attack surface reduction ASR rules [%el%d]                            "
	set "sht= Sheduled tasks         [%el%d^|Total]                                  "
    set "evts= Event logs             [%el%d^|Total]                                  "
	set "conm= Context menu                                                             "
	set "serv= [4;1mServices[4;1;30m                                                                [0m"
	set  "drv= [4;1mDrivers[4;1;30m                                                                 [0m"
	set "ssp= Smartscreen parameters [%el%d^|Total]                                  "
	set "ssd=Warning for downloaded files      "
	set "wsec=[4;36mWindows Security                                                         [0m "
    set "uwpsec=UWP App                           "
   	set "hid=Visible in settings               "
	set "noti=Notifications                     "
	set "tray=Tray icon                         "
	set "aplk= AppLocker drivers and services                                          "
	set "cippol= Code integrity [App Control] policies [Active]                 "
) else (
	set "av= Сторонний антивирус: "
	set "noav= Сторонний антивирус не установлен или не зарегистрирован в центре безопасности"
	set "avfilt= Антивирус установлен но не зарегистрирован в центре безопасности. "
	set "realtime= Защита в реальном времени                                                "
	set "tamper= Защита от подделки                                                       "
	set "smart= Интеллектуальное управление приложениями                                 "
	set "vbs= Безопасность на основе виртуализации                                     "
	set "lsa= Защита локальной системы безопасности                                    "
	set "cred= Credential Guard                                                         "
	set "asrr= Правила сокращения направлений атак ASR [Включено]                      "
	set "sht= Задачи в планировщике [Включено^|Всего]                                  "
    set "evts= Журналы событий       [Включено^|Всего]                                  "
	set "conm= Контекстное меню                                                         "
	set "serv= [4;1mСлужбы[4;1;30m                                                                  [0m"
	set  "drv= [4;1mДрайверы[4;1;30m                                                                [0m"
	set "ssp= Параметры Smartscreen [Включено^|Всего]                                  "
	set "ssd=Оповещение для скачанных файлов   "
	set "wsec=[4;36mБезопасность Windows                                                     [0m "
    set "uwpsec=UWP приложение                    "
	set "hid=Видно в настройках                "
	set "noti=Уведомления                       "
	set "tray=Значок в трее                     "
	set "aplk= AppLocker драйверы и службы                                             "
	set "cippol= Политики целостности кода [Управления приложениями] [Активные]    " 
)
%ifdef% WindowsVersion goto :SkipWinVer
%msg% "Determining the Windows version..." "Определение версии Windows..."
for /f "tokens=4 delims= " %%v in ('ver') do set "win=%%v"
for /f "tokens=3 delims=." %%v in ('echo  %win%') do set /a "build=%%v"
for /f "tokens=1 delims=." %%v in ('echo  %win%') do set /a "win=%%v"
for /f "tokens=4" %%a in ('ver') do set "WindowsBuild=%%a"
set "WindowsBuild=%WindowsBuild:~5,-1%"
for /f "tokens=2*" %%a in ('%rq% "HKLM\%smw% NT\%cv%" /v ProductName') do set "WindowsVersion=%%b"
if [%build%] gtr [22000] set WindowsVersion=%WindowsVersion:10=11%
:SkipWinVer
%msg% " [1;36m%WindowsVersion% %WindowsBuild%[0m [34m[script %asv%][0m [4;1;30mSystem analysis...[0m" " [1;36m%WindowsVersion% %WindowsBuild%[0m [34m[script %asv%][0m [4;1;30mАнализ системы...[0m"
%msg% "[1;32mSystem analysis...[0m" "[1;32mАнализ системы...[0m"
set "ActiveAV="
chcp 437 >nul 2>&1
for /f "usebackq tokens=*" %%G IN (`%sysdir%WindowsPowerShell\v1.0\powershell.exe -MTA -NoP -NoL -NonI -EP Bypass -c "Get-WmiObject -ClassName AntiVirusProduct -Namespace root/SecurityCenter2 | Where-Object { ($_.productState -eq 397312 -or $_.productState -eq 266240) -and $_.displayName -ne 'Windows Defender' } | Select-Object -ExpandProperty displayName -First 1"`) do (set "ActiveAV=%%G")
chcp 65001 >nul 2>&1
call :CheckAV
%ifdef% ActiveAV (echo %av%[36m%ActiveAV%[0m) else (%ifdef% FiltersAV (echo %avfilt%%FiltersAV%) else (echo %noav%))
%msg% "[1;32mSystem analysis...[0m" "[1;32mАнализ системы...[0m"
chcp 437 >nul 2>&1
%powershell% -MTA -NoL -NonI -EP Bypass -c "Write-host SecureBoot $(Confirm-SecureBootUEFI);Write-Host Bitlocker $((Get-BitLockerVolume -MountPoint %sys%:).VolumeStatus);Get-MpComputerStatus;Get-WmiObject -ClassName Win32_DeviceGuard -Namespace root\Microsoft\Windows\DeviceGuard">"%temp%\%AS%status.txt" 2>&1
chcp 65001 >nul 2>&1
%find% "SecureBoot True" "%temp%\%AS%status.txt">nul 2>&1&&set secboot=1||set secboot=
%find% "Bitlocker FullyEncrypted" "%temp%\%AS%status.txt">nul 2>&1&&set bitlocker=1
%find% "Bitlocker EncryptionInProgress" "%temp%\%AS%status.txt">nul 2>&1&&set bitlocker=1
%ifdef% Lang (set "info=[Службы-Драйверы: [31mЗапущено [33mВключено [1;32mВыключено[0m]") else (set "info=[Services-Drivers:    [31mRunning [33m%el%d [1;32m%dl%d[0m]")
%ifdef% secboot (set "secmsg=%secb%[36mON[0m]") else (set "secmsg=%secb%[36mOFF[0m]")
%ifdef% bitlocker (set "secmsg=%secmsg% %bitl%%ON%]  %info%") else (set "secmsg=%secmsg% %bitl%%OFF%]  %info%")
echo %secmsg%
%msg% "[1;32mSystem analysis...[0m" "[1;32mАнализ системы...[0m"
del /f /q "%temp%\%AS%WTDS.txt">nul 2>&1
if exist "%ProgramFiles%\%wd%\MsMpEng.exe" (set DefExist=1) else (set "DefExist=")
call :isProcess "MsMpEng.exe"&&set DefRun=1||set DefRun=
%find% "Antivirus%el%d" "%temp%\%AS%status.txt">nul 2>&1||goto :SkipPSCheck
%findstr% /r /c:"Antivirus%el%d *: *True" "%temp%\%AS%status.txt" >nul 2>&1&&set DefOn=1||set DefOn=
%findstr% /r /c:"RealTimeProtection%el%d *: *True" "%temp%\%AS%status.txt" >nul 2>&1&& set DefReal=1 || set DefReal=
%findstr% /r /c:"IsTamperProtected *: *True" "%temp%\%AS%status.txt" >nul 2>&1&&set DefTamper=1||set DefTamper=
%findstr% /r /c:"SmartAppControlState *: *On" "%temp%\%AS%status.txt" >nul 2>&1&&set DefSmart=1||set DefSmart=
%ifNdef% DefSmart %findstr% /r /c:"SmartAppControlState *: *Eval" "%temp%\%AS%status.txt" >nul 2>&1&&set DefSmart=1||set DefSmart=
set MpStatus=1
:SkipPSCheck
%ifdef% MpStatus goto :SkipRegCheck
(%rq% "HKLM\%smwd%">nul 2>&1)&&((%rq% "HKLM\%smwd%" /v "%dl%AntiVirus" 2>nul|%find% "0x1">nul 2>&1)&&set "DefOn="||set DefOn=1)
(%rq% "HKLM\%smwd%">nul 2>&1)&&((%rq% "HKLM\%smwd%" /v "%dl%AntiSpyware" 2>nul|%find% "0x1">nul 2>&1)&&set "DefOn=")
(%rq% "HKLM\%smwd%">nul 2>&1)&&((%rq% "HKLM\%smwd%\Real-Time Protection" /v "%dl%RealtimeMonitoring" 2>nul|%find% "0x1">nul 2>&1)&&set "DefReal="||set DefReal=1)||set "DefOn="
(%rq% "HKLM\%smwd%\Features" /v "TamperProtection">nul 2>&1)&&((%rq% "HKLM\%smwd%\Features" /v "TamperProtection" 2>nul|%find% "0x4">nul 2>&1)&&set "DefTamper="||set DefTamper=1)||set "DefTamper="
(%rq% "HKLM\%smwd%" /v "VerifiedAndReputableTrustMode%el%d">nul 2>&1)&&((%rq% "HKLM\%smwd%" /v "VerifiedAndReputableTrustMode%el%d" 2>nul|%find% "0x0">nul 2>&1)&&set "DefSmart="||set DefSmart=1)||set "DefSmart="
:SkipRegCheck
%ifdef% DefExist  (%ifdef% DefRun (%ifdef% DefOn (echo %defend%%ON%) else (echo %defend%%OFFRUN%)) else (echo %defend%%OFF%)) else (echo %defend%%DEL%)
%ifdef% DefReal   (echo %realtime%%ON%) else (echo %realtime%%OFF%)
%ifdef% DefTamper (echo %tamper%%ON%) else (echo %tamper%%OFF%)
%ifdef% DefSmart  (echo %smart%%ON%) else (echo %smart%%OFF%)
chcp 65001 >nul 2>&1
%msg% "[1;32mSystem analysis...[0m" "[1;32mАнализ системы...[0m"
%ifNdef% DefVBS (%rq% "HKLM\%sccd%\Scenarios\HypervisorEnforcedCodeIntegrity" /v "%el%d" 2>nul|%find% "0x1">nul 2>&1)&&set DefVBSreg=1||set DefVBSreg=
%findstr% /r /c:"VirtualizationBasedSecurityStatus *: *\0" "%temp%\%AS%status.txt" >nul 2>&1&&set "DefVBSps="||set DefVBSps=1
del /f /q "%temp%\%AS%status.txt">nul 2>&1
%ifdef% DefVBSreg set DefVBS=1
%ifdef% DefVBSps  set DefVBS=1
%ifNdef% DefVBSreg %ifdef% DefVBSps set DefVBSLock=1
%bcdedit%|%find% "hypervisorlaunchtype    Auto">nul 2>&1&&set "hyperv= [1;35mHyperV[0m"||set "hyperv="
%ifNdef% hyperv %bcdedit%|%find% "hypervisorlaunchtype    On">nul 2>&1&&set "hyperv= [1;35mHyperV[0m"||set "hyperv="
%ifNdef% DefVBSLock %ifdef% DefVBS (%rq% "HKLM\%sccd%\Scenarios\HypervisorEnforcedCodeIntegrity" /v "Locked" 2>nul|%find% "0x1">nul 2>&1)&&set DefVBSLock=1||set DefVBSLock=
%ifdef% DefVBSLock %rq% "HKLM\%smw%\%cv%\RunOnce" /v "NeedRestart">nul 2>&1&&set DefVBSLock=
%ifdef% DefVBS (%ifdef% DefVBSLock (%ifNdef% hyperv (echo %vbs%%ONLOCK%) else (echo %vbs%[36mON[0m%hyperv%)) else (echo %vbs%%ON%)) else (echo %vbs%%OFF%)
(%rq% "HKLM\%scc%\Lsa" /v "RunAsPPLBoot" 2>nul|%find% "0x2">nul 2>&1)&&set DefLsa=1||set DefLsa=
(%rq% "HKLM\%scc%\Lsa" /v "RunAsPPL" 2>nul|%find% "0x2">nul 2>&1)&&set DefLsa=1
(%rq% "HKLM\%scc%\Lsa" /v "RunAsPPLBoot" 2>nul|%find% "0x1">nul 2>&1)&&set DefLsaLock=1||set DefLsaLock=
(%rq% "HKLM\%scc%\Lsa" /v "RunAsPPL" 2>nul|%find% "0x1">nul 2>&1)&&set DefLsaLock=1
(%rq% "HKLM\%spm%\Windows\System" /v "RunAsPPL" 2>nul|%find% "0x1">nul 2>&1)&&set DefLsaLock=1
%ifdef% DefLsaLock    (echo %lsa%%ONLOCK%) else (%ifdef% DefLsa (echo %lsa%%ON%) else (echo %lsa%%OFF%))
(%rq% "HKLM\%scc%\CI\State">nul 2>&1)&&((%rq% "HKLM\%scc%\CI\State" /v "HVCI%el%d" 2>nul|%find% "0x1">nul 2>&1)&&set DefCred=1||set DefCred=)||set DefCred=
(%rq% "HKLM\%sccd%\Scenarios\KeyGuard\Status">nul 2>&1)&&((%rq% "HKLM\%sccd%\Scenarios\KeyGuard\Status" /v "CredGuard%el%d" 2>nul|%find% "0x1">nul 2>&1)&&set DefCred=1||set DefCred=)||set DefCred=
%ifdef% DefCred (%rq% "HKLM\%sccd%\Scenarios\HypervisorEnforcedCodeIntegrity" /v "Locked" 2>nul|%find% "0x1">nul 2>&1)&&set DefCredLock=1||set DefCredLock=
%ifdef% DefCredLock    (echo %cred%%ONLOCK%) else (%ifdef% DefCred (echo %cred%%ON%) else (echo %cred%%OFF%))
set /a ASRCount=0
for /f "tokens=1" %%i in ('%rq% "HKLM\%smwd%\%wd% Exploit Guard\ASR\Rules" 2^>nul ^| %find% "0x1"') do set /a ASRCount+=1
if %ASRCount% gtr 0 (echo %asrr%[[31m%ASRCount%[0m]) else (echo %asrr%[[1;32m0[0m])  
call :process_services "MDCoreSvc Sense webthreatdefsvc webthreatdefusersvc WinDefend"
set /p "colored_services_list=" < "%temp%\%AS%service_list.tmp"
del /f /q "%temp%\%AS%service_list.tmp">nul 2>&1
set "summary_services=[%serv_count_running%^|%serv_count_enabled%^|%serv_count_disabled%^|%serv_count_total%]"
echo %serv%%summary_services%
%ifdef% colored_services_list echo  %colored_services_list%
call :process_services "MsSecFlt MsSecWfp WdNisDrv WdNisSvc wtd WdBoot WdDevFlt WdFilter MsSecCore KslD"
set /p "colored_drivers_list=" < "%temp%\%AS%service_list.tmp"
del /f /q "%temp%\%AS%service_list.tmp">nul 2>&1
set "summary_drivers=[%serv_count_running%^|%serv_count_enabled%^|%serv_count_disabled%^|%serv_count_total%]"
echo %drv%%summary_drivers%
%ifdef% colored_drivers_list echo  %colored_drivers_list%
set /a TasksCount=0
set /a TasksDisabled=0
%schtasks% /Query /TN "Microsoft\Windows\%wd%\%wd% Cache Maintenance">nul 2>&1&&(set /a TasksCount+=1&(%schtasks% /Query /TN "Microsoft\Windows\%wd%\%wd% Cache Maintenance"|%find% "Disabled">nul 2>&1&&set /a TasksDisabled+=1)&(%schtasks% /Query /TN "Microsoft\Windows\%wd%\%wd% Cache Maintenance"|%find% "Отключено">nul 2>&1&&set /a TasksDisabled+=1))
%schtasks% /Query /TN "Microsoft\Windows\%wd%\%wd% Cleanup">nul 2>&1&&(set /a TasksCount+=1&(%schtasks% /Query /TN "Microsoft\Windows\%wd%\%wd% Cleanup"|%find% "Disabled">nul 2>&1&&set /a TasksDisabled+=1)&(%schtasks% /Query /TN "Microsoft\Windows\%wd%\%wd% Cleanup"|%find% "Отключено">nul 2>&1&&set /a TasksDisabled+=1))
%schtasks% /Query /TN "Microsoft\Windows\%wd%\%wd% Scheduled Scan">nul 2>&1&&(set /a TasksCount+=1&(%schtasks% /Query /TN "Microsoft\Windows\%wd%\%wd% Scheduled Scan"|%find% "Disabled">nul 2>&1&&set /a TasksDisabled+=1)&(%schtasks% /Query /TN "Microsoft\Windows\%wd%\%wd% Scheduled Scan"|%find% "Отключено">nul 2>&1&&set /a TasksDisabled+=1))
%schtasks% /Query /TN "Microsoft\Windows\%wd%\%wd% Verification">nul 2>&1&&(set /a TasksCount+=1&(%schtasks% /Query /TN "Microsoft\Windows\%wd%\%wd% Verification"|%find% "Disabled">nul 2>&1&&set /a TasksDisabled+=1)&(%schtasks% /Query /TN "Microsoft\Windows\%wd%\%wd% Verification"|%find% "Отключено">nul 2>&1&&set /a TasksDisabled+=1))
%schtasks% /Query /TN "Microsoft\Windows\%wd%\%wd% Update">nul 2>&1&&(set /a TasksCount+=1&(%schtasks% /Query /TN "Microsoft\Windows\%wd%\%wd% Update"|%find% "Disabled">nul 2>&1&&set /a TasksDisabled+=1)&(%schtasks% /Query /TN "Microsoft\Windows\%wd%\%wd% Update"|%find% "Отключено">nul 2>&1&&set /a TasksDisabled+=1))
%schtasks% /Query /TN "Microsoft\Windows\AppID\%ss%Specific">nul 2>&1&&(set /a TasksCount+=1&(%schtasks% /Query /TN "Microsoft\Windows\AppID\%ss%Specific"|%find% "Disabled">nul 2>&1&&set /a TasksDisabled+=1)&(%schtasks% /Query /TN "Microsoft\Windows\AppID\%ss%Specific"|%find% "Отключено">nul 2>&1&&set /a TasksDisabled+=1))
%schtasks% /Query /TN "Microsoft\Windows\AppID\PolicyConverter">nul 2>&1&&(set /a TasksCount+=1&(%schtasks% /Query /TN "Microsoft\Windows\AppID\PolicyConverter"|%find% "Disabled">nul 2>&1&&set /a TasksDisabled+=1)&(%schtasks% /Query /TN "Microsoft\Windows\AppID\PolicyConverter"|%find% "Отключено">nul 2>&1&&set /a TasksDisabled+=1))
%schtasks% /Query /TN "Microsoft\Windows\AppID\VerifiedPublisherCertStoreCheck">nul 2>&1&&(set /a TasksCount+=1&(%schtasks% /Query /TN "Microsoft\Windows\AppID\VerifiedPublisherCertStoreCheck"|%find% "Disabled">nul 2>&1&&set /a TasksDisabled+=1)&(%schtasks% /Query /TN "Microsoft\Windows\AppID\VerifiedPublisherCertStoreCheck"|%find% "Отключено">nul 2>&1&&set /a TasksDisabled+=1))
%schtasks% /Query /TN "Microsoft\Windows\ExploitGuard\ExploitGuard MDM policy Refresh">nul 2>&1&&(set /a TasksCount+=1&(%schtasks% /Query /TN "Microsoft\Windows\ExploitGuard\ExploitGuard MDM policy Refresh"|%find% "Disabled">nul 2>&1&&set /a TasksDisabled+=1)&(%schtasks% /Query /TN "Microsoft\Windows\ExploitGuard\ExploitGuard MDM policy Refresh"|%find% "Отключено">nul 2>&1&&set /a TasksDisabled+=1))
%schtasks% /Query /TN "Microsoft\Windows\Windows Error Reporting\QueueReporting">nul 2>&1&&(set /a TasksCount+=1&(%schtasks% /Query /TN "Microsoft\Windows\Windows Error Reporting\QueueReporting"|%find% "Disabled">nul 2>&1&&set /a TasksDisabled+=1)&(%schtasks% /Query /TN "Microsoft\Windows\Windows Error Reporting\QueueReporting"|%find% "Отключено">nul 2>&1&&set /a TasksDisabled+=1))
set /a Task%el%d=%TasksCount%-%TasksDisabled%
if "%TaskEnabled%"=="0" (echo %sht%[[1;32m%TaskEnabled%[0m^|%TasksCount%]) else (echo %sht%[[31m%TaskEnabled%[0m^|%TasksCount%])
call :EventsCount
if "%eventenabled%"=="0"  (echo %evts%[[1;32m%eventenabled%[0m^|%eventscount%]) else (echo %evts%[[31m%eventenabled%[0m^|%eventscount%])
set ContextCount=0
%rq% "HKLM\%scl%\CLSID\{09A47860-11B0-4DA5-AFA5-26D86198A780}">nul 2>&1&&(%rq% "HKLM\%smw%\%cv%\Shell Extensions\Blocked" /v "{09A47860-11B0-4DA5-AFA5-26D86198A780}">nul 2>&1||set ContextCount=1)
if [%ContextCount%] neq [0] (echo %conm%%ON%) else (echo %conm%%OFF%) 
if exist "%windir%\System32\%ss%.exe" (set SsExist=1) else (set "SsExist=")
call :isProcess "%ss%.exe"&&set SsRun=1||set SsRun=
%rq% "HKLM\%scl%\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}\LocalServer32">nul 2>&1&&set SsOn=1||set SsOn=
%ifdef% SsExist (%ifdef% SsRun (%ifdef% SsOn (echo %ssn%%ON%) else (echo %ssn%%OFFRUN%)) else (echo %ssn%%OFF%)) else (echo %ssn%%DEL%)
set /a SSCount=0
%ifNdef% DefSmart (%rq% "HKLM\%spm%\Windows\System" /v "%el%%ss%" 2>nul|%find% "0x0">nul 2>&1||(%rq% "HKLM\%smw%\%cv%\Explorer" /v "%ss%%el%d" 2>nul|%find% "Off">nul 2>&1||set /a SSCount+=1)) else set /a SSCount+=1
(%rq% "HKLM\%spm%\Edge" /v "%ss%%el%d" 2>nul|%find% "0x0">nul 2>&1)||((%rq% "HKCU\%spm%\Edge" /v "%ss%%el%d" 2>nul|%find% "0x0">nul 2>&1)||(%rq% "HKCU\Software\Microsoft\Edge\%ss%%el%d" 2>nul|%find% "0x0">nul 2>&1||set /a SSCount+=1))
%ifdef% DefSmart set /a SSCount+=1&goto :SkipWTDS
%rq% "HKLM\%smw%\%cv%\WTDS">nul 2>&1||goto :SkipWTDS
%msg% "[1;32mSystem analysis...[0m" "[1;32mАнализ системы...[0m"
del /f /q "%temp%\%AS%WTDS.txt">nul 2>&1
(%rq% "HKLM\%smw%\%cv%\WTDS">nul 2>&1)||goto :SkipWTDS
start /min /wait "" "%cmd%" /c ""%Script%^" ti ^"%sys%:\windows\regedit.exe^" /e ^"%temp%\%AS%WTDS.txt^" ^"HKEY_LOCAL_MACHINE\%smw%\%cv%\WTDS^""
set /a CheckFileCount=0
:CheckFileLoop
if exist "%temp%\%AS%WTDS.txt" goto :FileFound
set /a CheckFileCount+=1
if %CheckFileCount% geq 10000 goto :EndCheckFile
goto :CheckFileLoop
:FileFound
(type "%temp%\%AS%WTDS.txt"|%find% """Service%el%d""=dword:00000000">nul 2>&1)||(%rq% "HKLM\%spm%\Windows\WTDS\Components" /v "Service%el%d" 2>nul|%find% "0x0">nul 2>&1||set /a SSCount+=1)
:EndCheckFile
del /f /q "%temp%\%AS%WTDS.txt">nul 2>&1
:SkipWTDS
(%rq% "HKLM\%spmwd%" /v "PUAProtection" 2>nul|%find% "0x0">nul 2>&1)||(%rq% "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\%wd%" /v "PUAProtection" 2>nul|%find% "0x0">nul 2>&1||set /a SSCount+=1)
(%rq% "HKCU\%smw%\%cv%\AppHost" /v "%el%WebContentEvaluation" 2>nul|%find% "0x0">nul 2>&1)||set /a SSCount+=1
if [%SSCount%] gtr [0] (echo %ssp%[[31m%SSCount%[0m^|5]) else (echo %ssp%[[1;32m0[0m^|5])  
%msg% "[1;32mSystem analysis...[0m" "[1;32mАнализ системы...[0m"
chcp 437 >nul 2>&1
%powershell% -MTA -NoP -NoL -NonI -EP Bypass -c "Get-AppXPackage -AllUsers|Format-Table"|%find% "ChxApp" >nul 2>&1&&set ssUWP=1||set ssUWP=
chcp 65001 >nul 2>&1
%ifNdef% ssUWP goto :SkipUWPinRegistrySS
set "UWP=ChxApp"
set "UwpName="
%rq% "%uwpsearch%" /f "*%UWP%*" /k>nul 2>&1&&for /f "tokens=2" %%a in ('%rq% "%uwpsearch%" /f "*%UWP%*" /k^|^|goto :EndSearchUWP') do (set "UwpName=%%~nxa"&goto EndSearchUWPSS)
:EndSearchUWPSS
%ifNdef% UwpName goto :SkipUWPinRegistrySS
%rq% "HKLM\%smw%\%cv%\Appx\AppxAllUserStore\Deprovisioned\%UwpName%">nul 2>&1&&set "ssUWP="
%rq% "HKLM\%smw%\%cv%\Appx\AppxAllUserStore\EndOfLife\S-1-5-18\%UwpName%">nul 2>&1&&set "ssUWP="
for /f "tokens=*" %%a in ('%rq% "HKLM\%smw%\%cv%\Appx\AppxAllUserStore" ^| %findstr% /R /C:"S-1-5-21-*"') do (
	%rq% "HKLM\%smw%\%cv%\Appx\AppxAllUserStore\EndOfLife\%%~nxa\%UwpName%">nul 2>&1&&set "ssUWP="
	%rq% "HKLM\%smw%\%cv%\Appx\AppxAllUserStore\Deleted\EndOfLife\%%~nxa\%UwpName%">nul 2>&1&&set "ssUWP="
)
:SkipUWPinRegistrySS
%ifdef% ssUWP (echo  %uwpsec% %ON%) else (echo  %uwpsec%%OFF%)
(%rq% "HKCU\%smw%\%cv%\Policies\Attachments" /v "SaveZoneInformation" 2>nul|%find% "0x1">nul 2>&1)&&set "SaveZone="||set SaveZone=1
%ifdef% SaveZone (echo  %ssd% %ON%) else (echo  %ssd%%OFF%)   
%sc% query SecurityHealthService|%find% "RUNNING">nul 2>&1&&set "wsecon=1"||set "wsecon="
%ifdef% wsecon (echo %wsec%%ON%) else (echo %wsec%%OFF%)
call :process_services "SecurityHealthService wscsvc SgrmAgent SgrmBroker"
set /p "colored_wsec_list=" < "%temp%\%AS%service_list.tmp"
del /f /q "%temp%\%AS%service_list.tmp">nul 2>&1
set "summary_wsec=[%serv_count_running%^|%serv_count_enabled%^|%serv_count_disabled%^|%serv_count_total%]"
echo %serv%%summary_wsec%
%ifdef% colored_wsec_list echo  %colored_wsec_list%
%msg% "[1;32mSystem analysis...[0m" "[1;32mАнализ системы...[0m"
chcp 437 >nul 2>&1
%powershell% -MTA -NoP -NoL -NonI -EP Bypass -c "Get-AppXPackage -AllUsers|Format-Table"|%find% "SecHealth" >nul 2>&1&&set wsecUWP=1||set wsecUWP=
chcp 65001 >nul 2>&1
%ifNdef% wsecUWP goto :SkipUWPinRegistry
set "UWP=sechealth"
set "UwpName="
%rq% "%uwpsearch%" /f "*%UWP%*" /k>nul 2>&1&&for /f "tokens=2" %%a in ('%rq% "%uwpsearch%" /f "*%UWP%*" /k^|^|goto :EndSearchUWP') do (set "UwpName=%%~nxa"&goto EndSearchUWP)
:EndSearchUWP
%ifNdef% UwpName goto :SkipUWPinRegistry
%rq% "HKLM\%smw%\%cv%\Appx\AppxAllUserStore\Deprovisioned\%UwpName%">nul 2>&1&&set "wsecUWP="
%rq% "HKLM\%smw%\%cv%\Appx\AppxAllUserStore\EndOfLife\S-1-5-18\%UwpName%">nul 2>&1&&set "wsecUWP="
for /f "tokens=*" %%a in ('%rq% "HKLM\%smw%\%cv%\Appx\AppxAllUserStore" ^| %findstr% /R /C:"S-1-5-21-*"') do (
	%rq% "HKLM\%smw%\%cv%\Appx\AppxAllUserStore\EndOfLife\%%~nxa\%UwpName%">nul 2>&1&&set "wsecUWP="
	%rq% "HKLM\%smw%\%cv%\Appx\AppxAllUserStore\Deleted\EndOfLife\%%~nxa\%UwpName%">nul 2>&1&&set "wsecUWP="
)
:SkipUWPinRegistry
%ifdef% wsecUWP (echo  %uwpsec%%ON%) else (echo  %uwpsec%%OFF%)
(%rq% "HKLM\%spmwd%\UX Configuration" /v "UILockdown" 2>nul|%find% "0x1">nul 2>&1)&&set "wsecui="||set "wsecui=1"
(%rq% "HKLM\%smw%\%cv%\Policies\Explorer" /v "SettingsPageVisibility" 2>nul|%find% "windows%df%er">nul 2>&1)&&set "wsecui="
%rq% "HKLM\%smw%\%cv%\Run" /v "SecurityHealth" /f>nul 2>&1&&set "wsectray=1"||set "wsectray="
call :isProcess "SecurityHealthSystray.exe"&&set "wsectray=1"
(%rq% "HKLM\%spmwd% Security Center\Systray" /v "HideSystray" 2>nul|%find% "0x1">nul 2>&1)&&set "wsectray="
(%rq% "HKCU\%smw%\%cv%\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance" /v "%el%d" 2>nul|%find% "0x0">nul 2>&1)&&set "wsecui="||set "wsecnoti=1"
(%rq% "HKLM\%spmwd% Security Center\Notifications" /v "%dl%Notifications" 2>nul|%find% "0x1">nul 2>&1)&&set "wsecnoti="
%ifdef% wsecui (echo  %hid%%ON%) else (echo  %hid%%OFF%)
%ifdef% wsectray (echo  %tray%%ON%) else (echo  %tray%%OFF%)
%ifdef% wsecnoti (echo  %noti%%ON%) else (echo  %noti%%OFF%)
call :process_services "applockerfltr AppIDSvc applockerfltr"
del /f /q "%temp%\%AS%service_list.tmp">nul 2>&1
set "summary_aplk=[[31m%serv_count_running%[0m^|[33m%serv_count_enabled%[0m^|[1;32m%serv_count_disabled%[0m^|%serv_count_total%]"
echo %aplk%%summary_aplk%
call :CIPoliciesCount
echo %cippol%cip:[%cip%] [1;30mp7b:[%psb%][0m
%ifdef% SAFEBOOT_OPTION del /f /q "%sys%:\%AS%.log">nul 2>&1
cls
%msg% " [1;36m%WindowsVersion% %WindowsBuild%[0m [34m[script %asv%][0m [4;1;30many key to return[0m" " [1;36m%WindowsVersion% %WindowsBuild%[0m [34m[script %asv%][0m [4;1;30mлюбая клавиша назад[0m"
%ifdef% ActiveAV (echo %av%[36m%ActiveAV%[0m) else (%ifdef% FiltersAV (echo %avfilt%%FiltersAV%) else (echo %noav%))
echo %secmsg%
%ifdef% DefExist  (%ifdef% DefRun (%ifdef% DefOn (echo %defend%%ON%) else (echo %defend%%OFFRUN%)) else (echo %defend%%OFF%)) else (echo %defend%%DEL%)
%ifdef% DefOn (%ifdef% DefReal   (echo %realtime%%ON%) else (echo %realtime%%OFF%)) else (%ifdef% DefReal   (echo [1;30m%realtime%ON[0m) else (echo [1;30m%realtime%OFF[0m))
%ifdef% DefOn (%ifdef% DefTamper (echo %tamper%%ON%) else (echo %tamper%%OFF%)) else (%ifdef% DefTamper (echo [1;30m%tamper%ON[0m) else (echo [1;30m%tamper%OFF[0m))
%ifdef% DefSmart  (echo %smart%%ON%) else (echo %smart%%OFF%)
%ifdef% DefVBS (%ifdef% DefVBSLock (%ifNdef% hyperv (echo %vbs%%ONLOCK%) else (echo %vbs%[36mON[0m%hyperv%)) else (echo %vbs%%ON%)) else (echo %vbs%%OFF%)
%ifdef% DefLsaLock    (echo %lsa%%ONLOCK%) else (%ifdef% DefLsa (echo %lsa%%ON%) else (echo %lsa%%OFF%))
%ifdef% DefCred (%rq% "HKLM\%sccd%\Scenarios\HypervisorEnforcedCodeIntegrity" /v "Locked" 2>nul|%find% "0x1">nul 2>&1)&&set DefCredLock=1||set DefCredLock=
%ifdef% DefCredLock    (echo %cred%%ONLOCK%) else (%ifdef% DefCred (echo %cred%%ON%) else (echo %cred%%OFF%))
%ifdef% DefReal   (if %ASRCount% gtr 0 (echo %asrr%[[31m%ASRCount%[0m]) else (echo %asrr%[[1;32m0[0m])) else (echo [1;30m%asrr%[%ASRCount%][0m) 
if "%eventenabled%"=="0"  (echo %evts%[[1;32m%eventenabled%[0m^|%eventscount%]) else (echo %evts%[[31m%eventenabled%[0m^|%eventscount%])
%ifdef% DefExist (if "%TaskEnabled%"=="0" (echo %sht%[[1;32m%TaskEnabled%[0m^|%TasksCount%]) else (echo %sht%[[31m%TaskEnabled%[0m^|%TasksCount%])) else (echo [1;30m%sht%[%TaskEnabled%^|%TasksCount%][0m)
if [%ContextCount%] neq [0] (echo %conm%%ON%) else (echo %conm%%OFF%) 
echo %serv%%summary_services%
%ifdef% colored_services_list echo  %colored_services_list%
echo %drv%%summary_drivers%
%ifdef% colored_drivers_list echo  %colored_drivers_list%
%ifdef% SsExist (%ifdef% SsRun (%ifdef% SsOn (echo %ssn%%ON%) else (echo %ssn%%OFFRUN%)) else (echo %ssn%%OFF%)) else (echo %ssn%%DEL%)
%ifNdef% SsExist set "SsOn="
%ifdef% SsOn (if [%SSCount%] gtr [0] (echo %ssp%[[31m%SSCount%[0m^|5]) else (echo %ssp%[[1;32m0[0m^|5])) else (echo [1;30m%ssp%[%SSCount%^|5][0m)
%ifdef% ssUWP %ifdef% SaveZone echo [%uwpsec%%ON% ][%ssd%%ON% ]
%ifdef% ssUWP %ifNdef% SaveZone echo [%uwpsec%%ON% ][%ssd%%OFF%]
%ifNdef% ssUWP %ifdef% SaveZone echo [%uwpsec%%OFF%][%ssd%%ON% ]
%ifNdef% ssUWP %ifNdef% SaveZone echo [%uwpsec%%OFF%][%ssd%%OFF%]
%ifdef% wsecon (echo %wsec%%ON%) else (echo %wsec%%OFF%)
echo %serv%%summary_wsec%
%ifdef% colored_wsec_list echo  %colored_wsec_list%
%ifdef% wsecUWP %ifdef% wsecui echo [%uwpsec%%ON% ][%hid%%ON% ]
%ifdef% wsecUWP %ifNdef% wsecui echo [%uwpsec%%ON% ][%hid%%OFF%]
%ifNdef% wsecUWP %ifdef% wsecui echo [%uwpsec%%OFF%][%hid%%ON% ]
%ifNdef% wsecUWP %ifNdef% wsecui echo [%uwpsec%%OFF%][%hid%%OFF%]
set traynoti=
%ifdef% wsecon (%ifdef% wsecnoti (set "traynoti=[%noti%%ON% ]") else (set "traynoti=[%noti%%OFF%]")) else (%ifdef% wsecnoti (set "traynoti=[[1;30m%noti%ON[0m ]") else (set "traynoti=[[1;30m%noti%OFF[0m]"))  
%ifdef% wsecon (%ifdef% wsectray (set "traynoti=%traynoti%[%tray%%ON% ]") else (set "traynoti=%traynoti%[%tray%%OFF%]")) else (%ifdef% wsectray (set "traynoti=%traynoti%[[1;30m%tray%ON[0m ]") else (set "traynoti=%traynoti%[[1;30m%tray%OFF[0m]"))
echo %traynoti%
echo %aplk%%summary_aplk%
%msg% "%cippol%cip:[%cip%] [1;30mp7b:[%psb%][0m" "%cippol%cip:[%cip%] [1;30mp7b:[%psb%][0m"
pause>nul 2>&1
goto :BEGIN
exit

:isProcess
%tasklist% /NH /FI "IMAGENAME eq %~1" 2>nul | %find% /I "%~1">nul 2>&1
exit /b %errorlevel%

:process_services
set "service_list=%~1"
set /a serv_count_running=0
set /a serv_count_enabled=0
set /a serv_count_disabled=0
set /a serv_count_total=0
> "%temp%\%AS%service_list.tmp" (
    for %%s in (%service_list%) do (
        call :process_service "%%s"
    )
)
if %serv_count_running%==0 if %serv_count_enabled%==0 if %serv_count_disabled%==0 set serv_count_running=[1;35m%serv_count_running%[0m&set serv_count_enabled=[1;35m%serv_count_enabled%[0m&set serv_count_disabled=[1;35m%serv_count_disabled%[0m&exit /b
if not %serv_count_running%==0 (set serv_count_running=[31m%serv_count_running%[0m) else (set serv_count_running=[1;30m%serv_count_running%[0m)
if not %serv_count_enabled%==0 (set serv_count_enabled=[33m%serv_count_enabled%[0m) else (set serv_count_enabled=[1;30m%serv_count_enabled%[0m)
if not %serv_count_disabled%==0 (set serv_count_disabled=[1;32m%serv_count_disabled%[0m) else (set serv_count_disabled=[1;30m%serv_count_disabled%[0m)
exit /b 

:process_service
set "service_name=%~1"
%sc% query "%service_name%" >nul 2>nul
if errorlevel 1 exit /b
set /a serv_count_total=serv_count_total+1
for /f "tokens=2 delims=:" %%i in ('%sc% query "%service_name%" ^| find "STATE"') do (
    for %%j in (%%i) do set "svc_state=%%j"
)
for /f "tokens=2 delims=:" %%i in ('%sc% qc "%service_name%" ^| find "START_TYPE"') do (
    for %%j in (%%i) do set "svc_start_type=%%j"
)
if "%svc_state%"=="RUNNING" (
    <nul set /p "=[31m%service_name%[0m "
    set /a serv_count_running=serv_count_running+1
    exit /b
)
if "%svc_start_type%"=="DISABLED" (
    <nul set /p "=[1;32m%service_name%[0m "
    set /a serv_count_disabled=serv_count_disabled+1
) else (
    <nul set /p "=[33m%service_name%[0m "
    set /a serv_count_enabled=serv_count_enabled+1
)
exit /b

:CIPoliciesCount
set /a cip=0
set /a psb=0
set "efi="
for %%a in (Z Y X W V U T S R Q P O N M L K J I H G F E D) do if not exist %%a:\nul set "efi=%%a:"&goto :FoundFreeDisk
:FoundFreeDisk
%ifdef% efi (
	%mountvol% %efi% /s >nul 2>&1
	dir "%efi%\EFI\Microsoft\Boot\CIPolicies\Active\*.cip" /b 2>nul | %find% /c /v "" >nul && (for /f %%a in ('dir "%efi%\EFI\Microsoft\Boot\CIPolicies\Active\*.cip" /b 2^>nul ^| %find% /c /v ""') do set /a cip+=%%a)
	dir "%efi%\EFI\Microsoft\Boot\*.p7b" /b 2>nul | %find% /c /v "" >nul && (for /f %%a in ('dir "%efi%\EFI\Microsoft\Boot\*.p7b" /b 2^>nul ^| %find% /c /v ""') do set /a psb+=%%a)
	%mountvol% %efi% /d >nul 2>&1
)
dir "%sysdir%CodeIntegrity\CIPolicies\Active\*.cip" /b 2>nul | %find% /c /v "" >nul && (for /f %%a in ('dir "%sysdir%CodeIntegrity\CIPolicies\Active\*.cip" /b 2^>nul ^| %find% /c /v ""') do set /a cip+=%%a)
dir "%sysdir%CodeIntegrity\*.p7b" /b 2>nul | %find% /c /v "" >nul && (for /f %%a in ('dir "%sysdir%CodeIntegrity\*.p7b" /b 2^>nul ^| %find% /c /v ""') do set /a psb+=%%a)
if "%cip%"=="0" (set "cip=[1;32m%cip%[0m") else (set "cip=[36m%cip%[0m")
exit /b

:UnlockUEFI
cls
if not exist "%sysdir%SecConfig.efi" (
	echo.
	%msg% " File not found - unlocking is not possible!" " Файл не найден - разблокировка невозможна!"
	echo.
	echo  %sysdir%SecConfig.efi
	echo.
	%msg% "[4;1;30mPress any key to return...                                                        [0m" "[4;1;30mНажмите любую клавишу для возврата...                                             [0m"
	pause>nul 2>&1
	goto :Menu6
	exit
)
set Item=
echo.
%msg% " The computer will be rebooted now" " Сейчас компьютер будет перезагружен"
%msg% " and you will be prompted to unlock manually" " и будет предложено отключить блокировку вручную"
%msg% " to do this, you will need to press F3." " для этого нужно будет нажать F3."
echo.
%msg% " [[33m1[0m] - [33mYes[0m [[33m0[0m] - [33mNo[0m" " [[33m1[0m] - [33mДа[0m [[33m0[0m] - [33mНет[0m"
echo.
%ifNdef% Lang (choice /C 01 /N /M "Reboot now?") else (choice /C 01 /N /M "Перезагрузиться сейчас?")
set "Item=%errorlevel%"
set loadoption=
if [%Item%]==[1] goto :Menu6
if "%~1"=="LSA" set "loadoption=DISABLE-LSA-PPL"
if "%~1"=="VBS" set "loadoption=DISABLE-VBS"
if "%~1"=="CG" set "loadoption=DISABLE-LSA-ISO"
if "%~1"=="ALL" set "loadoption=DISABLE-LSA-PPL,DISABLE-VBS,DISABLE-LSA-ISO"
if "%~1"=="ALLHV" set "loadoption=DISABLE-LSA-PPL,DISABLE-VBS,DISABLE-LSA-ISO"
if "%~1"=="ALLHV" %bcdedit% /set hypervisorlaunchtype off >nul 2>&1
%rd% "HKLM\%sccd%" /v "HypervisorEnforcedCodeIntegrity" /f>nul 2>&1
%rd% "HKLM\%sccd%" /v "EnableVirtualizationBasedSecurity" /f>nul 2>&1
%rd% "HKLM\%sccd%" /v "RequirePlatformSecurityFeatures" /f>nul 2>&1
%rd% "HKLM\%sccd%" /v "Locked" /f>nul 2>&1
%rd% "HKLM\%sccd%\Scenarios\HypervisorEnforcedCodeIntegrity" /f>nul 2>&1
%rd% "HKLM\%sccd%\Capabilities" /f>nul 2>&1
%rd% "HKLM\%scc%\Lsa" /v "LsaCfgFlags" /f>nul 2>&1
%rd% "HKLM\%scc%\Lsa" /v "RunAsPPL" /f>nul 2>&1
%rd% "HKLM\%scc%\Lsa" /v "RunAsPPLBoot" /f>nul 2>&1
%rd% "HKLM\%spm%\Windows\DeviceGuard" /v "LsaCfgFlags" /f>nul 2>&1
%rd% "HKLM\%smwci%\LSASS.exe" /v "AuditLevel" /f>nul 2>&1
set "efi="
for %%a in (Z Y X W V U T S R Q P O N M L K J I H G F E D) do if not exist %%a:\nul set "efi=%%a:"&goto :FoundFreeDiskUnlock
:FoundFreeDiskUnlock
%ifdef% efi (
	%mountvol% %efi% /s >nul 2>&1
	copy /y "%sysdir%SecConfig.efi" "%efi%\EFI\Microsoft\Boot\SecConfig.efi">nul 2>&1
    %bcdedit% /create "{0cb3b571-2f2e-4343-a879-d86a476d7215}" /d DGOptOut /application osloader>nul 2>&1
    %bcdedit% /set "{0cb3b571-2f2e-4343-a879-d86a476d7215}" path \EFI\Microsoft\Boot\SecConfig.efi>nul 2>&1
    %bcdedit% /set "{bootmgr}" bootsequence "{0cb3b571-2f2e-4343-a879-d86a476d7215}">nul 2>&1
    %bcdedit% /set "{0cb3b571-2f2e-4343-a879-d86a476d7215}" loadoptions %loadoption%>nul 2>&1
    %bcdedit% /set "{0cb3b571-2f2e-4343-a879-d86a476d7215}" device partition=%efi%>nul 2>&1
	if not "%loadoption%"=="DISABLE-LSA-PPL" %bcdedit% /set vsmlaunchtype off>nul 2>&1
	%mountvol% %efi% /d >nul 2>&1
)
cls
call :Reboot2Normal
exit /b

:CleanCaches
%msg% "Clean caches and logs..." "Очистка кэшей и логов..."
del /f /q /s "%sys%:\ProgramData\Microsoft\%wd%\Definition Updates\Backup\*.*">nul 2>&1
del /f /q /s "%sys%:\ProgramData\Microsoft\Windows Security Health\Logs\*.*">nul 2>&1
del /f /q /s "%sys%:\ProgramData\Microsoft\%wd%\Scans\*.bin">nul 2>&1
del /f /q /s "%sys%:\ProgramData\Microsoft\%wd%\Scans\*.bin64">nul 2>&1
del /f /q /s "%sys%:\ProgramData\Microsoft\%wd%\Scans\*.log">nul 2>&1
del /f /q "%sys%:\ProgramData\Microsoft\%wd%\Scans\mpcache*.*">nul 2>&1
del /f /q "%sys%:\ProgramData\Microsoft\%wd%\Scans\*.db*">nul 2>&1
del /f /q /s "%sys%:\ProgramData\Microsoft\%wd%\Scans\History\*.*">nul 2>&1
del /f /q /s "%sys%:\ProgramData\Microsoft\%wd%\Support\*.*">nul 2>&1
del /f /q "%temp%\MpCmdRun.log">nul 2>&1
del /f /q "%LOCALAPPDATA%\Temp\MpCmdRun.log">nul 2>&1
del /f /q "%sys%:\Windows\Temp\MpCmdRun.log">nul 2>&1
del /f /q "%sys%:\Windows\Temp\MpSigStub.log">nul 2>&1
exit /b

:ResetPlatform
set NewPlatform=
if exist "%ProgramData%\Microsoft\%wd%\Platform" for /d %%D in ("%ProgramData%\Microsoft\%wd%\Platform\*") do (if exist "%%D\MpCmdRun.exe" set NewPlatform=%%D)
if [%build%] geq [22000] %ifNdef% NotResetPlatform %ifdef% NewPlatform (
	%ifNdef% DefTamper (%msg% "Reseting %df%er Platform..." "Сброс платформы Защитника...") else (%msg% "Reseting %df%er Platform [maybe slowly]..." "Сброс платформы Защитника [может быть медленно]...")
	if exist "%sys%:\Program Files\%wd%\MpCmdRun.exe" ("%sys%:\Program Files\%wd%\MpCmdRun.exe" -ResetPlatform>nul 2>&1)
)	
exit /b

:StopInstances
%msg% "Terminating processes and stopping services..." "Завершение процессов и остановка служб..."
%ifdef% NotDisableSecHealth (
	set "procs='MsMpEng.exe','MsMpEngCP.exe','NisSrv.exe','smartscreen.exe','MsSense.exe','MpCmdRun.exe','Mp%df%erCoreService.exe'"
	) else (
	set "procs='SecurityHealthService.exe','SecurityHealthHost.exe','SecHealthUI.exe','SecurityHealthSystray.exe','MsMpEng.exe','MsMpEngCP.exe','NisSrv.exe','smartscreen.exe','MsSense.exe','MpCmdRun.exe','Mp%df%erCoreService.exe'"
)
%ifdef% NotDisableSecHealth (
	set "servs='Win%df%','MDCoreSvc','MsSecCore','WdNisSvc','Sense','SgrmBroker','webthreatdefsvc','webthreatdefusersvc','WdNisDrv','WdBoot','WdDevFlt','WdFilter','SgrmAgent','MsSecWfp','MsSecFlt','wtd','KslD','AppID','AppIDSvc','applockerfltr','wscsvc'"
	) else (
	set "servs='SecurityHealthService','Win%df%','MDCoreSvc','MsSecCore','WdNisSvc','Sense','SgrmBroker','webthreatdefsvc','webthreatdefusersvc','WdNisDrv','WdBoot','WdDevFlt','WdFilter','SgrmAgent','MsSecWfp','MsSecFlt','wtd','KslD','AppID','AppIDSvc','applockerfltr','wscsvc'"
)
chcp 437 >nul 2>&1
%powershell% -MTA -NoP -NoL -NonI -EP Bypass -c "$p = @(%procs%); $s = @(%servs%); $fP = \"Name='\" + ($p -join \"' OR Name='\") + \"'\"; $fS = \"Name='\" + ($s -join \"' OR Name='\") + \"'\"; for ($i=0; $i -lt 2; $i++) { foreach ($proc in gwmi Win32_Process -Filter $fP) { $proc.Terminate() }; foreach ($srv in gwmi Win32_Service -Filter $fS) { $srv.StopService() } }">nul 2>&1
chcp 65001 >nul 2>&1
exit /b

:StopTelemetry
%msg% "Stopping telemetry services..." "Остановка служб телеметрии..."
for %%s in (DiagTrack diagnosticshub.standardcollector.service InventorySvc ADPSvc whesvc wuqisvc) do %sc% stop %%~s>nul 2>&1
exit /b

:SetMpPreference
%msg% "Stopping protections..." "Остановка защит..."
chcp 437 >nul 2>&1
%powershell% -MTA -NoP -NoL -NonI -EP Bypass -c "Set-MpPreference -DisableRealtimeMonitoring $true">nul 2>&1
chcp 65001 >nul 2>&1
exit /b

:CheckAV
set "FiltersAV="&for /f "skip=2 tokens=1,2,3" %%a in ('%fltmc%') do if "%%b" neq "0" for /f "delims=. tokens=1" %%x in ("%%c") do if %%x GEQ 320000 if %%x LEQ 329999 echo %%a| %findstr% /I /B /V "wd" >nul && (%ifdef% FiltersAV (call set "FiltersAV=%%FiltersAV%% %%a") else (set "FiltersAV=%%a"))
%ifdef% FiltersAV (exit /b 1) else (exit /b 0)
::                              --------+*                                  
::                       --------+##*=--+##*=+++**+**                       
::               ---------++=---+@@@@%=+@@@@#=+%%%*++++******               
::         -------------=#@@@%==%@@@@@=#@@@@#+@@@@@*+++++++++++****         
::      ---------+##*=--*@@@@@*-*@@@@*-=#@@#=*@@@@@*+++++++++++++++***      
::     --------+@@@@@@%=*@@@@@*--=+++*#%%%%#+=%@@#=+++++++++++++++++*+*     
::     -------=%@@@@@@@%*@@@@@=-+%@@@@@@@@@@@@%+---++++++++++++++++++**     
::    --------+@@@@@@@@@#=*#++%@@@@@@@@@@@@@@@@@#--=++++++++++++++++++**    
::    --------+%@@@@@@@@#--*@@@@@@@@@@@@@@@@@@@@@%=+++++++++++++++++++**    
::    ---------*@@@@@@@@*+%@@@@@@@@@@@@@@@@@@@@@@@%++++++++++++++++++**#    
::    ----------#@@@@@@#*@@@@@@@@@@@@@@@@@@@@@@@@@@*+++++++++++++++++**#    
::    ------------+##=-*@@@@@@@@@@@@%:. .#@@@@@@@@@#+++++++++++++++++**%    
::    ----------------=@@@@@@@@@@@@@+.  .+@@@@@@@@@%+++++++++++++++++*#%    
::    ----------------*@@@@@@@@@@@@@+.  .+@@@@@@@@@%++++++++++++++++**%%    
::    ----------------#@@@@@@#-=%@@@+.  .+@@@%=-#@@%++++++++++++++++*#%%    
::    ----------------+@@@@#:.  :#@@+.  .+@@#:   .#%+++++++++++++++**%%%    
::    ----------------=%@@+.  ..=@@@+.  .+@@@=..  .-+++++++++++++++*%%%%    
::    -----------------+%*.   .#@@@@+.  .+@@@@#.   .-+++++++++++++*#%%%%    
::    ------------------=-.   #@@@@@@+--+@@@@@@#   .:++++++++++++*#%%%%%    
::    -------------------.   :@@@@@@@@@@@@@@@@@@:   .=+++++++++*#%%%%%%%    
::     -----------------:.   :@@@@@@@@@@@@@@@@@@:   .=+++++++**#%%%%%%%%    
::     ------------------.   .%@@@@@@@@@@@@@@@@@.   :=+++++**#%%%%%%%%%     
::     ------------------:.   -@@@@@@@@@@@@@@@@-   .-+++++*#%%%%%%%%%%%     
::     ----------------=++:.  .:#@@@@@@@@@@@@#-.  .:++++*#%%%%%%%%%%%%%     
::      --------------+++++:.   .:*%@@@@@@@*-.   .:++**#%%%%%%%%%%%%%%      
::       -----------++++++++=.     ..::::..     .#%**#%%%%%%%%%%%%%%%       
::       ----------+++++++++++=:.            .-#@@@#%%%%%%%%%%%%%%%%%       
::        --------+++++++++++++++**=:.....-*%@@@@@@%%%%%%%%%%%%%%%%%        
::          ------+++++++++++++++*@@@@@@@@@@@@@@@@@%%%%%%%%%%%%%%%%         
::           ----=+++++++++++++++#@@@@@@@@@@@@@@@@@%%%%%%%%%%%%%%%          
::            ---=++++++++++++++*%@@@@@@@@@@@@@@@@@%%%%%%%%%%%%%            
::             ---+++++++++++++*#@@@@@@@@@@@@@@@@@@%%%%%%%%%%%%             
::               --+++++++++++**@@@@@@@@@@@@@@@@@@@%%%%%%%%%%               
::                 -++++++++++*%@@@@@@@@@@@@@@@@@@@%%%%%%%%                 
::                   +**++++++*@@@@@@@@@@@@@@@@@@@%%%%%%%                   
::                     **+*+++*@@@@@@@@@@@@@@@@@@@%%%%%                     
::                      ***+**%@@@@@@@@@@@@@@@@@%%%%                        
::                          *+**%@@@@@@@@@@@@@@%%%                          
::                             **#@@@@@@@@@@@@%                             
::                                  @@@@@@                                  
