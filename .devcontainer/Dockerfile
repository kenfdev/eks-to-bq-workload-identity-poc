FROM mcr.microsoft.com/devcontainers/typescript-node:0-18

# Install kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
RUN chmod +x ./kubectl
RUN mv ./kubectl /usr/local/bin

# Install kops
RUN curl --silent --location "https://github.com/kubernetes/kops/releases/download/$(curl --silent --location https://storage.googleapis.com/kubernetes-release/release/stable.txt)/kops-linux-amd64" -o /usr/local/bin/kops
RUN chmod +x /usr/local/bin/kops

# Install eksctl
RUN curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
RUN mv /tmp/eksctl /usr/local/bin
