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
    apt-add-repository ppa:ondrej/php

# packages
RUN apt-get -y update && \
	apt-get -y install \
  apache2 \
  libapache2-mod-php5.6 \
  php5.6-mysql \
  php5.6-gd \
  php5.6-apc \
  php5.6-curl \
  php5.6-soap \
  php5.6-dom \
  php5.6-imap \
  php5.6-zip \
  php5.6-mbstring \
  php5.6-cli \
  php5.6-mcrypt \
  php5.6-ssh2 \
  libgpgme11-dev \
  php-pear \
  php5.6-dev \
  php5.6 \
  php5.6-bcmath \
  language-pack-de \
  language-pack-nl \
  language-pack-fr

# php configuration
ADD php/apache2/php.ini /etc/php/5.6/apache2/php.ini
ADD php/cli/php.ini /etc/php/5.6/cli/php.ini

# Install GnuPG PHP Extension
# RUN pecl install gnupg
# ADD php/mods-available/gnupg.ini /etc/php/5.6/mods-available/
# RUN ln -s /etc/php/5.6/mods-available/gnupg.ini /etc/php/5.6/apache2/conf.d/20-gnupg.ini

# php vrs-extensions
ADD php/vrsmedia-extensions /usr/lib/php/5.6/vrsmedia-extensions

# php vrs-extensions pdflib
ADD php/mods-available/pdflib.ini /etc/php/5.6/mods-available/
RUN ln -s /etc/php/5.6/mods-available/pdflib.ini /etc/php/5.6/apache2/conf.d/20-pdflib.ini

# Enable apache mods
RUN a2enmod php5.6 && \
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
RUN /compile/03-prince.sh

# Add ICC profiles
ADD icc_profiles /icc_profiles

# Apache Configuration
ADD apache/apache.conf /etc/apache2/apache2.conf
ADD apache/cdn-domains.conf /etc/apache2/cdn-domains.conf
ADD apache/cms-domains.conf /etc/apache2/cms-domains.conf
ADD apache/amak-hostid.conf /etc/apache2/amak-hostid.conf
ADD apache/macros /etc/apache2/macros
ADD apache/sites-available /etc/apache2/sites-available

RUN a2dissite 000-default

# maintenance page and default vhost, used if no host is matching at all
ADD amak-maintenance /var/www/amak-maintenance
RUN a2ensite 00-amak-maintenance

RUN apache2ctl configtest

# setup scripts
ADD scripts /scripts
RUN chmod +x -R /scripts/


# Application Packages
COPY packages /amak-packages

# Extract Application
RUN /scripts/extract.sh

# Set Server TimeZone
ENV TZ Europe/Berlin

# Add GPG Keyring
RUN mkdir /www-gpg && chown www-data:www-data /www-gpg && chmod -R go-rwx /www-gpg
ENV GNUPGHOME /www-gpg
USER www-data
ADD pgp-keys /pgp-keys
RUN /scripts/gpg.sh
USER root

# set correct php version as standard
RUN update-alternatives --set php /usr/bin/php5.6

# Exports
EXPOSE 80

CMD ["/bin/bash", "/scripts/run.sh"]
