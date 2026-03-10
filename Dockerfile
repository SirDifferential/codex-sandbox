FROM ubuntu:24.04

ARG CODEX_NPM_PKG=@openai/codex

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    gnupg \
  && mkdir -p /etc/apt/keyrings \
  && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
    | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
  && printf '%s\n' \
    'deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main' \
    > /etc/apt/sources.list.d/nodesource.list \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    nodejs \
	tmux \
	vim \
	curl \
  && rm -rf /var/lib/apt/lists/*

RUN npm install -g "${CODEX_NPM_PKG}"

ENV HOME=/home/ubuntu
WORKDIR /work

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY bashrc /home/ubuntu/.bashrc
COPY .vimrc /home/ubuntu/.vimrc
COPY .tmux.conf /home/ubuntu/.tmux.conf
COPY AGENTS.md /home/ubuntu/.codex/AGENTS.md
RUN chmod 0755 /usr/local/bin/entrypoint.sh

USER ubuntu

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
