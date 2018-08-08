FROM python:2-stretch

MAINTAINER Fernando López <fernando.lopez@fiware.org>

WORKDIR /opt

RUN apt-get update && \
    apt-get install -y libmemcached-dev ca-certificates && \
    pip install --no-cache-dir social-auth-app-django "gunicorn==19.3.0" "psycopg2==2.6" pylibmc && \
    rm -rf /var/lib/apt/lists/* && \
    \
    export dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" && \
    wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/1.10/gosu-$dpkgArch" && \
    wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/1.10/gosu-$dpkgArch.asc" && \
    export GNUPGHOME="$(mktemp -d)" && \
    for server in $(shuf -e ha.pool.sks-keyservers.net \
                            hkp://p80.pool.sks-keyservers.net:80 \
                            keyserver.ubuntu.com \
                            hkp://keyserver.ubuntu.com:80 \
                            pgp.mit.edu) ; do \
        gpg --keyserver "$server" --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 && break || : ; \
    done && \
    gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu && \
    rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc && \
    chmod +x /usr/local/bin/gosu && \
    gosu nobody true

RUN pip install "wirecloud<1.2"

# RUN adduser --system --shell /bin/bash --ingroup root wirecloud && \
#     pip install --no-cache-dir channels asgi_ipc asgi_redis asgi_rabbitmq && \
#     wirecloud-admin startproject wirecloud_instance && \
#     chown -R wirecloud:root wirecloud_instance && \
#     chmod a+x wirecloud_instance/manage.py
RUN pip install --no-cache-dir channels asgi_ipc asgi_redis asgi_rabbitmq && \
    wirecloud-admin startproject wirecloud_instance && \
    chmod a+x wirecloud_instance/manage.py


WORKDIR /opt/wirecloud_instance

RUN sed -i "s/'ENGINE': 'django.db.backends.'/'ENGINE': 'django.db.backends.postgresql_psycopg2'/g" wirecloud_instance/settings.py && \
    sed -i "s/'NAME': ''/'NAME': '$POSTGRES_DATABASE'/g" wirecloud_instance/settings.py; \
    sed -i "s/'USER': ''/'USER': '$POSTGRES_USER'/g" wirecloud_instance/settings.py; \
    sed -i "s/'PASSWORD': ''/'PASSWORD': '$POSTGRES_PASSWORD'/g" wirecloud_instance/settings.py; \
    sed -i "s/'HOST': ''/'HOST': '$POSTGRES_HOSTNAME'/g" wirecloud_instance/settings.py; \
    sed -i "s/'PORT': ''/'PORT': '5432'/g" wirecloud_instance/settings.py && \
    sed -i "s/SECRET_KEY = '[^']\+'/SECRET_KEY = 'TOCHANGE_SECRET_KEY'/g" wirecloud_instance/settings.py && \
    sed -i "s/STATIC_ROOT = path.join(BASEDIR, '..\/static')/STATIC_ROOT = '\/var\/www\/static'/g" wirecloud_instance/settings.py

# RUN python manage.py collectstatic --noinput && \
#    chown -R wirecloud:root /var/www/static
RUN python manage.py collectstatic --noinput

# volumes must be created after running the collectstatic command
VOLUME /var/www/static
VOLUME /opt/wirecloud_instance

EXPOSE 8000

COPY ./docker-entrypoint.sh /
COPY ./manage.py /usr/local/bin/

RUN chmod -R 777 /opt
RUN chmod 777 /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
