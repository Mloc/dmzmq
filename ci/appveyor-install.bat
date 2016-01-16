set PATH=C:\msys64\usr\bin;C:\msys64\mingw32;%PATH%

cd %APPVEYOR_BUILD_FOLDER%

sh --login ci\appveyor-install.sh %BYOND_MAJOR% %BYOND_MINOR% %LIBSODIUM_VERSION% %LIBZMQ_VERSION%
