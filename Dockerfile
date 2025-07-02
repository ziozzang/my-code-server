# Use Ubuntu as the base image
FROM debian:latest

# Install necessary packages && optimize container size
RUN apt-get update && apt-get install -y software-properties-common apt-transport-https wget && \
    apt-get clean autoclean && \
    apt-get autoremove --yes && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/

# Add the Microsoft GPG key
RUN wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | gpg --dearmor | tee /etc/apt/trusted.gpg.d/microsoft.gpg

# Add the Visual Studio Code repository
RUN echo "deb [arch=amd64] https://packages.microsoft.com/repos/code stable main" | tee /etc/apt/sources.list.d/vscode.list

# Install needed packages on your IDE system && optimize container size
RUN apt-get update && \
    apt-get -y install code && \
    apt-get -y install sudo -y \
    nano \
    git \
    curl \
    wget \
    unzip \
    npm htop mc tmux \
    ssh  python3-pip && \
    apt-get clean autoclean && \
    apt-get autoremove --yes && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/

RUN wget https://download.docker.com/linux/static/stable/x86_64/docker-28.3.0.tgz && \
    tar xzvf docker-28.3.0.tgz && \
    mv docker/docker /usr/bin/ && \
    rm -rf docker docker-*.tgz

RUN curl -SL https://github.com/docker/compose/releases/download/v2.38.1/docker-compose-linux-x86_64 -o /usr/bin/docker-compose && \
    chmod +x /usr/bin/docker-compose && \
    apt-get clean autoclean && \
    apt-get autoremove --yes && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/

# Copy start.sh to the container
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

# Create a non-root user
RUN useradd -m vscodeuser && \
    echo 'vscodeuser ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/vscodeuser && \
    chmod 0444 /etc/sudoers.d/vscodeuser && \
    usermod -aG sudo vscodeuser

# Switch to the non-root user
USER vscodeuser

# Set the home directory for the non-root user
ENV HOME=/home/vscodeuser

# Install vscode plugins
RUN mkdir -p $HOME/.vscode-server/extensions $HOME/.vscode && ln -s $HOME/.vscode-server/extensions $HOME/.vscode/extensions && \
    code --install-extension saoudrizwan.claude-dev && \
    code --install-extension ms-python.vscode-pylance && \
    code --install-extension ms-python.python && \
    code --install-extension RooVeterinaryInc.roo-cline && \
    code --install-extension ms-python.debugpy && \
    code --install-extension ms-azuretools.vscode-docker && \
    code --install-extension GitLab.gitlab-workflow && \
    code --install-extension ms-python.pylint && \
    code --install-extension DhananjaySenday.mcp--inspector && \
    code --install-extension humao.rest-client && \
    code --install-extension 42Crunch.vscode-openapi && \
    code --install-extension ZainChen.json && \
    code --install-extension MS-CEINTL.vscode-language-pack-ko && \
    code --install-extension ms-kubernetes-tools.vscode-kubernetes-tools && \
    code --install-extension slightc.pip-manager && \
    code --install-extension ms-toolsai.jupyter && \
    code --install-extension ecmel.vscode-html-css && \
    code --install-extension p1c2u.docker-compose && \
    code --install-extension ms-azuretools.vscode-containers && \
    code --install-extension ms-vscode-remote.remote-containers && \
    code --install-extension ms-azuretools.vscode-docker && \
    code --install-extension ms-vscode-remote.vscode-remote-extensionpack && \
    code --install-extension ReprEng.csv && \
    code --install-extension DotJoshJohnson.xml && \
    code --install-extension RabinHansda.flask-builder && \
    code --install-extension formulahendry.code-runner && \
    code --install-extension eridem.vscode-postman && \
    code --install-extension magabde.focus-microservice && \
    code --install-extension damildrizzy.fastapi-snippets && \
    code --install-extension DhananjaySenday.mcp--inspector

# Exécutez le script au lancement du conteneur
ENTRYPOINT ["sh", "/app/start.sh"]
