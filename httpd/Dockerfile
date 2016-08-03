FROM ubuntu:trusty

# Non interactive frontend
RUN DEBIAN_FRONTEND=noninteractive

# ppa management
RUN apt-get update && apt-get -y install software-properties-common

# java 8
RUN \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java8-installer && \
  rm -rf /var/cache/oracle-jdk8-installer && \
  apt-get -y update && \
  apt-get -y install oracle-java8-installer


# php 5.6 repository
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C && \
    apt-add-repository ppa:ondrej/php5-5.6

# packages
RUN apt-get -y update && \
	apt-get -y install \
  apache2 \
  libapache2-mod-php5 \
  php5-mysql \
  php5-gd \
  php-apc \
  php5-curl \
  php5-cli \
  php5-mcrypt \
  php5-ssh2 \
  libgpgme11-dev \
  php-pear \
  php5-dev \
  language-pack-de \
  language-pack-nl \
  language-pack-fr

# php configuration
ADD php/apache2/php.ini /etc/php5/apache2/php.ini
ADD php/cli/php.ini /etc/php5/cli/php.ini

# Install GnuPG PHP Extension
RUN pecl install gnupg
ADD php/mods-available/gnupg.ini /etc/php5/mods-available/
RUN php5enmod gnupg

# php vrs-extensions
ADD php/vrsmedia-extensions /usr/lib/php5/vrsmedia-extensions

# php vrs-extensions pdflib
ADD php/mods-available/pdflib.ini /etc/php5/mods-available/
RUN php5enmod pdflib && php5enmod pdflib

# development only packages
RUN apt-get -y update && \
	apt-get -y install \
   curl \
   git \
   npm \
   nodejs-legacy \
   php5-xdebug

# Install composer (dev only)
RUN curl getcomposer.org/composer.phar > /usr/bin/composer
RUN chmod +x /usr/bin/composer

# Install grunt bower (dev only)
RUN npm install -g grunt-cli && npm install -g bower

# Enable apache mods
RUN a2enmod php5 && \
    a2enmod rewrite && \
    a2enmod headers && \
    a2enmod proxy_http && \
    a2enmod deflate && \
    a2enmod proxy_connect && \
    a2enmod macro

# Compile special versions
ADD compile /compile
RUN chmod +x -R /compile/
RUN /compile/01-imagemagick.sh
RUN /compile/02-ghostscript.sh

# Add ICC profiles
ADD icc_profiles /icc_profiles

# Apache Configuration
ADD apache/apache.conf /etc/apache2/apache2.conf
ADD apache/macros /etc/apache2/macros
ADD apache/sites-available /etc/apache2/sites-available

RUN a2dissite 000-default

# setup scripts
ADD scripts /scripts
RUN chmod +x -R /scripts/

# Set Server TimeZone
ENV TZ Europe/Berlin

# application environment for development container only!
ENV ENVIRONMENT development

# Add GPG Keyring
RUN mkdir /www-gpg && chown www-data:www-data /www-gpg && chmod -R go-rwx /www-gpg
ENV GNUPGHOME /www-gpg
USER www-data
ADD pgp-keys /pgp-keys
RUN /scripts/gpg.sh
USER root

# special local development machine config
ADD apache/development /etc/apache2/development

# check syntax
RUN apache2ctl configtest

# Exports
EXPOSE 80

# common aliases for development
RUN alias la='ls -hal'
RUN alias ..='cd ..'

WORKDIR "/var/www"
CMD ["/bin/bash", "/scripts/run.sh"]


