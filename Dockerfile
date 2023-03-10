FROM debian:11 as build

RUN apt-get update
# Adapted https://github.com/signalwire/freeswitch/blob/v1.10.9/docker/examples/Debian11/Dockerfile#L12
RUN apt-get -yq install \
    git build-essential flex bison make pkg-config libncurses5-dev m4 \
    postgresql-client \
    # gcc bison flex make sed tr \
# TLS support
    libssl-dev \
# SCTP support
    libsctp-dev \
# mysql support
    default-libmysqlclient-dev zlib1g-dev \
# postgres support
    libpq-dev  \
# unixodbc DB support
    unixodbc-dev \
# jabber gateway support (the jabber module) or the XMPP gateway support
    libexpat1-dev \
# the cpl_c (Call Processing Language) or the presence modules (presence and pua*)
    libxml2 \
# XML-RPC support
    libxmlrpc-core-c3-dev \
# perl module
    libperl-dev \
# LDAP support
    libldap-dev \
# carrierroute module
    libconfuse-dev

ARG OPENSIPS_REPO=https://github.com/OpenSIPS/opensips
ARG OPENSIPS_REVISION=2.4.11
RUN mkdir -p /usr/src/opensips && \
    cd /usr/src/opensips && \
    git init && \
    git remote add origin ${OPENSIPS_REPO} && \
    git fetch --depth 1 origin ${OPENSIPS_REVISION} && \
    git reset --hard FETCH_HEAD

WORKDIR /usr/src/opensips
RUN mkdir -p /usr/build/prefix && \
    make opensips modules prefix= include_modules=db_postgres && \
    make install basedir=/usr/build/prefix prefix= include_modules=db_postgres
ADD create-min-root.sh .
RUN ./create-min-root.sh

FROM busybox:glibc

COPY --from=build /root/min-root.tar.gz .
RUN tar xzvf min-root.tar.gz && rm min-root.tar.gz
CMD ["opensips", "-FE"]