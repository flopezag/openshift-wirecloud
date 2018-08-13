# Quick reference

-	**Where to get help**:  
	[the Docker Community Forums](https://forums.docker.com/), [the Docker Community Slack](https://blog.docker.com/2016/11/introducing-docker-community-directory-docker-community-slack/), or [Stack Overflow](https://stackoverflow.com/search?q=fiware-wirecloud)

-	**Where to file issues**:  
	[https://github.com/flopezag/openshift-wirecloud/issues](https://github.com/flopezag/openshift-wirecloud/issues)

-	**Maintained by**:  
	[the FIWARE OpenShift Docker Maintainers](https://github.com/flopezag/openshift-wirecloud)

-	**Source of this description**:  
	[docs OpenShift FIWARE Wirecloud directory](https://github.com/flopezag/openshift-wirecloud/blob/master/doc) ([history](https://github.com/flopezag/openshift-wirecloud/commits/master/doc))

-	**Supported Docker versions**:  
	[the 18.06.0-ce release](https://github.com/docker/docker-ce/releases/tag/v18.06.0-ce) 
	(down to 18.06.0-ce on a best-effort basis)

# What is this FIWARE Wirecloud image

This docker image has been generated in order to be used in OpenShift without any 
kind of privileges or user definition. It is based on the original [Dockerfile](https://github.com/Wirecloud/docker-wirecloud/blob/master/1.1-composable/Dockerfile) 
of the FIWARE Wirecloud component version 1.1 (composable version). For that 
purpose, it is needed to define the corresponding PostgreSQL environment variables
in order to connect to the correct DB instance. 

# How to use this image

## Hosting a simple docker service locally

In order to create the proper image just execute:

```console
docker build -f Dockerfile -t flopez/wirecloud:1.1 $PWD
```

Just the next step is to upload the image to the current repository:

```console
docker push flopez/wirecloud:1.1
```

Alternatively, to run this docker image just execute the following commands:

```console
docker run --name <some container name> \
           -e POSTGRES_DATABASE=<name of the PostgreSQL database> \
           -e POSTGRES_HOSTNAME=<PostgreSQL hostname> \
           -e POSTGRES_PASSWORD=<PostgreSQL user password> \
           -e POSTGRES_USER=<PostgreSQL username> \
           <docker image ID>
```

This will create a container listening on port 8000. Keep in mind that is component
is be be run together with NGINX and PostgreSQL, therefore it not possible to execute
it in standalone process. Take a look to the folder docker-composable to see how to 
configure a docker-compose file to execute an instance of wirecloud.

## OpenShift deployment

It is possible to deploy this docker image inside a OpenShift instance, just 
selecting deploy image and specifying the proper Image Name. In this case,
the value of the Image name or pull spec is **docker.io/flopez/wirecloud:1.1**


### Using environment variables in Wirecloud configuration

There are some environment variables that have to be defined when we deploy this 
image. Here is an example using docker-compose.yml:

```yaml
    wirecloud:
      image: flopez/wirecloud:1.1
      ports:
        - "8000:8000"
      environment:
        - POSTGRES_DATABASE=<name of the PostgreSQL database>
        - POSTGRES_HOSTNAME=<PostgreSQL hostname>
        - POSTGRES_USER<PostgreSQL username>
        - POSTGRES_PASSWORD=<PostgreSQL user password>
```

Keep in miand that these values have to be the same that were defined in the 
installation of the PostgreSQL instance.

Additionally, this component requires the creation of specific volumes in order to
load the static content of the web page together with the space in which we store
the different widgets that we want to use.

````yaml
    wirecloud:
        volumes:
            - ./wirecloud_instance:/opt/wirecloud_instance
            - ./static:/var/www/static
```

# License

View [license information](https://github.com/Wirecloud/wirecloud/blob/develop/LICENSE.txt)
for the software contained in this image.

As with all Docker images, these likely also contain other software which may be under 
other licenses (such as Bash, etc from the base distribution, along with any direct or 
indirect dependencies of the primary software being contained).

As for any pre-built image usage, it is the image user's responsibility to ensure that 
any use of this image complies with any relevant licenses for all software contained 
within.

For the additional configuration content defined in this repo, view license information 
contained in the repository [license information](https://github.com/flopezag/openshift-wirecloud/blob/master/LICENSE).