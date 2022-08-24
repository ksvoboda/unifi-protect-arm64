FROM arm64v8/ubuntu:xenial

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get -y --no-install-recommends install \
        curl \
        wget \
        mount \
        psmisc \
        dpkg \
        apt \
        lsb-release \
        sudo \
        gnupg \
        apt-transport-https \
        ca-certificates \
        dirmngr \
        mdadm \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sL https://deb.nodesource.com/setup_16.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
    && apt-get -y --no-install-recommends install systemd \
    && find /etc/systemd/system \
        /lib/systemd/system \
        -path '*.wants/*' \
        -not -name '*journald*' \
        -not -name '*systemd-tmpfiles*' \
        -not -name '*systemd-user-sessions*' \
        -exec rm \{} \; \
    && rm -rf /var/lib/apt/lists/*
STOPSIGNAL SIGKILL

RUN rm /etc/apt/sources.list

RUN touch /etc/apt/sources.list

RUN apt-get update

# RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

# RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ bionic-pgdg main' > /etc/apt/sources.list.d/postgresql-pgdg.list
# RUN echo 'deb [trusted=yes] http://ftp.de.debian.org/debian sid main ' > /etc/apt/sources.list
# RUN echo 'deb [trusted=yes] http://security.debian.org/debian-security stretch/updates main' > /etc/apt/sources.list
# RUN echo 'deb [trusted=yes] http://ftp.de.debian.org/debian sid main' > /etc/apt/sources.list

RUN echo 'deb [trusted=yes] https://deb.nodesource.com/node_16.x bullseye main' > /etc/apt/sources.list

RUN echo 'deb-src [trusted=yes] https://deb.nodesource.com/node_16.x bullseye main' > /etc/apt/sources.list

RUN echo 'deb [trusted=yes] http://archive.raspberrypi.org/debian/ bullseye main' > /etc/apt/sources.list

RUN echo 'deb-src [trusted=yes] http://archive.raspberrypi.org/debian/ bullseye main' > /etc/apt/sources.list

RUN echo 'deb [trusted=yes] https://apt.artifacts.ui.com stretch main release' > /etc/apt/sources.list

RUN echo 'deb [trusted=yes] http://security.debian.org/debian-security stretch/updates main' > /etc/apt/sources.list

RUN echo 'deb [trusted=yes] http://ftp.de.debian.org/debian stretch main' > /etc/apt/sources.list

RUN apt-get update

#RUN apt-get install -y ssl-cert libedit2 sysstat ucf logrotate

#RUN wget https://apt.postgresql.org/pub/repos/apt/pool/main/p/postgresql-9.6/postgresql-9.6_9.6.24-1.pgdg18.04+1_arm64.deb

#RUN dpkg -i /postgresql-9.6_9.6.24-1.pgdg18.04+1_arm64.deb

RUN apt-get -y --allow-unauthenticated install postgresql=9.6+181+deb9u3 \
    && sed -i 's/peer/trust/g' /etc/postgresql/9.6/main/pg_hba.conf \
    && rm -rfv /var/lib/apt/lists/*

#RUN apt-get clean && apt-get update

COPY put-deb-files-here/*.deb files/postgresql.sh /

COPY put-version-file-here/version /usr/lib/version

RUN dpkg -i /ubnt-archive-keyring_*_arm64.deb \
    && echo 'deb https://apt.artifacts.ui.com stretch main release' > /etc/apt/sources.list.d/ubiquiti.list \
    && chmod 666 /etc/apt/sources.list.d/ubiquiti.list \
    && apt-get update 

RUN apt-get install -f

RUN apt-get install -y ulp-go

RUN apt install -y --no-install-recommends /*.deb \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean && apt-get update

RUN echo 'deb [trusted=yes] http://ftp.de.debian.org/debian stretch main' > /etc/apt/sources.list

RUN apt-get update

RUN apt-get install -y --no-install-recommends libstdc++6=6.3.0-18+deb9u1

RUN apt-get install -y --no-install-recommends ubnt-opencv4-libs

RUN apt-get -y --no-install-recommends install unifi-protect \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean && apt-get update 

RUN /postgresql.sh \
    && rm /postgresql.sh 

RUN echo "exit 0" > /usr/sbin/policy-rc.d \
    && sed -i "s/Requires=network.target postgresql-cluster@9.6-main.service ulp-go.service/Requires=network.target postgresql-cluster@9.6-main.service/" /lib/systemd/system/unifi-core.service \
    && sed -i 's/redirectHostname: unifi//' /usr/share/unifi-core/app/config/config.yaml

COPY files/ubnt-tools /sbin/ubnt-tools

VOLUME ["/srv", "/data"]

CMD ["/lib/systemd/systemd"]
