export CPPFLAGS="-I$HOME/devroot/include"
export LDFLAGS="-L$HOME/devroot/lib"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$HOME/devroot/lib"
source $HOME/BYOND-${BYOND_MAJOR}.${BYOND_MINOR}/byond/bin/byondsetup
