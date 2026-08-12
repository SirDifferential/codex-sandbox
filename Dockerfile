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
	jq \
	python3-pil \
	python3-pefile \
	ffmpeg \
	imagemagick \
	file \
	bubblewrap \
	ripgrep \
	binutils \
	cabextract \
	wine \
	winetricks \
	xvfb \
	wget

RUN dpkg --add-architecture i386 && apt-get update && apt-get install -y --no-install-recommends wine32:i386 && rm -rf /var/lib/apt/lists/*
RUN npm install -g @openai/codex

ENV HOME=/home/ubuntu
WORKDIR /work

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY .bashrc /home/ubuntu/.bashrc
COPY .vimrc /home/ubuntu/.vimrc
COPY .tmux.conf /home/ubuntu/.tmux.conf
COPY AGENTS.md /home/ubuntu/AGENTS.md
RUN chmod 0755 /usr/local/bin/entrypoint.sh

USER ubuntu

ENV WINEPREFIX=/home/ubuntu/.wine64
ENV WINEARCH=win64

RUN xvfb-run --auto-servernum wineboot --init && xvfb-run --auto-servernum winetricks -q dotnet40

ENV WINEPREFIX=/home/ubuntu/.wine32
ENV WINEARCH=win32

RUN xvfb-run --auto-servernum wineboot --init && xvfb-run --auto-servernum winetricks -q dotnet40

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
