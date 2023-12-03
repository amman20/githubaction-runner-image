FROM ubuntu:latest

ARG REPO_URL
ARG TOKEN
ARG ARCH=linux-arm64

# Install github action self-runner
RUN mkdir -p /home/ubuntu/actions-runner
WORKDIR /home/ubuntu/actions-runner

RUN apt update && apt install -y curl unzip libdigest-sha-perl supervisor unzip sudo
COPY ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY ./entry_point.sh .

RUN curl -o actions-runner-linux-arm64-2.311.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-${ARCH}-2.311.0.tar.gz
RUN echo "5d13b77e0aa5306b6c03e234ad1da4d9c6aa7831d26fd7e37a3656e77153611e  actions-runner-${ARCH}-2.311.0.tar.gz" | shasum -a 256 -c
RUN tar xzf ./actions-runner-${ARCH}-2.311.0.tar.gz

# Install aws cli
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip" \
&& unzip awscliv2.zip \
&& ./aws/install

# Install docker
# Add Docker's official GPG key:
RUN sudo apt-get update \
&& sudo apt-get install -y ca-certificates curl gnupg \
&& sudo install -m 0755 -d /etc/apt/keyrings \
&& curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
&& sudo chmod a+r /etc/apt/keyrings/docker.gpg \
&& echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null \
&& sudo apt-get update && sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin

RUN ./bin/installdependencies.sh

ENTRYPOINT [ "./entry_point.sh" ]

# How to run
# docker run -d --name github-actions-runner --privileged --rm -v /var/run/docker.sock:/var/run/docker.sock -e REPO_URL= -e TOKEN= github-action-self-hosted:latest