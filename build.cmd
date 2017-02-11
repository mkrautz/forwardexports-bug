:: Copyright 2005-2017 The Mumble Developers. All rights reserved.
:: Use of this source code is governed by a BSD-style license
:: that can be found in the LICENSE file at the root of the
:: Mumble source tree or at <https://www.mumble.info/LICENSE>.

:: Enter VC env if necessary
where cl.exe >NUL
if %errorlevel% equ 0 goto :novc
call "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat" x86
:novc

cl /LD /MT dummycrt.cpp
if %errorlevel% neq 0 exit /b %errorlevel%

cl /LD /MT crtimpl.cpp
if %errorlevel% neq 0 exit /b %errorlevel%

cl /LD /MT app.cpp dummycrt.lib
if %errorlevel% neq 0 exit /b %errorlevel%

cl /MT /EHsc main.cpp /link /out:main.exe user32.lib shlwapi.lib
if %errorlevel% neq 0 exit /b %errorlevel%

rmdir /s /q out
if %errorlevel% neq 0 exit /b %errorlevel%

mkdir out\crtdir
if %errorlevel% neq 0 exit /b %errorlevel%

move main.exe out
if %errorlevel% neq 0 exit /b %errorlevel%

move crtimpl.dll out\crtdir
if %errorlevel% neq 0 exit /b %errorlevel%

move dummycrt.dll out\crtdir
if %errorlevel% neq 0 exit /b %errorlevel%

move app.dll out\crtdir
if %errorlevel% neq 0 exit /b %errorlevel%
