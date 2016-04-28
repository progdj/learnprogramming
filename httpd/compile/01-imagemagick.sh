#!/usr/bin/env bash

cd /compile/

# Compile and install script for imagemagick version 6.9.3-8.

apt-get update && apt-get install build-essential && apt-get build-dep imagemagick -y
wget http://www.imagemagick.org/download/ImageMagick-6.9.3-8.tar.gz
tar xzvf ImageMagick-6.9.3-8.tar.gz
cd ImageMagick-6.9.3-8/
./configure
make
make install
ldconfig /usr/local/lib
identify --version
convert --version