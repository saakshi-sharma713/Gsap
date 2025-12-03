@echo off
echo.
echo Running Script with Admin Privilege

:init
	setlocal DisableDelayedExpansion
	set cmdInvoke=1
	set winSysFolder=System32
	set "batchPath=%~0"
	for %%k in (%0) do set batchName=%%~nk
	set "vbsGetPrivileges=%temp%\OEgetPriv_%batchName%.vbs"
	setlocal EnableDelayedExpansion

:checkPrivileges
	NET FILE 1>NUL 2>NUL
	if '%errorlevel%' == '0' ( goto gotPrivileges ) else ( goto getPrivileges )

:getPrivileges
	if '%1'=='ELEV' (echo ELEV & shift /1 & goto gotPrivileges)
	echo.
	echo Set UAC = CreateObject^("Shell.Application"^) > "%vbsGetPrivileges%"
	echo args = "ELEV " >> "%vbsGetPrivileges%"
	echo For Each strArg in WScript.Arguments >> "%vbsGetPrivileges%"
	echo args = args ^& strArg ^& " "  >> "%vbsGetPrivileges%"
	echo Next >> "%vbsGetPrivileges%"

	if '%cmdInvoke%'=='1' goto InvokeCmd 

	echo UAC.ShellExecute "!batchPath!", args, "", "runas", 1 >> "%vbsGetPrivileges%"
	goto ExecElevation

