FROM ubuntu:trusty

# Install apache
RUN DEBIAN_FRONTEND=noninteractive

# php 5.6
RUN apt-get -y install software-properties-common
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C
RUN apt-add-repository ppa:ondrej/php5-5.6

# packages
RUN apt-get -y update 

RUN apt-get -y install \
  apache2 \
  libapache2-mod-php5 \
  php5-mysql \
  php5-gd \
  php-apc \
  php5-curl \
  php5-cli \
  php5-mcrypt \
  php5-ssh2 \
  ghostscript \
  language-pack-de \
  language-pack-nl \
  language-pack-fr

# java 8
RUN \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java8-installer && \
  rm -rf /var/cache/oracle-jdk8-installer


  
  
# Enable apache mods
RUN a2enmod php5 && \
    a2enmod rewrite && \
    a2enmod headers && \
    a2enmod proxy_http && \
    a2enmod deflate && \
    a2enmod proxy_connect && \
    a2enmod macro

# Error reporting
RUN sed -i "s/error_reporting = .*$/error_reporting = E_ERROR | E_WARNING | E_PARSE/" /etc/php5/apache2/php.ini

# Add PHP extensions
ADD php_ext /php_ext

# Add ICC profiles
ADD icc_profiles /icc_profiles

# Apache Configuration
ADD apache/apache.conf /etc/apache2/apache2.conf
ADD apache/macros /etc/apache2/macros
ADD apache/sites-available /etc/apache2/sites-available

RUN a2dissite 000-default

RUN apache2ctl configtest
ADD php.ini /etc/php5/apache2/php.ini

# setup scripts
ADD scripts /scripts
RUN chmod +x -R /scripts/  


# Application Packages
COPY packages /amak-packages

# Extract Application
RUN /scripts/extract.sh


# Exports
EXPOSE 80

CMD ["/bin/bash", "/scripts/run.sh"]
