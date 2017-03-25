#!/bin/bash

# Install Prince-XML

cd /compile/

# preset
apt-get install libgif4

tar xzvf prince-11.1-ubuntu14.04-amd64.tar.gz

cd prince-11.1-ubuntu14.04-amd64/

./install.sh < "/usr/bin"

echo "installed prince 11.1"

prince --version
