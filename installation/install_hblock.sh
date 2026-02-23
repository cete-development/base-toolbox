#/bin/bash

folder="/tmp/hblock"
if [ -d "$folder" ]; then
    sudo rm -r "$folder"
fi
git clone https://github.com/hectorm/hblock  /tmp/hblock
cd /tmp/hblock
sudo make install
hblock
