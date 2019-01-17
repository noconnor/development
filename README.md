# Development

Development environment setup scripts.

* [Environments](#environments) - Available development environments
* [Docker usage](#usage:-docker) - How to install a docker based development environment
* [Vagrant usage](#usage:-vagrant) - How to install a vagrant based development environment

<br />

## Environments

Available development environments:

* `react` - React application development environment containing `node 8`
* `robot` - Development environment with `robotframework` and `python3` pre-installed


Available OS's:

* `centos` - Centos 7


<br />

## Usage: Docker

Choose a target development environment (see [Environments](#environments) above) and execute the follow command

```
# replace <TARGET_ENV> with actual target env and TARGET_OS with actual os
curl -o- https://raw.githubusercontent.com/noconnor/development/master/install/docker.sh | bash -s -- <TARGET_ENV> <TARGET_OS>

# i.e. to install a robotframework docker dev env
curl -o- https://raw.githubusercontent.com/noconnor/development/master/install/docker.sh | bash -s -- robot centos
```


This install script will:

* Install `docker`
    * If run on Mac OSX, [docker-machine](https://docs.docker.com/machine/), [virtualbox](https://www.virtualbox.org/) and [docker-sync](http://docker-sync.io/) will also be installed
    * [Homebrew](https://brew.sh/) is a prerequisite for Mac OSX
* Download a `Dockerfile` for the target development environment (see [docker](docker/) directory)
* Generate an OS specific start script for your target environment (see generated `start.sh` script)


When the `start.sh` script is run, the current directory will be mounted into the docker container (see `/home/workspace` inside the docker container)
and an interactive shell session will be started.

This mounted path will be kept in sync with the host environment (for Mac OSX see generated `docker-sync.yml` file for sync details).

<br /> 


## Usage: Vagrant

To pre-provisioned vagrant manager vm, choose a target environment and run:  

```
curl -o- https://raw.githubusercontent.com/noconnor/development/master/install/vagrant.sh | bash -s -- <TARGET_ENV> <TARGET_OS>

# i.e. to install a react dev env running centos
curl -o- https://raw.githubusercontent.com/noconnor/development/master/install/vagrant.sh | bash -s -- react centos

```

This script will:

* Install `vagrant`
* Download a `Vagrantfile` for the target development environment (see [vagrant](vagrant/) directory)
* Provision a vagrant managed box with target development environment installed

The directory in which the install command was executed will be mounted inside the vagrant VM 

<br />
