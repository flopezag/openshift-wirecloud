# OpenShift FIWARE Knowage docker image
[![License badge](https://img.shields.io/badge/license-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

Dockerfile description of the FIWARE Knowage component in order to install in OpenShift

## Create the Docker Image

In order to create the proper image you need to have installed docker engine.
The first command is used to generate the docker image from the defined Dockerfile.

```
docker build -f Dockerfile -t flopez/knowage .
```

It creates the corresponding docker image tagged with flopez/knowage. The next step is
upload the image into a repository (in our case [Docker Hub](https://hub.docker.com/)).
We need to login into our user:

```
docker login
```

And them push the new created image into our repository

```
docker push flopez/knowage:latest
```

## OpenShift deployment

In order to deploy this image, just select the image name

```
docker.io/flopez/knowage:latest
```

And write the proper environment variable with the hostname of the Wirecloud service 
in order to use properly the component.

```
POSTGRES_HOSTNAME = <MySQL Database>
POSTGRES_USER = <MySQL user>
POSTGRES_PASSWORD = <MySQL password>
POSTGRES_DATABASE = <MySQL TCP address, hostname of the service>
```

Keep in mind that in OpenShift the hostname has the format:

```
<service name>.<project name>.svc
```

## License

These scripts are licensed under Apache License 2.0.
