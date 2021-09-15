# Preparation

If you don't already have a SSH key please create a ssh key pair using `ssh-keygen`

## Internal IP Ranges setup

- 10.0.0.1: Load Balancer internal floating IP
- 10.0.0.2 - 10.0.0.254: reserved for static IP addresses (e.g. Load Balancer)
- 10.0.1.1 - 10.0.1.254: reserved for K3S services of type LoadBalancer
- 10.0.2.1 - 10.0.254.254: DHCP range
