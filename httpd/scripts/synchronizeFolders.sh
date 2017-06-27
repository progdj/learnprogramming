#!/bin/bash

SOURCE_DIRECTORY=$1
DESTINATION_DIRECTORY=$2

synchronizeFilesAndFolders() {

    verifyDestination $DESTINATION_DIRECTORY
    if [ $? -eq 0 ]
    then
        printf "Destination Directory is not secure \033[0;32m$DESTINATION_DIRECTORY\033[0m";
        return 1
    fi

    for dir in $SOURCE_DIRECTORY/*/
    do
        dir=${dir%*/}
        verifyLicenseholderId ${dir##*/}
        if [ $? -eq 0 ]
        then
            printf "Using Data-Folder \033[0;32m${dir##*/}\033[0m ..."
            emptySystemDependentFolders ${dir##*/}
	        removeOldPdfDocumentsFromFolder ${dir##*/} pdf
	        syncAllFoldersForTemplateCreation ${dir##*/}
            printf "\n"
        else
            printf "Skipping \033[0;31m${dir##*/}\033[0m\n"
        fi
    done
}

verifyDestination() {
    local destinationDirectory=$1
    if [[ $destinationDirectory =~ (TEST|STAGING|ALPHA|BETA) ]]; then
       return 1
    fi
    return 0
}

verifyLicenseholderId() {
    local licenseholderId=$1
    re='^[0-9]+$'
    if ! [[ $licenseholderId =~ $re ]] ; then
       return 1
    fi
    return 0
}

emptySystemDependentFolders() {
  local licenseholderId=$1

  emptyFilesFromFolder $licenseholderId export
  emptyFilesFromFolder $licenseholderId upload_images
  emptyFilesFromFolder $licenseholderId upload_pdf
  emptyFilesFromFolder $licenseholderId incoming
  emptyFilesFromFolder $licenseholderId archive
  emptyFilesFromFolder $licenseholderId temp
}

emptyFilesFromFolder() {
    local licenseholderId=$1
    local folder=$2

    if [[ -d $DESTINATION_DIRECTORY/$licenseholderId/$folder ]]; then
        find $DESTINATION_DIRECTORY/$licenseholderId/$folder -type f -exec rm -f {} \;
        printf "Removed files from \033[0;32m$DESTINATION_DIRECTORY/$licenseholderId/$folder\033[0m"

    fi
}

removeOldPdfDocumentsFromFolder() {
    local licenseholderId=$1
    local folder=$2

    if [[ -d $DESTINATION_DIRECTORY/$licenseholderId/$folder ]]; then
        find $DESTINATION_DIRECTORY/$licenseholderId/$folder -name "*.pdf" -mtime +60 -exec rm -f {} \;
        printf "Removed old pdf files from \033[0;32m$folder\033[0m"

    fi
}

syncAllFoldersForTemplateCreation() {
    local licenseholderId=$1

    syncFolderForTemplateCreation $licenseholderId graphics
    syncFolderForTemplateCreation $licenseholderId ads
}

syncFolderForTemplateCreation() {
    local licenseholderId=$1
    local folder=$2

    if [[ -d $DESTINATION_DIRECTORY/$licenseholderId/$folder ]]; then
	    rsync -aPu $SOURCE_DIRECTORY/$licenseholderId/$folder $DESTINATION_DIRECTORY/$licenseholderId/$folder
        printf "Synchronised Files from \033[0;32m$SOURCE_DIRECTORY/$licenseholderId/$folder\033[0m to \033[0;32m$DESTINATION_DIRECTORY/$licenseholderId/$folder\033[0m"
    fi
}

synchronizeFilesAndFolders;