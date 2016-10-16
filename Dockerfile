FROM centos:centos7
MAINTAINER SoftwareCollections.org <sclorg@redhat.com>

# MongoDB image for OpenShift.
#
# Volumes:
#  * /var/lib/mongodb/data - Datastore for MongoDB
# Environment:
#  * $MONGODB_USER - Database user name
#  * $MONGODB_PASSWORD - User's password
#  * $MONGODB_DATABASE - Name of the database to create
#  * $MONGODB_ADMIN_PASSWORD - Password of the MongoDB Admin

ENV MONGODB_VERSION=3.2 \
    HOME=/var/lib/mongodb

LABEL microlib.description="MongoDB is a scalable, high-performance, open source NoSQL database." \
      microlib.display-name="MongoDB 3.2" 

EXPOSE 27017

# Due to the https://bugzilla.redhat.com/show_bug.cgi?id=1206151,
# the whole /var/lib/mongodb/ dir has to be chown-ed.
RUN yum install -y centos-release-scl-rh && \
    yum-config-manager --enable centos-sclo-rh-testing && \
    INSTALL_PKGS="bind-utils gettext iproute rsync tar rh-mongodb32-mongodb rh-mongodb32" && \
    yum install -y --setopt=tsflags=nodocs $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    yum clean all && \
    mkdir -p /var/lib/mongodb/data && chown -R mongodb.0 /var/lib/mongodb/ /var/opt/rh/rh-mongodb32/lib/mongodb && \
    # Loosen permission bits to avoid problems running container with arbitrary UID
    chmod g+w -R /var/opt/rh/rh-mongodb32/lib/mongodb && \
    chmod -R g+rwx /var/lib/mongodb

# Get prefix path and path to scripts rather than hard-code them in scripts
ENV CONTAINER_SCRIPTS_PATH=/usr/share/container-scripts/mongodb \
    MONGODB_PREFIX=/opt/rh/rh-mongodb32/root/usr \
    ENABLED_COLLECTIONS=rh-mongodb32

# When bash is started non-interactively, to run a shell script, for example it
# looks for this variable and source the content of this file. This will enable
# the SCL for all scripts without need to do 'scl enable'.
ENV BASH_ENV=${CONTAINER_SCRIPTS_PATH}/scl_enable \
    ENV=${CONTAINER_SCRIPTS_PATH}/scl_enable \
    PROMPT_COMMAND=". ${CONTAINER_SCRIPTS_PATH}/scl_enable"

ADD root /

# Container setup
RUN touch /etc/mongod.conf && chown mongodb:0 /etc/mongod.conf && /usr/libexec/fix-permissions /etc/mongod.conf

VOLUME ["/var/lib/mongodb/data"]

USER 184

ENTRYPOINT ["container-entrypoint"]
CMD ["run-mongod"]
