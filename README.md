# Codex Sandbox (Semi-Airgapped)

This container setup runs Codex CLI with a read-only root filesystem and a mandatory writable work directory at `/work`. LAN access is blocked at the host with nftables while public internet remains open. USB access is blocked at the container level by disallowing device passthrough and privileged mode.

## Build

```bash
docker build -t codex-sandbox:latest ~/codex-sandbox
```

## What's inside

- Base image: Ubuntu 24.04
- Node.js 20 (from Nodesource) and `@openai/codex` installed globally
- Convenience tools: `git`, `tmux`, `vim`, `curl`, `build-essential`
- Dotfiles: `bashrc` copied to `/home/ubuntu/.bashrc`, plus `.vimrc` and `.tmux.conf`
- `AGENTS.md` copied into `/work/.codex/AGENTS.md` at container start

## Apply LAN Guard (nftables)

The guard installs drop rules into Docker's `DOCKER-USER` chain for both `ip` and `ip6`, and uses a dedicated `codex_sandbox` table to store the discovered Docker bridge interface set.

```bash
sudo ~/codex-sandbox/host-network-guard.sh apply
```

Check status:

```bash
sudo ~/codex-sandbox/host-network-guard.sh status
```

Remove:

```bash
sudo ~/codex-sandbox/host-network-guard.sh remove
```

## API key

Create an OpenAI API key and save it to `~/.codex-key` on the host. `run.sh` reads this file and passes it into the container as `OPENAI_API_KEY`.

## Run

```bash
bash ~/codex-sandbox/run.sh /path/to/workdir
```

## Security Notes

- Root filesystem is read-only; only `/work` is writable.
- `/work` is mounted from the host workdir you pass to `run.sh`.
- No container device passthrough and no privileged mode.
- All Linux capabilities dropped and no-new-privileges enforced.
- LAN access blocked for Docker bridge networks using nftables; public internet remains open.
- The container runs as user `ubuntu`, with `HOME` and `CODEX_HOME` forced to `/work` by the entrypoint.
