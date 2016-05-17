#!/bin/bash

# Install ghostscript

cd /compile/

tar xzvf ghostscript-9.19-linux-x86_64.tgz

cp ghostscript-9.19-linux-x86_64/gs-919-linux_x86_64 /usr/bin/gs-919-linux_x86_64

rm -f /usr/bin/gs

ln -s /usr/bin/gs-919-linux_x86_64 /usr/bin/gs

echo "installed ghostscript Version:"

gs --version
