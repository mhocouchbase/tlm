set INSTALL_DIR=%1

rem Get Google's depot_tools.
if not exist depot_tools (
    git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git || goto error
)
set PATH=%cd%\depot_tools;%PATH%

rem Setting MSVC version specifically to 2017
set GYP_MSVS_VERSION=2017

rem Disable gclient getting Google-internal versions of stuff
set DEPOT_TOOLS_WIN_TOOLCHAIN=0

rem Set up gclient config for tag to pull for v8, then do sync
rem (this handles the 'fetch v8' done by the usual process)
echo solutions = [ { "url": "https://github.com/couchbasedeps/v8-mirror.git@8.5.210.26","managed": False, "name": "v8", "deps_file": "DEPS", }, ]; > .gclient
call gclient sync || goto error
echo on

rem Actual v8 configure and build steps - we build debug and release.
cd v8
rem Use double-quoting here because .bat quote removal is inscrutable.
set V8_ARGS=target_cpu=""x64"" use_custom_libcxx=true is_component_build=true v8_enable_backtrace=true v8_use_snapshot=true v8_use_external_startup_data=false v8_enable_pointer_compression=false
call gn gen out.gn/x64.release --args="%V8_ARGS% is_debug=false" || goto error

echo on
call ninja -C out.gn/x64.release || goto error
echo on
call gn gen out.gn/x64.debug --args="%V8_ARGS% is_debug=true" || goto error
echo on
call ninja -C out.gn/x64.debug || goto error
echo on

rem Copy right stuff to output directory.
mkdir %INSTALL_DIR%\lib\Release
mkdir %INSTALL_DIR%\lib\Debug
mkdir %INSTALL_DIR%\include\libplatform
mkdir %INSTALL_DIR%\include\cppgc
mkdir %INSTALL_DIR%\include\unicode

cd out.gn\x64.release
copy v8.dll* %INSTALL_DIR%\lib\Release || goto error
copy v8_lib* %INSTALL_DIR%\lib\Release || goto error
copy cppgc.* %INSTALL_DIR%\lib\Release || goto error
copy icu*.* %INSTALL_DIR%\lib\Release || goto error
copy libc*.* %INSTALL_DIR%\lib\Release || goto error
copy zlib*.* %INSTALL_DIR%\lib\Release || goto error
del %INSTALL_DIR%\lib\Release\*.ilk || goto error

cd ..\..\out.gn\x64.debug
copy v8.dll* %INSTALL_DIR%\lib\Debug || goto error
copy v8_lib* %INSTALL_DIR%\lib\Debug || goto error
copy cppgc.* %INSTALL_DIR%\lib\Debug || goto error
copy icu*.* %INSTALL_DIR%\lib\Debug || goto error
copy libc*.* %INSTALL_DIR%\lib\Debug || goto error
copy zlib*.* %INSTALL_DIR%\lib\Debug || goto error
del %INSTALL_DIR%\lib\Debug\*.ilk || goto error

cd ..\..\include
copy v8*.h %INSTALL_DIR%\include || goto error
cd libplatform
copy *.h %INSTALL_DIR%\include\libplatform || goto error
cd ..\cppgc
copy *.h %INSTALL_DIR%\include\cppgc || goto error

cd ..\..\third_party\icu\source\common\unicode
copy *.h %INSTALL_DIR%\include\unicode || goto error
cd ..\..\io\unicode
copy *.h %INSTALL_DIR%\include\unicode || goto error
cd ..\..\i18n\unicode
copy *.h %INSTALL_DIR%\include\unicode || goto error
cd ..\..\extra\uconv\unicode
copy *.h %INSTALL_DIR%\include\unicode || goto error

goto :eof

:error
echo Failed with error %ERRORLEVEL%
exit /B %ERRORLEVEL%
