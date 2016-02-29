# AMAK Docker Server Environment

Welcome to the AMAK Docker Server Environment. Here you'll find our setup for production systems, based on docker.

- `jenkins` contains the setup for our ci server itself.
- `jenkins-slave` contains the setup for a server which is controlled by jenkins. 

## Jenkins Slave

### HowTo: create a docker server image

- A image can be used to create a running container and might get shared on a hub.
- You'll need all current packages. (`amak-frontend`, `amak-source`, `amak-portal`, `amak-cms`)
 - To obtain a package run `vendor/bin/phing package` within your working copy of `amak-frontend`, `amak-portal` and `amak-cms`.
 - For `amak-source` please run `vendor/bin/phing amak-source-legacy-package`.
 - Copy all files from your working copies folder `dist` to `jenkins-slave/httpd/amak-packages`. (For each application!)
- Now you can build an image, simply run


    docker build -t your-docker-image-tag ./jenkins-slave/httpd/


- Change `your-docker-image-tag` to a tag name, just like `amak-nrc-2016-02-19-1200`…
- Your image is ready to use now.

### HowTo: use a server image

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