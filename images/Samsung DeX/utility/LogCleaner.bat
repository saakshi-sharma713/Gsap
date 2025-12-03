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

REM preparing timestamp
for /f "tokens=2,3,1 delims=/- " %%x in ("%date%") do set dateStamp=%%x-%%y-%%z
for /f "tokens=1,2,3 delims=:. " %%x in ("%time%") do set timeStamp=%dateStamp%_%%x-%%y-%%z
set fileName=%baseName%_%timeStamp%.zip
set folderName=%baseName%_%timeStamp%
set appLogPath="%appdata%\Samsung\Samsung DeX"
set deviceErrorPath="%programdata%\Samsung\USB Driver Installer"
set desktopPath="%USERPROFILE%\Desktop"

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