:InvokeCmd
	echo args = "/c """ + "!batchPath!" + """ " + args >> "%vbsGetPrivileges%"
	echo UAC.ShellExecute "%SystemRoot%\%winSysFolder%\cmd.exe", args, "", "runas", 1 >> "%vbsGetPrivileges%"

:ExecElevation
	"%SystemRoot%\%winSysFolder%\WScript.exe" "%vbsGetPrivileges%" %*
	exit /B

:gotPrivileges
	setlocal & cd /d %~dp0
	if '%1'=='ELEV' (del "%vbsGetPrivileges%" 1>nul 2>nul  &  shift /1)

:LogCollection
echo Finding Log Files...
set baseName=SamsungDeXLog
set versionNo=2.4.1.27

REM preparing timestamp
for /f "tokens=2,3,1 delims=/- " %%x in ("%date%") do set dateStamp=%%x-%%y-%%z
for /f "tokens=1,2,3 delims=:. " %%x in ("%time%") do set timeStamp=%dateStamp%_%%x-%%y-%%z
set fileName=%baseName%_%timeStamp%.zip
set folderName=%baseName%_%timeStamp%
set appLogPath="%appdata%\Samsung\Samsung DeX"
set deviceErrorPath="%programdata%\Samsung\USB Driver Installer"
set desktopPath="%USERPROFILE%\Desktop"
set registryPath="HKEY_CURRENT_USER\Software\Samsung\Samsung DeX"

REM Checking if clear called
set isClear=false
if '%1'=='-c' set isClear=true
if '%1'=='-C' set isClear=true
if '%1'=='--Clear' set isClear=true
if '%1'=='--clear' set isClear=true
if '%1'=='--CLEAR' set isClear=true
if '%isClear%'=='true' (
	REM Removing all logs
	echo Removing Log Files...
	REM => Installer Logs
	del %temp%\Samsung_DeX_*.log  /f /q
	REM => App logs
	del %appLogPath%\*.log /f /q
	del %appLogPath%\SamsungDeXLicenseAgreement* /f /q
	del %appLogPath%\SamsungDeXWPFLog* /f /q
	REM => EasySetup logs
	del %programdata%\Samsung\EasySetup*.log /f /q
	REM => Crashdump logs
	del %temp%\SamsungDeXDumpFile\*.dmp /f /q

	echo Old Log Files Removed!!
	exit /B 0
)

REM Creating Temp Folder
mkdir %folderName%
cd %folderName%

REM => Generate required extra logs
%systemroot%\system32\dxdiag.exe /t %appLogPath%\DxDiag.log

REM Gathering all logs
REM => Installer Logs
xcopy %temp%\Samsung_DeX_*.log .\ /I /Y
xcopy %temp%\dd_vcredist_x86*.log .\ /I /Y
REM => App crash dumps => skipped for the time being
REM xcopy %temp%\SamsungDeXDumpFile*.dmp .\ /I /Y
REM xcopy %temp%\SamsungDeXDumpFile*.txt .\ /I /Y
REM => App crash dumps => Collecting new Dump Files
xcopy %temp%\SamsungDeXDumpFile\SamsungDeX*.dmp .\ /I /Y
REM => App logs
xcopy %appLogPath%\*.log .\ /I /Y
REM => Dump TS logs
xcopy %appLogPath%\*.ts .\ /I /Y
REM => License Agreement logs
xcopy %appLogPath%\SamsungDeXLicenseAgreement* .\ /I /Y
REM => WPF App logs
xcopy %appLogPath%\SamsungDeXWPFLog* .\ /I /Y
REM => EasySetup logs
xcopy %programdata%\Samsung\EasySetup\*.log .\ /I /Y
REM => Driver logs
xcopy %deviceErrorPath%\*.log .\ /I /Y
xcopy %windir%\inf\setupapi.dev.log .\ /I /Y
REM => Gathering Event logs
xcopy %windir%\System32\winevt\Logs\Application.evtx .\ /I /Y
xcopy %windir%\System32\winevt\Logs\System.evtx .\ /I /Y
xcopy %windir%\System32\winevt\Logs\Setup.evtx .\ /I /Y
xcopy %windir%\System32\winevt\Logs\HardwareEvents.evtx .\ /I /Y
REM => ss_conn_service2 logs
xcopy %programdata%\Samsung\MSSCS\*.log  .\ /I /Y

REM => WiFi Report
netsh wlan show wlanreport
xcopy %programdata%\Microsoft\Windows\WlanReport\wlan-report-latest.html .\ /I /Y

REM Gathering System Info
call :SavePCInfo

cd ..
set shouldDeleteFolder=true

REM Getting PowerShell version
for /f "delims=" %%a in ('powershell $PSVersionTable.PSVersion.Major') do Set psVersion=%%a

REM Only folders are provided if powershell version is 2 or below
if /I "%psVersion%" LEQ "2" (
	echo Current powershell version does not allow to zip files. Folder provided.
	xcopy %folderName% %desktopPath%\%folderName% /I /Y

	if "%CD%"==%desktopPath% set shouldDeleteFolder=false
)

REM Next steps are performed if Powershell version is 3 or above
if /I "%psVersion%" GEQ "3" (
	REM Zipping Log files...
	echo Zipping Log files...
	powershell.exe -nologo -noprofile -command "& { Add-Type -A 'System.IO.Compression.FileSystem'; [IO.Compression.ZipFile]::CreateFromDirectory('%folderName%', '%USERPROFILE%\Desktop\%fileName%'); }"
)

REM Removing temporary folder
if '%shouldDeleteFolder%'=='true' rmdir /Q /S %folderName%

echo Done!
exit /B 0


:SavePCInfo
	 REM set variables
	 set system=
	 set manufacturer=
	 set model=
	 set serialnumber=
	 set osname=
	 set osVersion=
	 set sp=
	 setlocal ENABLEDELAYEDEXPANSION
	 set "volume=C:"
	 set totalMem=
	 set availableMem=
	 set usedMem=
	 set cpuName=
	 set cpuDescription=
	 set cpuL2Cache=
	 set cpuL3Cache=
	 set cpuCores=
	 set cpuProcessors=
	 set cpuClock=
	 set notificationStatus=
	 set autorunStatus=
	 set langaugeValue=
	 set appVersion=
	 set wifiChannel=

	 echo Getting data for PC: %computername%...

	 REM Get Computer Name
	 for /F "tokens=2 delims='='" %%A in ('wmic OS Get csname /value') do set system=%%A

	 REM Get Computer Manufacturer
	 for /F "tokens=2 delims='='" %%A in ('wmic ComputerSystem Get Manufacturer /value') do set manufacturer=%%A

	 REM Get Computer Model
	 for /F "tokens=2 delims='='" %%A in ('wmic ComputerSystem Get Model /value') do set model=%%A

	 REM Get Computer Serial Number
	 for /F "tokens=2 delims='='" %%A in ('wmic Bios Get SerialNumber /value') do set serialnumber=%%A

	 REM Get Computer OS
	 for /F "tokens=2 delims='='" %%A in ('wmic os get Name /value') do set osname=%%A
	 for /F "tokens=1 delims='|'" %%A in ("%osname%") do set osname=%%A
	 for /F "tokens=2 delims='='" %%A in ('wmic os get Version /value') do set osVersion=%%A
	 
	 REM Get Computer OS SP
	 for /F "tokens=2 delims='='" %%A in ('wmic os get ServicePackMajorVersion /value') do set sp=%%A
	 
	 REM Get CPU info
	 for /F "tokens=2 delims='='" %%A in ('wmic CPU get Name /value') do set cpuName=%%A
	 for /F "tokens=2 delims='='" %%A in ('wmic CPU get Description /value') do set cpuDescription=%%A
	 for /F "tokens=2 delims='='" %%A in ('wmic CPU get L2CacheSize /value') do set cpuL2Cache=%%A
	 for /F "tokens=2 delims='='" %%A in ('wmic CPU get L3CacheSize /value') do set cpuL3Cache=%%A
	 for /F "tokens=2 delims='='" %%A in ('wmic CPU get NumberOfCores /value') do set cpuCores=%%A
	 for /F "tokens=2 delims='='" %%A in ('wmic CPU get NumberOfLogicalProcessors /value') do set cpuProcessors=%%A
	 for /F "tokens=2 delims='='" %%A in ('wmic CPU get CurrentClockSpeed /value') do set cpuClock=%%A
	 

	 REM Get Memory
	 for /F "tokens=4" %%a in ('systeminfo ^| findstr Physical') do if defined totalMem (set availableMem=%%a) else (set totalMem=%%a)
	 set totalMem=%totalMem:,=%
	 set availableMem=%availableMem:,=%
	 set /a usedMem=totalMem-availableMem

	 for /f "tokens=1*delims=:" %%i in ('fsutil volume diskfree %volume%') do (
		 set "diskfree=!disktotal!"
		 set "disktotal=!diskavail!"
		 set "diskavail=%%j"
	 )
	 for /f "tokens=1" %%i in ("%disktotal%") do set disktotal=%%i
	 for /f "tokens=1" %%i in ("%diskavail%") do set diskavail=%%i
	 
	 REM Get Registry Values
	 for /f "tokens=3" %%i in ('reg query %registryPath%  /V CheckReceiveNotice  ^|findstr /ri "REG_DWORD"') do set notificationStatus=%%i
	 for /f "tokens=3" %%i in ('reg query %registryPath%  /V AutoRun  ^|findstr /ri "REG_DWORD"') do set autorunStatus=%%i
	 for /f "tokens=3" %%i in ('reg query %registryPath%  /V Language  ^|findstr /ri "REG_SZ"') do set langaugeValue=%%i
	 for /f "tokens=3" %%i in ('reg query %registryPath%  /V Version  ^|findstr /ri "REG_SZ"') do set appVersion=%%i
	 for /f "delims=: tokens=2" %%i in ('netsh wlan show interface name="Wi-Fi" ^| findstr "Channel"') do set wifiChannel=%%i

	 REM Generate file
	 set file="ComputerInfo.txt"
	 echo ------------------------------------------------------ >> %file%
	 echo Log Collector Version: %versionNo% >> %file%
	 echo Notification Showing Settings Value: %notificationStatus% >> %file%
	 echo Auto Run Settings Value: %autorunStatus% >> %file%
	 echo User Language: %langaugeValue% >> %file%
	 echo Installed Samsung DeX app Version: %appVersion% >> %file%
	 echo Details For: %system% >> %file%
	 echo Manufacturer: %manufacturer% >> %file%
	 echo Model: %model% >> %file%
	 echo Operating System: %osname% >> %file%
	 echo Operating System Version: %osVersion% >> %file%
	 echo OS Service Pack: %sp% >> %file%
	 echo C:\ Total: %disktotal:~0,-9% GB >> %file%
	 echo C:\ Avail: %diskavail:~0,-9% GB >> %file%
	 echo Total Memory: %totalMem% MB >> %file%
	 echo Used  Memory: %usedMem% MB >> %file%
	 echo Computer Processor Architecture: %processor_architecture% >> %file%
	 echo Computer Processor Name: %cpuName% >> %file%
	 echo Computer Processor Description: %cpuDescription% >> %file%
	 echo Computer Processor Level 2 Chache: %cpuL2Cache% KB >> %file%
	 echo Computer Processor Level 3 Chache: %cpuL3Cache% KB >> %file%
	 echo Computer Processor Core Count: %cpuCores% >> %file%
	 echo Computer Processor Logical Unit Count: %cpuProcessors% >> %file%
	 echo Computer Processor Clock Speed: %cpuClock% MHz >> %file%
	 echo Connected WiFi Channel: %wifiChannel% >> %file%
	 echo ------------------------------------------------------ >> %file%
	 echo Here is the list of all registry keys and their curent value in use >> %file%
	 echo Registry Key                  = Registry Value >> %file%
	 echo ====================================================================== >> %file%
	 for /F "tokens=1,3" %%a in ('reg query %registryPath%') do (
	 	set key="%%a                                                         "
	 	if not "%%a"=="HKEY_CURRENT_USER\Software\Samsung\Samsung" echo !key:~1,29! = %%b >> %file%
	 )
	 echo ------------------------------------------------------ >> %file%
 exit /B 0
