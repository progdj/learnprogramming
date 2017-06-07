#!/bin/bash

#
# Licenseholder Data Directory Prepare
# Paramater #1 VRS-Application data directory. something like /var/www/amak-frontend
VRSDATADIR=$1/data


createLinksForValidLicenseholders() {
    for dir in $VRSDATADIR/*/
    do
        dir=${dir%*/}
        verifyLicenseholderId ${dir##*/}
        if [ $? -eq 0 ]
        then
            printf "Linking \033[0;32m${dir##*/}\033[0m ..."
            createLicenseholderDataDirectories ${dir##*/};
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


createLicenseholderDataDirectories() {
    local licenseholderId=$1
    createLicenseholderDirectory $licenseholderId ads
    createLicenseholderDirectory $licenseholderId ads/managed
    createLicenseholderDirectory $licenseholderId graphics
    createLicenseholderDirectory $licenseholderId graphics/preview
    createLicenseholderDirectory $licenseholderId graphics/print
    createLicenseholderDirectory $licenseholderId export
    createLicenseholderDirectory $licenseholderId export/general
    createLicenseholderDirectory $licenseholderId export/zip
    createLicenseholderDirectory $licenseholderId pdf
    createLicenseholderDirectory $licenseholderId upload_images
    createLicenseholderDirectory $licenseholderId upload_images/background
    createLicenseholderDirectory $licenseholderId upload_images/background/print
    createLicenseholderDirectory $licenseholderId upload_images/symbol
    createLicenseholderDirectory $licenseholderId upload_images/symbol/print
    createLicenseholderDirectory $licenseholderId upload_images/mobile
    createLicenseholderDirectory $licenseholderId upload_images/mobile/print
    createLicenseholderDirectory $licenseholderId upload_images/mobile/background
    createLicenseholderDirectory $licenseholderId upload_images/mobile/symbol
    createLicenseholderDirectory $licenseholderId upload_pdf
    createLicenseholderDirectory $licenseholderId upload_pdf/pdf
    createLicenseholderDirectory $licenseholderId incoming
    createLicenseholderDirectory $licenseholderId archiv
    createLicenseholderDirectory $licenseholderId temp
    createLicenseholderDirectory $licenseholderId references
}

createLicenseholderDirectory()
{
    local licenseholderId=$1
    local folder=$2

    if [[ ! -d $VRSDATADIR/$licenseholderId/$folder ]]; then
        mkdir -p $VRSDATADIR/$licenseholderId/$folder
        printf " \033[0;32m$folder(+)\033[0m"
        chown www-data:www-data -R $VRSDATADIR/$licenseholderId/$folder
    fi
}

createLinksForValidLicenseholders;