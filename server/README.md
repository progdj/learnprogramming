# AMAK Docker Server Environment

Welcome to the AMAK Docker Server Environment. Here you'll find our setup for production systems, based on docker.

- Have a look at https://github.com/VRSMedia/amak-docker/wiki too...
- `jenkins` contains the setup for our ci server itself.
- `jenkins-slave` contains the setup for a server which is controlled by jenkins. 

## Jenkins Slave

## Requirements

- A slave should be configured to host a home for user `jenkins`.
- A slave must host a docker service. https://docs.docker.com/engine/installation/linux/
- At jenkins home should be a checkout from `amak-docker` with a symlink named `slave` pointing to checkout `server/jenkins-slave`.
 - like `lrwxrwxrwx 1 jenkins jenkins   47 Feb 29 22:57 slave -> /home/jenkins/amak-docker/server/jenkins-slave/`
- The user jenkins must have a valid ssh configuration, that includes private key and authorized_keys!
- Follow `docker-control.sh` and `environments/README.md` to follow the ci process. 

### Tasks and Setups

- We support 2 ways to create and host containers.
 - Source Code based containers, which are created after a pull from git. This containers are used for testing and development purposes. These containers will use the workflow controlled by `docker-control.sh setup-package`.
 - Image based container deployments, which are created out of an image from `docker-control.sh setup-package`. The workflow for this deployment is cointrolled by `docker-share.sh`.
- Both ways use the [environment config](jenkins-slave/environments/README.md) logic to define what configuration will be used to host the actual container.

### Production Containers

A production container should be created out of an image from a container that was tested before. 
Doing so ensures that the result of docker build and current package versions are working together, 
as every new build could change versions within the used os or third party libs.
To do so `docker-control.sh export-image` will create a docker image based on the `environment` you passed.

We expect different hosts for develop and production.

`docker load` will use this file to restore the tag on the foreign host using the passed environment to define which configuration should be used to host the image.

`docker-share.sh` combines all steps needed to `export`, `transfer` and `import` a image from the source server to the actual production server. 
   

### HowTo: create a docker server image (bloody by hand)

- A image can be used to create a running container and might get shared on a hub.
- You'll need all current packages. (`amak-frontend`, `amak-source`, `amak-portal`, `amak-cms`)
 - To obtain a package run `vendor/bin/phing package` within your working copy of `amak-frontend`, `amak-portal` and `amak-cms`.
 - Copy all files from your working copies folder `dist` to `jenkins-slave/httpd/amak-packages`. (For each application!)
- Now you can build an image, simply run


    docker build -t your-docker-image-tag ./jenkins-slave/httpd/


- Change `your-docker-image-tag` to a tag name, just like `amak-nrc-2016-02-19-1200`…
- Your image is ready to use now.

### HowTo: use a server image (bloody by hand)

- Next step is to create a running container out of the created image.
- First we need to know what requirements our image has:
 - configuration folder is expected at `/amak-config/` (containing the file `config.properties`)
 - data shared folder is expected at `/amak-data/` (containing the licenseholder shared frontend data)
 - data shared folder is expected at `/portal-data/` (containing the licenseholder shared portal data)
- Our image offers a http service on port 80.
 
Example to run a image, host has our nfs frontend data mount at `/mnt/data/BETA/amak-data/frontend`, portal data at `/mnt/data/BETA/amak-data/portal` and a valid config within `/home/radtke/docker-solid/amak-config`. 
We want to expose the container port 80 on all host interfaces. We create our running instance based on image `amak-nrc-2016-02-19-1200`.
The container is named `nrc-beta`.

    docker run -d -v /mnt/data/BETA/amak-data/frontend:/amak-data -v /mnt/data/BETA/amak-data/portal:/portal-data -v /home/radtke/docker-solid/amak-config:/amak-config -p 0.0.0.0:80:80 --name=nrc-beta amak-nrc-2016-02-19-1200

If you stopped this run, you can simply restart the container by running `docker start nrc-beta`.

Note: The container will apply the configuration (`config.properties`) on each start!
You can clean up stopped containers and images by running 

    docker rm `docker ps --no-trunc -aq`
    docker images --quiet --filter=dangling=true | xargs --no-run-if-empty docker rmi
    
If your version is stable, you should remove the old container by running

    docker rmi --force your-old-image-name

## Jenkins

### The Jenkins Image

The jenkins server image needs the jenkins working directory, which is located on out jenkins server.

To build a current jenkins (or update the jenkins base) simply run `docker pull jenkins`. 
Followed by `docker build -t vrs-jenkins-base ./jenkins`. 
Create a new container 
```
docker create -p 80:8080 -u jenkins \
--restart=unless-stopped \
-v /mnt/data/jenkins/jenkins-data:/var/jenkins_home \
--link amak-firefoxdebug:firefox  \
--link amak-chromedebug:chrome  \
--restart=unless-stopped \
--name vrs-jenkins-NEW-DATE vrs-jenkins-base
```
Stop the old one Stop old instance `docker stop vrs-jenkins-OLD-DATE`. 
Start the new one by running `docker start vrs-jenkins-NEW-DATE`.


### The Jenkins Webdriver Farm

Webdrivers are configured at `/webdriver/composer.json`.

- Firefox (linked as `firefox` within jenkins container) on `78.137.97.99:4440` (VNC: 4441)
- Chrome (linked as `chrome` within jenkins container) on `78.137.97.99:4442` (VNC: 4443)