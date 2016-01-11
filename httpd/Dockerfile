FROM ubuntu:trusty

# Install apache
RUN DEBIAN_FRONTEND=noninteractive

RUN apt-get -y install software-properties-common
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C
RUN apt-add-repository ppa:ondrej/php5-5.6

RUN apt-get -y update && apt-get -y install \
  apache2 \
  libapache2-mod-php5 \
  php5-mysql \
  php5-gd \
  php-apc \
  php5-curl \
  php5-xdebug \
  php5-mcrypt \
  curl \
  ghostscript

# Enable apache mods
RUN a2enmod php5 && a2enmod rewrite && a2enmod headers
# Enable Proxy mods
RUN a2enmod proxy_http && a2enmod deflate && a2enmod proxy_connect

# Error reporting
RUN sed -i "s/error_reporting = .*$/error_reporting = E_ERROR | E_WARNING | E_PARSE/" /etc/php5/apache2/php.ini

# Add PDFLib extension
ADD php_pdflib.so /php_pdflib.so

# Add ICC profiles
ADD ISOnewspaper26v4.icc /icc_profiles/
ADD ISOnewspaper26v4_gr.icc /icc_profiles/

# Overwrite configurations
ADD apache.conf /etc/apache2/apache2.conf
ADD vhosts.conf /etc/apache2/sites-enabled/000-default.conf
ADD php.ini /etc/php5/apache2/php.ini

ADD run.sh /run.sh

EXPOSE 80

CMD ["/bin/bash", "run.sh"]
