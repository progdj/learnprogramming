# AMAK Docker Environment

This project aims at providing a docker based development environment for the AMAK project.
If you're not familiar with Docker, take a look at their [Website](https://www.docker.io) or directly
head over to the [Documentation](https://docs.docker.com/) and gain even deeper understanding on how to use it.

## Installation
### 1. Install Docker Toolbox
When using OS X: additionally install [Docker Machine NFS](https://github.com/adlogix/docker-machine-nfs)

### 2. Create a new Docker VM
OS X: Apply NFS-Mount after creation: **docker-machine-nfs**

### 3. Start the environment
```shell
$ cd ~/Workspace/PHP/amak-docker
$ docker-compose up
```

## Usage
### 1. Locate the Container
To access the Container, you first need to get its IP address. Open up a terminal or that ridiculous command line thing
on Windows and type: `docker-machine ip default`.

You later need to bind this IP address with all the projects URLs in your `hosts` file. First of all open that address
in your browser. It should then show you some further instructions on how to proceed with your deployment setup.

### 2. Configure the Deployment
Your browser should be showing a detailed instruction. That document can also be found in the `app/default` directory.

### 3. Database Import
After you set up your deployment, you need to import the database. Start your SQL client of choice and connect to your
container using its ip and **root** for both, the username and the password. There is already a **amak** database, that's
been set up to fulfill the requirements for a complete SQL dump.

### 4. Project initialisation
- composer install
- npm i
- grunt deploy

## Things to consider
Since this project will be filled up with **amak-frontend** and **amak-source**, remember to **not add them to the VCS!**
It is hereby recommended to deploy this project locally in order to not let that stuff slip into your workspace.