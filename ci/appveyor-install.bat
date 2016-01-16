set PATH=%PATH%;C:\msys64\usr\bin;C:\msys64\mingw32

cd %APPVEYOR_BUILD_FOLDER%
sh ci\appveyor-install.sh
