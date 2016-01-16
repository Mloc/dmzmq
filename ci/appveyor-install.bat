set PATH=%PATH%;C:\msys64\usr\bin;C:\msys64\mingw32

cd %APPVEYOR_BUILD_FOLDER%

sh -c 'pacman --noconfirm --needed -Sy bash pacman pacman-mirrors msys2-runtime'
sh -c 'pacman --noconfirm -Su'

sh ci\appveyor-install.sh %BYOND_MAJOR% %BYOND_MINOR% %LIBSODIUM_VERSION% %LIBZMQ_VERSION%
