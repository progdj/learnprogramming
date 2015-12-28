FROM ubuntu:trusty

# Install apache
RUN DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get -y install \
  apache2 \
  libapache2-mod-php5 \
  php5-mysql \
  php5-gd \
  php-apc \
  php5-curl \
  php5-xdebug \
  curl

# Enable apache mods
RUN a2enmod php5 && a2enmod rewrite && a2enmod headers
# Enable Proxy mods
RUN a2enmod proxy_http && a2enmod deflate && a2enmod proxy_connect

# Error reporting
RUN sed -i "s/error_reporting = .*$/error_reporting = E_ERROR | E_WARNING | E_PARSE/" /etc/php5/apache2/php.ini

# Overwrite configurations
ADD apache.conf /etc/apache2/apache2.conf
ADD vhosts.conf /etc/apache2/sites-enabled/000-default.conf
ADD php.ini /etc/php5/apache2/php.ini

ADD run.sh /run.sh

EXPOSE 80

CMD ["/bin/bash", "run.sh"]
