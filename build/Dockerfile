
# Base image
####################################

FROM debian:13 AS debian_base

# Install base packages
RUN apt-get update && apt-get install -y \
    dialog \
    locales \
    tini \
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

# User configuration
####################################
FROM debian_pkgs AS debian_user

# Build arguments
ARG app_username=appuser
ARG app_user_id=1000
ARG app_group_id=1000

ENV HOMEBOX_USER=$app_username
ENV HOMEBOX_USER_UID=$app_user_id
ENV HOMEBOX_USER_GID=$app_group_id

# Create user with specified UID/GID
RUN groupadd -g ${app_group_id} ${app_username} && \
    useradd -m -u ${app_user_id} -g ${app_group_id} -s /bin/bash ${app_username}

# Configure sudo for the user
RUN echo "${app_username} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${app_username} && \
    chmod 0440 /etc/sudoers.d/${app_username}

# Create necessary directories for sshd
RUN mkdir -p /var/run/sshd && \
    chmod 755 /var/run/sshd



# Custom configuration
####################################
FROM debian_user AS debian_custom

# Run build scripts
COPY build/build_scripts /usr/local/build

RUN /usr/local/build/install_docker.sh
RUN /usr/local/build/install_mise.sh
RUN /usr/local/build/install_oh-my-bash.sh

# Copy init scripts
COPY build/init /usr/local/init


# Copy entrypoint script
#COPY build/entrypoint.sh /entrypoint.sh
#RUN chmod +x /entrypoint.sh


# Dynamic scripts
WORKDIR /home/$app_username
#COPY build/scripts/build_* /scripts/
#RUN /scripts/build_root.sh
#USER $app_username
#RUN /scripts/build_user.sh
#USER root

# Expose SSH port
EXPOSE 22

# Set entrypoint

#COPY build/scripts/init_* /scripts/

#ENTRYPOINT ["/entrypoint.sh"]
ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/init/entrypoint.sh"]

