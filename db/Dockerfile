FROM percona:latest

# We need to overwrite the default settings, so that
# the Barracuda file format is used
ADD my.cnf /etc/mysql/my.cnf
RUN chmod 644 /etc/mysql/my.cnf