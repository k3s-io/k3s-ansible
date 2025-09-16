# K3s Test Node - Base image for Docker-based k3s testing
FROM jrei/systemd-ubuntu:noble

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    # SSH for Ansible connectivity
    openssh-server \
    # Container runtime dependencies
    docker.io \
    # K3s dependencies
    curl \
    wget \
    iptables \
    # Network tools
    net-tools \
    iputils-ping \
    netcat-openbsd \
    # Sudo for privilege escalation
    sudo \
    # Clean up
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configure SSH
RUN mkdir /var/run/sshd \
    && mkdir -p /root/.ssh \
    && chmod 700 /root/.ssh \
    && echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config \
    && echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config

# Create ansible user (matching typical Ansible setup)
RUN useradd -m -s /bin/bash ansible \
    && echo 'ansible:ansible' | chpasswd \
    && usermod -aG sudo ansible \
    && mkdir -p /home/ansible/.ssh \
    && chmod 700 /home/ansible/.ssh

# Copy SSH public key for ansible user
COPY keys/k3s.pub /home/ansible/.ssh/authorized_keys
RUN chown -R ansible:ansible /home/ansible/.ssh \
    && chmod 700 /home/ansible/.ssh \
    && chmod 600 /home/ansible/.ssh/authorized_keys

# Enable passwordless sudo for ansible user
RUN mkdir -p /etc/sudoers.d \
    && echo 'ansible ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/ansible

# Configure systemd for container use
RUN systemctl enable ssh \
    && systemctl enable docker

# Expose SSH port
EXPOSE 22