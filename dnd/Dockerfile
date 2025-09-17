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
    python3-pip \
    python3-virtualenv \
    python-is-python3 \
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

RUN cat <<EOF >/etc/systemd/system/nologin-handler.service
[Unit]
Description=Prevent nologin file creation
After=local-fs.target
Before=systemd-user-sessions.service

[Service]
Type=simple
ExecStart=/bin/bash -c 'while true; do rm -f /var/run/nologin; sleep 1; done'
Restart=always
RestartSec=1

[Install]
WantedBy=multi-user.target
EOF

# Configure systemd for container use
RUN systemctl enable ssh \
    && systemctl enable docker \
    && systemctl enable nologin-handler.service

# Expose SSH port
EXPOSE 22

CMD ["/lib/systemd/systemd"]
