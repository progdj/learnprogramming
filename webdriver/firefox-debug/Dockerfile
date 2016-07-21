FROM selenium/standalone-firefox-debug

USER root
RUN apt-get update && apt-get install --yes iputils-ping

COPY /scripts/addDynamicVHosts.sh /opt/bin/addDynamicVHosts.sh

CMD /opt/bin/addDynamicVHosts.sh && sudo su - seluser && /opt/bin/entry_point.sh