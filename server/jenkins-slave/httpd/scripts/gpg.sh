#!/bin/bash

# import tool for gpg file

FILES=/pgp-keys/*asc
for gpgfile in $FILES
do
    if [ -f ${gpgfile} ]; then
        echo "Importing ${gpgfile}..."
        gpg --import ${gpgfile}
        if [ $? -ne 0 ]; then
            echo "Failed to import the file ${gpgfile}..."
            exit 1
        fi;
    fi;
done


exit 0