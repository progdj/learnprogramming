#!/bin/bash

# Install Prince-XML

cd /compile/

# preset
apt-get install libgif4

tar xzvf prince-11.1-ubuntu14.04-amd64.tar.gz

cd prince-11.1-ubuntu14.04-amd64/

./install.sh < "/usr/local/bin"

cd ..

cp ./prince-11-license.dat /usr/local/lib/prince/license/license.dat

echo "installed prince 11.1"

prince --version
