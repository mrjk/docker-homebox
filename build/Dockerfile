
# Base image
####################################

FROM debian:13 AS debian_base

# Install base packages
RUN apt-get update && apt-get install -y \
    dialog \
    locales \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN localedef -i en_US -f UTF-8 en_US.UTF-8

# Install required packages
RUN apt-get update && apt-get install -y \
    gnupg \
    ca-certificates \
    curl \
    wget \
    vim \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


# Base packages
####################################
FROM debian_base AS debian_pkgs

RUN apt-get update && apt-get install -y \
    openssh-server \
    rsync \
    sudo \
    net-tools \
    build-essential \
    procps \
    iproute2 \
    iputils-ping \
    file \
    git \
    screen \
    ncdu \
    iftop \
    htop \
    info \
    man \
    tree \
    nmap \
    telnet \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Backup openssh config
RUN mkdir -p /usr/local/include/confs/ && \
  cp -a /etc/ssh/ /usr/local/include/confs/ssh
  

# Fix broken SSH install ...
#RUN apt-get -o Dpkg::Options::="--force-confask" install --reinstall openssh-server
# Other useful: man info telnet nmap


# Custom configuration
####################################
FROM debian_pkgs AS debian_user

# Manage init system
RUN apt-get update && apt-get install -y \
    supervisor \
    tini \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Run build scripts
COPY ./build_scripts /usr/local/build

RUN /usr/local/build/install_docker.sh
RUN /usr/local/build/install_mise.sh
RUN /usr/local/build/install_oh-my-bash.sh

# Copy init scripts
COPY ./init /usr/local/init

ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/init/minit.sh"]

