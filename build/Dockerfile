FROM debian:13

# Install base packages
RUN apt-get update && apt-get install -y \
    tini \
    dialog \
    locales \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN localedef -i en_US -f UTF-8 en_US.UTF-8

RUN apt-get update && apt-get install -y \
    net-tools \
    procps \
    iproute2 \
    iputils-ping \
    ca-certificates \
    curl \
    wget \
    file \
    vim \
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

# Other useful: man info telnet nmap

# Install required packages
RUN apt-get update && apt-get install -y \
    openssh-server \
    rsync \
    sudo \
    gnupg \
    build-essential \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Fix broken SSH install ...
#RUN apt-get -o Dpkg::Options::="--force-confask" install --reinstall openssh-server


# Build arguments
ARG app_username=appuser
ARG app_user_id=1000
ARG app_group_id=1000

# Create user with specified UID/GID
RUN groupadd -g ${app_group_id} ${app_username} && \
    useradd -m -u ${app_user_id} -g ${app_group_id} -s /bin/bash ${app_username}

# Configure sudo for the user
RUN echo "${app_username} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${app_username} && \
    chmod 0440 /etc/sudoers.d/${app_username}

# Create necessary directories
RUN mkdir -p /var/run/sshd /scripts /mnt && \
    chmod 755 /var/run/sshd


# Copy entrypoint script
COPY build/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Dynamic APPS: docker client with compose
RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg \
      | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    chmod a+r /etc/apt/keyrings/docker.gpg
RUN echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/debian trixie stable" \
    > /etc/apt/sources.list.d/docker.list
RUN apt-get update && apt-get install -y \
    docker-ce-cli \
    docker-compose-plugin \
    && rm -rf /var/lib/apt/lists/*


# Dynamic scripts
WORKDIR /home/$app_username
COPY build/scripts/build_* /scripts/
RUN /scripts/build_root.sh
USER $app_username
RUN /scripts/build_user.sh
USER root

# Expose SSH port
EXPOSE 22

# Set entrypoint

COPY build/scripts/init_* /scripts/

#ENTRYPOINT ["/entrypoint.sh"]
ENTRYPOINT ["/usr/bin/tini", "--", "/entrypoint.sh"]

