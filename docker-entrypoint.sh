#!/bin/bash

# echo $POSTGRES_HOSTNAME

# Wait DB to be accepting requests
# exec 8<>/dev/tcp/$(POSTGRES_HOSTNAME)/5432
# DB_STATUS=$?

# i=0

# while [[ ${DB_STATUS} -ne 0 && ${i} -lt 50 ]]; do
#     sleep 5
#     exec 8<>/dev/tcp/$(POSTGRES_HOSTNAME)/5432
#     DB_STATUS=$?
#
#     i=${i}+1
# done

# Check if we have to init wirecloud configuration
if [ ! -f /opt/wirecloud_instance/wirecloud_instance/settings.py ]; then

    cd /opt

    # Use the target_directory parameter to indicate that we want to use that
    # directory even if it exit
    wirecloud-admin startproject wirecloud_instance wirecloud_instance
    # chown -R wirecloud:wirecloud wirecloud_instance; \
    chmod a+x wirecloud_instance/manage.py

    cd /opt/wirecloud_instance

    sed -i "s/'ENGINE': 'django.db.backends.'/'ENGINE': 'django.db.backends.postgresql_psycopg2'/g" wirecloud_instance/settings.py; \
    sed -i "s/'NAME': ''/'NAME': '$POSTGRES_DATABASE'/g" wirecloud_instance/settings.py; \
    sed -i "s/'USER': ''/'USER': '$POSTGRES_USER'/g" wirecloud_instance/settings.py; \
    sed -i "s/'PASSWORD': ''/'PASSWORD': '$POSTGRES_PASSWORD'/g" wirecloud_instance/settings.py; \
    sed -i "s/'HOST': ''/'HOST': '$POSTGRES_HOSTNAME'/g" wirecloud_instance/settings.py; \
    sed -i "s/'PORT': ''/'PORT': '5432'/g" wirecloud_instance/settings.py; \
    sed -i "s/SECRET_KEY = '[^']\+'/SECRET_KEY = '$(python -c "from django.utils.crypto import get_random_string; import re; print(re.escape(get_random_string(50, 'abcdefghijklmnopqrstuvwxyz0123456789%^&*(-_=+)')))")'/g" wirecloud_instance/settings.py; \
    sed -i "s/STATIC_ROOT = path.join(BASEDIR, '..\/static')/STATIC_ROOT = '\/var\/www\/static'/g" wirecloud_instance/settings.py

    python manage.py collectstatic --noinput; \
    # chown -R wirecloud:wirecloud /var/www/static

    python manage.py migrate --fake-initial
    # su wirecloud -c "python manage.py populate"
    python manage.py populate
fi

# allow the container to be started with `--user`
# if [ "$(id -u)" = '0' ]; then
# 	chown -R wirecloud .
# 	chown -R wirecloud /var/www/static
# fi

# Real entry point
case "$1" in
    initdb)
        python manage.py migrate --fake-initial
        # su wirecloud -c "python manage.py populate"
        python manage.py populate
        ;;
    createdefaultsuperuser)
        echo "from django.contrib.auth.models import User; User.objects.create_superuser('admin', 'admin@example.com', 'admin')" | python manage.py shell > /dev/null
        ;;
    createsuperuser)
        python manage.py createsuperuser
        ;;
    *)
        # su wirecloud -c "/usr/local/bin/gunicorn wirecloud_instance.wsgi:application -w 2 -b :8000"
        /usr/local/bin/gunicorn wirecloud_instance.wsgi:application -w 2 -b :8000
        ;;
esac
