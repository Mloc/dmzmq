set PATH=C:\msys64\usr\bin;C:\msys64\mingw32\bin;%PATH%

cd %APPVEYOR_BUILD_FOLDER%
echo %BYOND_MAJOR%

bash -lc 'cd $APPVEYOR_BUILD_FOLDER ; ci/appveyor-install.sh'
