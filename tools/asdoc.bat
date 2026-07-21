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
::   Generate ASDoc HTML for LIB_KyoLib (Chinese UI chrome + source ASDoc body).
::
:: Usage
::   LIB_KyoLib\tools\asdoc.bat
::   set OPEN=1 && LIB_KyoLib\tools\asdoc.bat
::     OPEN=1 opens index.html in the default browser after success.
::
::   Optional monorepo forwarder:
::     tools\script\asdoc_kyolib.bat  ->  this script
::
:: Prerequisites
::   1. FLEX_HOME points at Flex/AIR SDK root (bin, lib\asdoc.jar, frameworks,
::      asdoc\templates).
::   2. A JRE/JDK that can run asdoc.jar. Do NOT use SDK asdoc.bat
::      (-Xbootclasspath/p breaks on Java 9+).
::   3. Optional: parent repo built LIB_Other.swc for cross-lib types.
::      Missing SWC only warns; docs may still generate with unresolved types.
::
:: Layout (relative to MODULE_ROOT = LIB_KyoLib)
::   src\                      Documented sources (-doc-sources)
::   lib\src\                  Third-party sources (filtered into -source-path)
::   tools\asdoc.bat           This entry
::   tools\asdoc\              Terms script, zh terms, local template cache
::     build_terms_zh.ps1      Build Chinese ASDoc_terms.xml from SDK English
::     zh_CN\ASDoc_terms.xml   Generated terms (refreshed each run)
::     templates\              SDK template copy (gitignore; synced on first run)
::   out\asdoc\                HTML output
::   out\asdoc\_libsrc\        Filtered lib\src temp tree (Crypto stub)
::
:: Flow
::   Check SDK -> filter lib sources -> build Chinese terms
::   -> sync/overlay templates -> run asdoc.jar -> optional open browser
::
:: Notes
::   No chcp / no lang packs: keep the caller's console code page unchanged.
::   Console messages are ASCII-only for encoding safety.
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@echo off
setlocal enabledelayedexpansion

:: Directory of this bat (...\LIB_KyoLib\tools\)
set BAT_HOME=%~dp0

title LIB_KyoLib - ASDoc

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 1) Flex / AIR SDK
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

if "%FLEX_HOME%"=="" (
	echo Environment variable FLEX_HOME is undefined!
	goto END
)
call :EXIST "%FLEX_HOME%"

set FLEX_BIN=%FLEX_HOME%\bin
call :EXIST "%FLEX_BIN%"

:: Invoke jar directly; SDK asdoc.bat breaks on Java 9+
set ASDOC_JAR=%FLEX_HOME%\lib\asdoc.jar
call :EXIST "%ASDOC_JAR%"

set FLEX_FRAMEWORKS=%FLEX_HOME%\frameworks
call :EXIST "%FLEX_FRAMEWORKS%"

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 2) Module paths and optional parent-repo SWC
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: MODULE_ROOT = LIB_KyoLib (parent of tools\)
set MODULE_ROOT=%BAT_HOME%..
for %%I in ("%MODULE_ROOT%") do set MODULE_ROOT=%%~fI

set KYO_SRC=%MODULE_ROOT%\src
set KYO_LIB_SRC=%MODULE_ROOT%\lib\src
call :EXIST "%KYO_SRC%"
call :EXIST "%KYO_LIB_SRC%"

:: Parent monorepo root (e.g. BleachVsNaruto) for LIB_Other.swc
set REPO_ROOT=%MODULE_ROOT%\..
for %%I in ("%REPO_ROOT%") do set REPO_ROOT=%%~fI

set OTHER_SWC=%REPO_ROOT%\out\production\LIB_Other\LIB_Other.swc
if not exist "%OTHER_SWC%" (
	echo [WARN] LIB_Other.swc not found: %OTHER_SWC%
	echo [WARN] Build LIB_Other first if asdoc reports unresolved types.
	set OTHER_SWC=
)

set DOC_OUT=%MODULE_ROOT%\out\asdoc
if not exist "%DOC_OUT%" mkdir "%DOC_OUT%"

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 3) Filter lib\src: drop Crypto.as, write a minimal stub
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: Real com.hurlant.crypto.Crypto has block comments between case labels;
:: asdoc's parser fatals on that, but type-check still needs Crypto symbols.
:: robocopy the tree with /XF Crypto.as, then write a signature-only stub.
::

set FILTERED_LIB=%MODULE_ROOT%\out\asdoc\_libsrc
if exist "%FILTERED_LIB%" rmdir /s /q "%FILTERED_LIB%"
mkdir "%FILTERED_LIB%"

robocopy "%KYO_LIB_SRC%" "%FILTERED_LIB%" /E /XF Crypto.as /NFL /NDL /NJH /NJS /nc /ns /np >nul
set RC=!ERRORLEVEL!
:: robocopy: 0-7 are success-class; >=8 is failure
if !RC! GEQ 8 (
	echo ASDoc generation failed.
	goto END
)

