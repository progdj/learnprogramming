#!/bin/bash

# Install Prince-XML

cd /compile/

# preset
apt-get install libgif4

tar xzvf prince-10r7-ubuntu14.04-amd64.tar.gz

cd prince-10r7-ubuntu14.04-amd64/

./install.sh < "/usr/local"

echo "installed prince 10r7"