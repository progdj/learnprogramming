#!/bin/bash

#
# Licenseholder Data Mapping
# Paramater #1 VRS-Application data directory. something like /var/www/amak-frontend
VRSDATADIR=$1/data
# Parameter #2 the VRS-NFS-Mount data directory.
NFS=$2

createLinksForValidLicenseholders() {
    for dir in $VRSDATADIR/*/
    do
        dir=${dir%*/}
        verifyLicenseholderId ${dir##*/}
        if [ $? -eq 0 ]
        then
            printf "Linking \033[0;32m${dir##*/}\033[0m Folders: "
            createLicenseholderDataLinks ${dir##*/};
            printf "\n"
        else
            printf "Skipping \033[0;31m${dir##*/}\033[0m\n"
        fi
    done
}

verifyLicenseholderId() {
    local licenseholderId=$1
    re='^[0-9]+$'
    if ! [[ $licenseholderId =~ $re ]] ; then
       return 1
    fi
    return 0
}


createLicenseholderDataLinks() {
    local licenseholderId=$1
    createLicenseholderDependingLink $licenseholderId ads
    printf ", "
    createLicenseholderDependingLink $licenseholderId graphics
    printf ", "
    createLicenseholderDependingLink $licenseholderId export
    printf ", "
    createLicenseholderDependingLink $licenseholderId pdf
    printf ", "
    createLicenseholderDependingLink $licenseholderId upload_images
    printf ", "
    createLicenseholderDependingLink $licenseholderId upload_pdf
}

createLicenseholderDependingLink()
{
    local licenseholderId=$1
    local folder=$2

    if [[ -d $NFS/$licenseholderId/$folder ]]; then
      rm -R -f $VRSDATADIR/$licenseholderId/$folder
      ln -s $NFS/$licenseholderId/$folder $VRSDATADIR/$licenseholderId/$folder
      printf "\033[0;32m$folder(+)\033[0m"
    else 
      printf "\033[0;31m$folder\033[0m"
    fi
}

createLinksForValidLicenseholders;