set STUB_DIR=%FILTERED_LIB%\com\hurlant\crypto
if not exist "%STUB_DIR%" mkdir "%STUB_DIR%"
(
	echo package com.hurlant.crypto {
	echo import flash.utils.ByteArray;
	echo import com.hurlant.crypto.symmetric.ICipher;
	echo import com.hurlant.crypto.symmetric.IPad;
	echo public class Crypto {
	echo public static function getCipher^(name:String, key:ByteArray, pad:IPad = null^):ICipher { return null; }
	echo public static function getPad^(name:String^):IPad { return null; }
	echo public static function getKeySize^(name:String^):uint { return 16; }
	echo }
	echo }
) > "%STUB_DIR%\Crypto.as"

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 4) Chinese UI chrome: terms + local templates
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: ASDoc has no locale switch. Chrome labels come from ASDoc_terms.xml:
::   a) build_terms_zh.ps1 writes Chinese terms from SDK English table
::   b) First run copies SDK asdoc\templates locally (gitignore)
::   c) Overlay Chinese ASDoc_terms.xml into that templates dir
::   d) asdoc -templates-path points at the local copy
::

set PATH=%FLEX_BIN%;%PATH%

set ASDOC_TMPL=%MODULE_ROOT%\tools\asdoc\templates
set ASDOC_ZH_TERMS=%MODULE_ROOT%\tools\asdoc\zh_CN\ASDoc_terms.xml

powershell -NoProfile -ExecutionPolicy Bypass -File "%MODULE_ROOT%\tools\asdoc\build_terms_zh.ps1"
if not exist "%ASDOC_ZH_TERMS%" (
	echo ASDoc generation failed.
	goto END
)

if not exist "%ASDOC_TMPL%\asdoc-util.xslt" (
	mkdir "%ASDOC_TMPL%" 2>nul
	robocopy "%FLEX_HOME%\asdoc\templates" "%ASDOC_TMPL%" /E /NFL /NDL /NJH /NJS /nc /ns /np >nul
	set RC=!ERRORLEVEL!
	if !RC! GEQ 8 (
		echo ASDoc generation failed.
		goto END
	)
)
copy /Y "%ASDOC_ZH_TERMS%" "%ASDOC_TMPL%\ASDoc_terms.xml" >nul

echo Generating LIB_KyoLib ASDoc...
echo Output: %DOC_OUT%

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 5) Run asdoc.jar
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
::   +flexlib                  Flex frameworks root
::   -templates-path           Local templates with Chinese terms
::   -compiler.source-path     src + filtered third-party sources
::   -doc-sources              Document only src (not greensock/hurlant pages)
::   -compiler.external-library-path
::                             SDK libs + optional LIB_Other.swc
::   -lenient                  Softer checks on third-party sources
::   -keep-xml=false           Drop intermediate XML
::

if defined OTHER_SWC (
	java -Xmx1536m -classpath "%ASDOC_JAR%" flex2.tools.ASDoc ^
		+flexlib="%FLEX_FRAMEWORKS%" ^
		-templates-path "%ASDOC_TMPL%" ^
		-compiler.source-path "%KYO_SRC%" "%FILTERED_LIB%" ^
		-doc-sources "%KYO_SRC%" ^
		-compiler.external-library-path "%FLEX_FRAMEWORKS%\libs" "%FLEX_FRAMEWORKS%\libs\air" "%FLEX_FRAMEWORKS%\libs\mx" "%OTHER_SWC%" ^
		-lenient ^
		-keep-xml=false ^
		-main-title "LIB_KyoLib API" ^
		-window-title "LIB_KyoLib ASDoc" ^
		-footer "5DPLAY Game Studio - LIB_KyoLib" ^
		-output "%DOC_OUT%"
) else (
	java -Xmx1536m -classpath "%ASDOC_JAR%" flex2.tools.ASDoc ^
		+flexlib="%FLEX_FRAMEWORKS%" ^
		-templates-path "%ASDOC_TMPL%" ^
		-compiler.source-path "%KYO_SRC%" "%FILTERED_LIB%" ^
		-doc-sources "%KYO_SRC%" ^
		-compiler.external-library-path "%FLEX_FRAMEWORKS%\libs" "%FLEX_FRAMEWORKS%\libs\air" "%FLEX_FRAMEWORKS%\libs\mx" ^
		-lenient ^
		-keep-xml=false ^
		-main-title "LIB_KyoLib API" ^
		-window-title "LIB_KyoLib ASDoc" ^
		-footer "5DPLAY Game Studio - LIB_KyoLib" ^
		-output "%DOC_OUT%"
)

if errorlevel 1 (
	echo ASDoc generation failed.
	goto END
)

echo ASDoc generated: %DOC_OUT%\index.html

if /i "%OPEN%"=="1" (
	if exist "%DOC_OUT%\index.html" start "" "%DOC_OUT%\index.html"
)

echo.
exit /b 0

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:END
pause >nul
exit /b 1

:EXIST
if not exist %1 (
	echo File does not exist: %~1
	goto END
)
goto :EOF
