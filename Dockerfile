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

RUN useradd -m -u 10001 -s /bin/bash codex \
  && npm install -g "${CODEX_NPM_PKG}"

ENV HOME=/home/codex
WORKDIR /work

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY bashrc /home/codex/.bashrc
COPY .vimrc /home/codex/.vimrc
COPY .tmux.conf /home/codex/.tmux.conf
RUN chmod 0755 /usr/local/bin/entrypoint.sh

USER codex

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
