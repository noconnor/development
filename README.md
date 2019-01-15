# Development

Development environment setup scripts

<br />

## Environments

* `react` - React application development environment containing `node 8`
* `robot` - Development environment with `robotframework` and `python3` pre-installed

<br />

## Usage

Choose a target development environment (see [Environments](#environments) above) and execute the follow command

```
# replace <TARGET> with actual target env
curl -o- https://raw.githubusercontent.com/noconnor/development/master/install.sh | bash -s <TARGET>

# i.e. to install a robotframework dev env
curl -o- https://raw.githubusercontent.com/noconnor/development/master/install.sh | bash -s robot
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

### Installing ruby with brew
```
brew install ruby

# add the following to ~/.bash_profile
eval "$(rbenv init -)" >> ~/.bash_profile
export PATH="/usr/local/opt/ruby/bin:$PATH" >> ~/.bash_profile
export PATH="/usr/local/lib/ruby/gems/2.6.0/bin:$PATH"
```
