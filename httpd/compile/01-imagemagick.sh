#!/usr/bin/env bash

cd /compile/

# Compile and install script for ImageMagick

apt-get update && apt-get install build-essential && apt-get build-dep imagemagick -y
tar xzvf ImageMagick-6.9.4-1.tar.gz
cd ImageMagick-6.9.4-1/
./configure
make
make install
ldconfig /usr/local/lib
identify --version
convert --version