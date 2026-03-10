#!/usr/bin/env bash

# Ensure codex uses writable state under /work in read-only containers.
export HOME=/work
export CODEX_HOME=/work/.codex
mkdir -p "${CODEX_HOME}"

# Basic colored prompt and ls output, safe for non-interactive shells.
if [[ $- == *i* ]]; then
  export LS_COLORS=${LS_COLORS:-'di=34:ln=36:so=35:pi=33:ex=32:bd=33;1:cd=33;1:su=31;1:sg=31;1:tw=34;1:ow=34;1'}
  alias ls='ls --color=auto'
  alias ll='ls -lah --color=auto'
  alias la='ls -A --color=auto'
  export PS1='\[\e[1;32m\]\u@\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]\$ '
fi
