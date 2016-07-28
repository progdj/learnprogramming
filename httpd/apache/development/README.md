#Development Apache Config

- This directory will be copied inside your local `httpd` container.
- You can use this to configure special rules which should not be contained on other developer machines.
- Any \*.conf file will be included within the `apache server scope config`. 

## Example Proxy Setup

If you try to host a running development environment outside the vrs office, 
you might need to setup some proxies to use external services.

I use a **socks 5 proxy** configured on my `ssh config` for an `vrs-server`.
 
    Host vrs-endpoint
        HostName ...
        Port ...
        User ...
        IdentityFile ...
        # socks proxy bound on local port 3333
        DynamicForward 3333

This will allow you to use `127.0.0.1:3333` as `socks proxy`. Unfortunately most soap clients require a http based proxy.
 
To create a httpd proxy out of your local socks proxy you can use http://www.delegate.org/delegate/. 
With delegate you can create a http proxy on a new local port.

    ~/DGROOT/bin/dg9_9_13 -P4444 SERVER=http ADMIN=your@mail.de SOCKS=localhost:333
    
This will open a http proxy on `127.0.0.1:4444`. 

This can be used within the **docker networks** too. Within a docker container you can access this proxy
by using the docker host `docker0`. This could be something like `172.17.0.1:4444`.

Within your **php soap clients** you just need to define `options[proxy_host]` and `options[proxy_port]`.
 
Another possible problem is any apache reverse proxy. You can handle this by placing a config file like **proxy.conf** in this folder.


    ProxyRemote "http://chili.vrsmedia.online/CHILI/" "http://172.17.0.1:4444"
    ProxyRemote "http://salespoint.alfa-openmedia.de:8083/stylo" "http://172.17.0.1:4444"
    ProxyRemote "http://salespoint.alfa-openmedia.de:8083/ASESalesPoint/ASEService" "http://172.17.0.1:4444"
    ProxyRemote "http://admarket-test.rhein-zeitung.net/stylo" "http://172.17.0.1:4444"
    ProxyRemote "http://admarket-test.rhein-zeitung.net:8084/ASESalesPoint/ASEService" "http://172.17.0.1:4444"
     
Please note that you need to rebuild the httpd container after you have changed this file.