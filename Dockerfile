FROM ubuntu:24.04

ARG CODEX_NPM_PKG=@openai/codex
ARG TARGETARCH=amd64

ARG GHIDRA_VERSION=12.1.3
ARG GHIDRA_BUILD_DATE=20260817
ARG GHIDRA_SHA256=93a5d11a9ad510622acaaf908c556a7b9b764d338e78a7567f3689bf5081fd54
ARG RADARE2_VERSION=6.2.0
ARG RADARE2_SHA256=eb82324e83315887fbee6f5d8632c982c593e056a87180f1bec5ccb06c463aeb
ARG DIE_VERSION=3.21
ARG DIE_SHA256=96e8e82e822e3ca8a829536312b92e8b241147fe38c8ab29c9dbfc1ab21aa25d
ARG CUTTER_VERSION=2.5.0
ARG CUTTER_SHA256=b8ad215d7a9e2af9e1f463511229f16e1f4745a0fb541413e5f4787f949ac0cf
ARG CAPA_VERSION=9.4.0
ARG CAPA_RULES_SHA256=79e37bb648dd7a912ff49e8d89bff022ea156d2567f8fe5080f9d6d03067ee02

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
	xxd \
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
    wget \
    unzip \
    python3-venv \
    llvm \
    openjdk-21-jdk \
    libgl1 \
    libopengl0 \
    libxcb-cursor0 \
    libxcb-xinerama0 \
    libxcb-xkb1 \
    libxkbcommon-x11-0

# The upstream Linux packages for DIE, Cutter, and BinDiff are amd64-only.
RUN test "$TARGETARCH" = amd64

RUN set -eux; \
  ghidra_zip="ghidra_${GHIDRA_VERSION}_PUBLIC_${GHIDRA_BUILD_DATE}.zip"; \
  curl -fL --retry 3 \
    "https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_${GHIDRA_VERSION}_build/${ghidra_zip}" \
    -o "/tmp/${ghidra_zip}"; \
  echo "${GHIDRA_SHA256}  /tmp/${ghidra_zip}" | sha256sum -c -; \
  unzip -q "/tmp/${ghidra_zip}" -d /opt; \
  mv "/opt/ghidra_${GHIDRA_VERSION}_PUBLIC" /opt/ghidra; \
  rm "/tmp/${ghidra_zip}"

RUN set -eux; \
  radare2_deb="radare2_${RADARE2_VERSION}_amd64.deb"; \
  curl -fL --retry 3 \
    "https://github.com/radareorg/radare2/releases/download/${RADARE2_VERSION}/${radare2_deb}" \
    -o "/tmp/${radare2_deb}"; \
  echo "${RADARE2_SHA256}  /tmp/${radare2_deb}" | sha256sum -c -; \
  apt-get install -y --no-install-recommends "/tmp/${radare2_deb}"; \
  rm "/tmp/${radare2_deb}"

RUN set -eux; \
  die_deb="die_${DIE_VERSION}_Ubuntu_24.04_amd64.deb"; \
  curl -fL --retry 3 \
    "https://github.com/horsicq/DIE-engine/releases/download/${DIE_VERSION}/${die_deb}" \
    -o "/tmp/${die_deb}"; \
  echo "${DIE_SHA256}  /tmp/${die_deb}" | sha256sum -c -; \
  apt-get install -y --no-install-recommends "/tmp/${die_deb}"; \
  rm "/tmp/${die_deb}"

# Extracting the AppImage makes Cutter usable in containers without FUSE.
RUN set -eux; \
  cutter_appimage="Cutter-v${CUTTER_VERSION}-Linux-x86_64.AppImage"; \
  curl -fL --retry 3 \
    "https://github.com/rizinorg/cutter/releases/download/v${CUTTER_VERSION}/${cutter_appimage}" \
    -o "/tmp/${cutter_appimage}"; \
  echo "${CUTTER_SHA256}  /tmp/${cutter_appimage}" | sha256sum -c -; \
  chmod +x "/tmp/${cutter_appimage}"; \
  cd /opt; \
  "/tmp/${cutter_appimage}" --appimage-extract; \
  mv squashfs-root cutter; \
  ln -s /opt/cutter/AppRun /usr/local/bin/cutter; \
  rm "/tmp/${cutter_appimage}"

RUN set -eux; \
  curl -fL --retry 3 \
    "https://github.com/google/bindiff/releases/download/v8/bindiff_8_amd64.deb" \
    -o /tmp/bindiff_8_amd64.deb; \
  curl -fL --retry 3 \
    "https://github.com/google/bindiff/releases/download/v8/bindiff_8_amd64.deb.asc" \
    -o /tmp/bindiff_8_amd64.deb.asc; \
  gpg --batch --keyserver hkps://keyserver.ubuntu.com \
    --recv-keys 7721F63BD38B4796; \
  gpg --batch --verify /tmp/bindiff_8_amd64.deb.asc /tmp/bindiff_8_amd64.deb; \
  apt-get install -y --no-install-recommends /tmp/bindiff_8_amd64.deb; \
  rm /tmp/bindiff_8_amd64.deb /tmp/bindiff_8_amd64.deb.asc; \
  rm -rf /root/.gnupg

# Avoid the standalone PyInstaller binary, which extracts shared libraries to
# a temporary filesystem and fails when that filesystem disallows mmap/exec.
RUN set -eux; \
  python3 -m venv /opt/capa-venv; \
  /opt/capa-venv/bin/pip install --no-cache-dir "flare-capa==${CAPA_VERSION}"; \
  capa_rules_zip="capa-rules-v${CAPA_VERSION}.zip"; \
  curl -fL --retry 3 \
    "https://github.com/mandiant/capa-rules/archive/refs/tags/v${CAPA_VERSION}.zip" \
    -o "/tmp/${capa_rules_zip}"; \
  echo "${CAPA_RULES_SHA256}  /tmp/${capa_rules_zip}" | sha256sum -c -; \
  capa_root="$(/opt/capa-venv/bin/python -c 'import capa.main; print(capa.main.get_default_root())')"; \
  unzip -q "/tmp/${capa_rules_zip}" -d /tmp; \
  mv "/tmp/capa-rules-${CAPA_VERSION}" "${capa_root}/rules"; \
  rm "/tmp/${capa_rules_zip}"; \
  ln -s /opt/capa-venv/bin/capa /usr/local/bin/capa

RUN dpkg --add-architecture i386 && apt-get update && apt-get install -y --no-install-recommends wine32:i386 && rm -rf /var/lib/apt/lists/*
RUN npm install -g "$CODEX_NPM_PKG"

ENV HOME=/home/ubuntu
WORKDIR /work

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY ghidra-wrapper.sh /usr/local/bin/ghidra
RUN chmod 0755 /usr/local/bin/ghidra \
  && ln -s /usr/local/bin/ghidra /usr/local/bin/analyzeHeadless
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
