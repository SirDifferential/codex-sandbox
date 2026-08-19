# Codex Sandbox (Semi-Airgapped)

This container setup runs Codex CLI with a read-only root filesystem and a mandatory writable work directory at `/work`. LAN access is blocked at the host with nftables while public internet remains open. USB access is blocked at the container level by disallowing device passthrough and privileged mode.

The container has the necessary tools for basic C and C++ coding, as well as 32-bit wine, winetricks, dotnet40, and reverse engineering tools. 64-bit wine is also available but unconfigured.

## Build

```bash
docker build -t codex-sandbox:latest ~/codex-sandbox
```

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
bash ~/codex-sandbox/run.sh /path/to/workdir && codex
```

You may have to point Codex to read AGENTS.md in case the file is not read automatically.

## Security Notes

- Root filesystem is read-only; only `/work` is writable.
- `/work` is mounted from the host workdir you pass to `run.sh`.
- No container device passthrough and no privileged mode.
- All Linux capabilities dropped and no-new-privileges enforced.
- LAN access blocked for Docker bridge networks using nftables; public internet remains open.
- The container runs as user `ubuntu`, with `HOME` and `CODEX_HOME` forced to `/work` by the entrypoint.
