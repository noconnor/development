# Development

Development environment setup scripts.

Repo contains scripts to install [`vagrant`](https://www.vagrantup.com/) and [`docker`](https://www.docker.com/) based development environments.

<br />

## Usage

The following table describes the available install script options:

| Configuration Option           | Description                                                                                                                                                                                                                                                                                                                                                                               | Default |
|------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------|
| `--framework`    | Install a framework to the host machine.<br />Currently supported options are `vagrant` or `docker`.                                                                                                                                                                                                                                                                                      | None    |
| `--runtime`      | Currently supported runtime's are `vagrant` or `docker`.<br />If `docker` is specified a docker container containing the target development environment will be installed to the host machine.<br />If `vagrant` is chosen, the development environment will be a  vagrant managed vm.                                                                                                    | vagrant |
| `--image`        | The image you would like your development environment to be based on.<br />Some example `vagrant` options can be found [here](https://app.vagrantup.com/noconnorie/).<br />Some docker examples can be found [here](https://hub.docker.com/u/noconnorie).<br /><br />**NOTE:** Drop the repository when specifying the image name, so `noconnorie/python3.centos` would be `python3.centos` | None    |

<br />

**Example Usage:**
```

export INSTALL=https://raw.githubusercontent.com/noconnor/development/master/install.sh

# Install docker
curl -o- "${INSTALL}" | bash -s -- --framework docker

# Install vagrant
curl -o- "${INSTALL}" | bash -s -- --framework vagrant

# Install a vagrant centos development environment with python 3 pre-installed
curl -o- "${INSTALL}" | bash -s -- --runtime vagrant --image python3.centos

# Install a docker centos development environment with node pre-installed
curl -o- "${INSTALL}" | bash -s -- --runtime docker --image react.centos

```


<br />
