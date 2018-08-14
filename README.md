# OpenShift FIWARE Wirecloud docker image
[![License badge](https://img.shields.io/badge/license-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

Dockerfile description and OpenShift configuration file of the [FIWARE Wirecloud](https://github.com/Wirecloud/wirecloud)
enabler in order to create a docker image and deploy a corresponding service instance in 
an OpenShift environment.

## Create the Docker Image

The first steps is to login inside the docker system through the execution of
the command:

```console
docker login
```

In order to create the proper image you need to have installed docker engine.
The first command is used to generate the docker image from the defined Dockerfile.

```console
docker build -f Dockerfile -t flopez/wirecloud:1.1 .
```

It creates the corresponding docker image tagged with flopez/wirecloud. Currently, 
the only version that was supported and generated is the 1.1. Down versions to 1.1 
are on a best-effort basis. The next step is upload the image into a repository 
(in our case [Docker Hub](https://hub.docker.com/)).

```console
docker push flopez/wirecloud:1.1
```


## OpenShift deployment

To start to work with OpenShift, you need to be registered in the corresponding 
environment. Just execute the following command:

```console
oc login <OpenShift server>
```

This command will request you the username and password to access to the proper 
OpenShift environment. Now, to deploy a new application, the first step is the 
creation of the proper application in the OpenShift environment. Just execute 
the command:

```console
oc new-app -e POSTGRES_DATABASE=<name of the PostgreSQL database> \
           -e POSTGRES_HOSTNAME=<PostgreSQL hostname> \
           -e POSTGRES_PASSWORD=<PostgreSQL user password> \
           -e POSTGRES_USER=<PostgreSQL username> \
           flopez/wirecloud:1.1 \
           --name wirecloud \
           -o yaml > wirecloud.yaml
```

Keep in mind that it is needed to specify the postgresql server hostname inside 
the OpenShift environment in order to know to which DB should be connected the 
Wirecloud instance. The docker image flopez/wirecloud is deployed publicly
in [Hub Docker public repository](https://hub.docker.com/r/flopez/wirecloud/). This 
operation will create the definition of the new application *wirecloud* with the 
corresponding yaml description file. We do not use this created description file 
but the one that we provided, due to we need to edit the content. You can compare 
the generated description application with the content inside the 
[config folder](https://github.com/flopezag/openshift-wirecloud/config) 
to see the differences. Finally, keep in mind that in OpenShift the hostname of 
the different services follow the next format:

```text
<service name>.<project name>.svc
```

Furthermore, to deploy our *wirecloud* application just execute the corresponding 
command:

```console
oc create -f config/
```

Last but not least, if we want to delete completely all the resources generated 
with these configuration files, just execute the corresponding command, specifying 
the name of the application that was created in the execution of the ```oc new-app``` 
command:

```console
oc delete all -l app=wirecloud
```

## Docker Compose deployment

The [docker-compose folder](https://github.com/flopezag/openshift-wirecloud/config)
provides you the corresponding docker-compose description file in order to deploy
a complete instance of FIWARE Wirecloud using docker-compose. Just execute the 
command with the proper definition of the postgreSQL DB environment variables:

```console
docker-compose up -d
```

## License

These scripts are licensed under Apache License 2.0.
