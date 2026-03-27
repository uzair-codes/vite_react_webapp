FROM jenkins/inbound-agent

USER root

RUN apt update && apt install -y \
    ansible \
    curl \
    unzip \
    python3-pip

# Install Terraform
RUN curl -fsSL https://releases.hashicorp.com/terraform/1.5.0/terraform_1.5.0_linux_amd64.zip -o terraform.zip \
    && unzip terraform.zip \
    && mv terraform /usr/local/bin/ \
    && rm terraform.zip