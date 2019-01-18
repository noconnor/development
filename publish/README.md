# Publish scripts

Utility scripts to help publish new `docker` or `vagrant` development environments.

<br />

## Usage

The following table describes the available publish script options:

| Configuration           | Description                                                                                                                                                                                                                                                                                                                                                                               | Default |
|------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------|
| `--runtime`      | Currently supported runtime's are `vagrant` or `docker`.<br />If `docker` is specified a `docker` container will be published.<br />If `vagrant` is chosen, a new vagrant vm will be built and published  | vagrant |
| `--image`        | The image you would like to build and publish.<br />This image should match a script in the [provisioners directory](provisioners/)                                                                       | None    |

<br />

**Example Usage:**
```
# Build and publish a docker container based on the provision script provisioners/python3.centos.provision.sh
./publish --runtime docker --image python3.centos

# Build and publish a vagrant vm based on the provision script provisioners/react.centos.provision.sh
./publish --runtime vagrant --image react.centos

```

<br />

## Adding a new docker image OR vagrant vm

To add a new **docker** image:

* Add a new provisioner script to the provisioners directory
* Ensure the new script has the `DOCKER_BASE` and `DOCKER_EXPOSE` headers set (see [react.centos.provision.sh](provisioners/react.centos.provision.sh) for an example)

That should be it, next step would be to run the publish script to make docker image available

<br />

To add a new **vagrant** image:

* Add a new provisioner script to the provisioners directory
* Ensure the new script has the `VAGRANT_BASE` headers set (see [react.centos.provision.sh](provisioners/react.centos.provision.sh) for an example)
* If needed add a new Vagrant file to the [vagrant directory](../vagrant/) (see [react.centos.Vagrantfile](../vagrant/react.centos.Vagrantfile) for an example)

That should be it, next step would be to run the publish script to make vagrant image available.

