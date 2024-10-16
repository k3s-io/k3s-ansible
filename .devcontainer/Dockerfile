FROM mcr.microsoft.com/devcontainers/python:1-3.12

USER root

RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && mv ./kubectl /usr/local/bin/kubectl && chmod +x /usr/local/bin/kubectl

RUN apt-get update && apt-get install -y vim

USER vscode


