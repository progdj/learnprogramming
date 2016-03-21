# AMAK Docker Server Environment

Welcome to the AMAK Docker Server Environment. Here you'll find our setup for production systems, based on docker.

- `jenkins` contains the setup for our ci server itself.
- `jenkins-slave` contains the setup for a server which is controlled by jenkins. 

## Jenkins Slave

## Requirements

- A slave should be configured to host a home for user `jenkins`.
- A slave must host a docker service. https://docs.docker.com/engine/installation/linux/
- At jenkins home should be a checkout from `amak-docker` with a symlink named `slave` pointing to checkout `server/jenkins-slave`.
 - like `lrwxrwxrwx 1 jenkins jenkins   47 Feb 29 22:57 slave -> /home/jenkins/amak-docker/server/jenkins-slave/`
- The user jenkins must have a valid ssh configuration, that includes private key and authorized_keys!
- Follow `docker-build.sh` and `environments/README.md` to follow the ci process. 

### Tasks and Setups

- We support 2 ways to create and host containers.
 - Source Code based containers, which are created after a pull from git. This containers are used for testing and development purposes. These containers will use the workflow controlled by `docker-build.sh`.
 - Image based container deployments, which are created out of an image from `docker-build.sh`. The workflow for this deployment is cointrolled by `docker-export.sh` and `docker-import.sh` - or `docker-share.sh`.
- Both ways use the [environment config](jenkins-slave/environments/README.md) logic to define what configuration will be used to host the actual container.

### Production Containers

A production container should be created out of an image from a container that was tested before. 
Doing so ensures that the result of docker build and current package versions are working together, 
as every new build could change versions within the used os or third party libs.
To do so `docker-export.sh` will create docker image tag named `amak-VERSION` based on the `environment` you passed.
If you would pass `develop` as environment the image used to host the current `develop` container would get tagged and exported to a file.

We expect different hosts for develop and production.

`docker-import.sh` will use this file to restore the tag on the foreign host using the passed environment to define which configuration should be used to host the image.

`docker-share.sh` combines all steps needed to `export`, `transfer` and `import` a image from the source server to the actual production server. 
   

### HowTo: create a docker server image (bloody by hand)

- A image can be used to create a running container and might get shared on a hub.
- You'll need all current packages. (`amak-frontend`, `amak-source`, `amak-portal`, `amak-cms`)
 - To obtain a package run `vendor/bin/phing package` within your working copy of `amak-frontend`, `amak-portal` and `amak-cms`.
 - For `amak-source` please run `vendor/bin/phing amak-source-legacy-package`.
 - Copy all files from your working copies folder `dist` to `jenkins-slave/httpd/amak-packages`. (For each application!)
- Now you can build an image, simply run


    docker build -t your-docker-image-tag ./jenkins-slave/httpd/


- Change `your-docker-image-tag` to a tag name, just like `amak-nrc-2016-02-19-1200`…
- Your image is ready to use now.

### HowTo: use a server image (bloody by hand)

- Next step is to create a running container out of the created image.
- First we need to know what requirements our image has:
 - configuration folder is expected at `/amak-config/` (containing the file `config.properties`)
 - data shared folder is expected at `/amak-data/` (containing the licenseholder shared data)
- Our image offers a http service on port 80.
 
Example to run a image, host has our nfs mount at `/mnt/data/BETA/amak-data/frontend` and a valid config within `/home/radtke/docker-solid/amak-config`. 
We want to expose the container port 80 on all host interfaces. We create our running instance based on image `amak-nrc-2016-02-19-1200`.
The container is named `nrc-beta`.

    docker run -d -v /mnt/data/BETA/amak-data/frontend:/amak-data -v /home/radtke/docker-solid/amak-config:/amak-config -p 0.0.0.0:80:80 --name=nrc-beta amak-nrc-2016-02-19-1200

If you stopped this run, you can simply restart the container by running `docker start nrc-beta`.

Note: The container will apply the configuration (`config.properties`) on each start!
You can clean up stopped containers and images by running 

    docker rm `docker ps --no-trunc -aq`
    docker images --quiet --filter=dangling=true | xargs --no-run-if-empty docker rmi
    
If your version is stable, you should remove the old container by running

    docker rmi --force your-old-image-name

## Jenkins

### Image

The jenkins server image needs the jenkins working directory, which is located on out jenkins server.

To build a current jenkins (or update the jenkins base) simply run `docker pull jenkins`. 
Followed by `docker build -t vrs-jenkins-base ./jenkins`. Stop old instance `docker stop vrs-jenkins`.
Start the new one `docker run -d -p 80:8080 -u jenkins -v /mnt/data/jenkins/jenkins-data:/var/jenkins_home --name vrs-jenkins vrs-jenkins-base`.