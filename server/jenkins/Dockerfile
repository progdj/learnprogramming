FROM jenkins

USER root

# php 5.6
RUN apt-get -y update \
    && apt-get -y install \
       php5-mysql \
       php5-gd \
       php-apc \
       php5-curl \
       php5-mcrypt \
       php5-ssh2 \
       php5-xsl \
       curl \
       ghostscript \
       locales-all

# Install composer
RUN curl getcomposer.org/composer.phar > /usr/bin/composer \
    && chmod +x /usr/bin/composer

# Apt cache Problems
# RUN rm -rf /var/lib/apt/lists/* && apt-get clean && apt-get update && apt-get upgrade -y

# Install Node Js and grunt, bower and ant
RUN curl -sL https://deb.nodesource.com/setup_dev | bash - \
    && apt-get install --yes nodejs build-essential ant \
    && npm install -g grunt-cli
    && npm install -g bower


ENV COMPOSER_HOME /home/composer
ENV PATH $PATH:/home/composer/vendor/bin

# Install PHP Code Tools
RUN mkdir /home/composer \
    && chmod 777 /home/composer \
    && export COMPOSER_HOME=/home/composer \
    && chown jenkins:jenkins -R /home/composer \
    && wget http://phpdox.de/releases/phpdox.phar \
    && chmod +x phpdox.phar \
    && mv phpdox.phar /usr/local/bin/phpdox

USER jenkins
RUN composer global require "squizlabs/php_codesniffer=*" \
    && composer global require 'phploc/phploc=*' \
    && composer global require 'pdepend/pdepend=*' \
    && composer global require 'phpmd/phpmd=*' \
    && composer global require 'sebastian/phpcpd=*'


# Set Server TimeZone
ENV TZ Europe/Berlin