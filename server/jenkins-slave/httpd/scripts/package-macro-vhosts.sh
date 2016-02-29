#!/usr/bin/env bash

# Apache Dynamic vHost Setup Util
# This script will print a apache configuration using the macro package syntax.

#package="frontend";
#packagePath=/var/www/amak-frontend
#domainConfigPath=/var/www/amak-frontend
#maindomainSuffix=".local"

package=$1;
packagePath=$2
domainConfigPath=$3
maindomainSuffix=$4


function getAlias()
{
    local line;
    local config;
    local configLcid;
    local lcid=$1;

    if [ -f $domainConfigPath/$package.properties ]; then
        cat $domainConfigPath/$package.properties | while read line
        do
            IFS=";";
            config=($line);
            configLcid=${config[0]};
            if [ "$lcid" == "$configLcid" ]; then
                echo -n "${config[1]} ";
            fi
        done
    fi
    echo -n "$package-$lcid";
}

php $packagePath/yiic apachesetup --filter=$package | while read line
do
    IFS="|";
    config=($line);
    name=${config[0]};
    domain=${config[1]};
    lid=${config[2]};
    lcid=${config[3]};
    alias=$(getAlias $lcid)
    echo "# $name\n";
    echo -n "Use amak-$package $domain $lid $lcid \"$alias";
    if [ "$maindomainSuffix" != "" ]; then
        echo -n " $domain$maindomainSuffix";
    fi
    echo -n "\""
    echo ""; echo "\n\n";
done

exit 0