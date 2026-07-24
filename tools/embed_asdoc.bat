::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: Copyright (C) 2021-2026, 5DPLAY Game Studio
:: All rights reserved.
::
:: This program is free software: you can redistribute it and/or modify
:: it under the terms of the GNU General Public License as published by
:: the Free Software Foundation, either version 3 of the License, or
:: (at your option) any later version.
::
:: This program is distributed in the hope that it will be useful,
:: but WITHOUT ANY WARRANTY; without even the implied warranty of
:: MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
:: GNU General Public License for more details.
::
:: You should have received a copy of the GNU General Public License
:: along with this program.  If not, see <http://www.gnu.org/licenses/>.
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: Purpose
::   Post-build hook: embed ASDoc into LIB_KyoLib.swc (no HTML browse).
::   Called by monorepo build.bat / VSCode tasks / IDEA External Tool,
::   and by submodule VSCode compile task.
::
:: Usage
::   LIB_KyoLib\tools\embed_asdoc.bat
::   LIB_KyoLib\tools\embed_asdoc.bat "D:\...\LIB_KyoLib.swc"
::
:: SWC resolution (when SWC_PATH / arg unset)
::   1) <parent>\out\production\LIB_KyoLib\LIB_KyoLib.swc  (monorepo)
::   2) <module>\out\production\LIB_KyoLib\LIB_KyoLib.swc  (standalone)
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@echo off
setlocal enabledelayedexpansion

set "BAT_HOME=%~dp0"
set "MODE=embed"
set "NO_PAUSE=1"

set "MODULE_ROOT=%BAT_HOME%.."
for %%I in ("%MODULE_ROOT%") do set "MODULE_ROOT=%%~fI"
set "REPO_ROOT=%MODULE_ROOT%\.."
for %%I in ("%REPO_ROOT%") do set "REPO_ROOT=%%~fI"

set "ASDOC_PS=%REPO_ROOT%\tools\script\ps"
if not exist "%ASDOC_PS%\wait_swc_ready.ps1" set "ASDOC_PS=%MODULE_ROOT%\tools\asdoc"

set "SWC_MONO=%REPO_ROOT%\out\production\LIB_KyoLib\LIB_KyoLib.swc"
set "SWC_IND=%MODULE_ROOT%\out\production\LIB_KyoLib\LIB_KyoLib.swc"

if "%SWC_PATH%"=="" (
	if exist "%SWC_MONO%" (
		set "SWC_PATH=%SWC_MONO%"
	) else if exist "%SWC_IND%" (
		set "SWC_PATH=%SWC_IND%"
	) else (
		set "SWC_PATH=%SWC_MONO%"
	)
)

if not "%~1"=="" (
	set "SWC_PATH=%~f1"
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%ASDOC_PS%\wait_swc_ready.ps1" -SwcPath "!SWC_PATH!" -TimeoutSec 45
if errorlevel 1 (
	echo SWC not ready for ASDoc embed: !SWC_PATH!
	exit /b 1
)

call "%BAT_HOME%asdoc.bat"
exit /b %ERRORLEVEL%
