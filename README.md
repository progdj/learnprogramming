# AMAK Docker Environment

This project aims at providing a docker based development environment for the AMAK project.
If you're not familiar with Docker, take a look at their [Website](https://www.docker.io) or directly
head over to the [Documentation](https://docs.docker.com/) and gain even deeper understanding on how to use it.

## Installation
###1. Install Docker Toolbox
When using OS X: additionally install [Docker Machine NFS](https://github.com/adlogix/docker-machine-nfs)

###2. Create a new Docker VM
OS X: Apply NFS-Mount after creation: **docker-machine-nfs**

###3. Copy AMAK into app
Copy the AMAK repositories to the `app` directory. It should then be listing
 - **app/**
    - **amak-frontend**/...
    - **amak-source**/...
 - **db/**
    - ...
 - **httpd/**
    - ...
 - **docker-compose.yml**

###4. Start the environment
```shell
$ cd ~/Workspace/PHP/amak-docker
$ docker-compose up
```

##Usage
The **app/** directory is mounted within your Docker VM and thus leads to every file being instantly deployed.