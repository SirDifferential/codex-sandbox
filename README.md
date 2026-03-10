# Codex Sandbox (Semi-Airgapped)

This container setup runs Codex CLI with a read-only root filesystem and a mandatory writable work directory at `/work`. LAN access is blocked at the host with nftables while public internet remains open. USB access is blocked at the container level by disallowing device passthrough and privileged mode.

## Build

```bash
docker build -t codex-sandbox:latest ~/codex-sandbox
```

Optional: override the npm package name if needed.

```bash
docker build -t codex-sandbox:latest \
  --build-arg CODEX_NPM_PKG=codex \
  ~/codex-sandbox
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

Create OpenAI API key and save it to ~/.codex-key

## Run

```bash
bash ~/codex-sandbox/run.sh /path/to/workdir
```

You can pass extra Docker args after the workdir if needed.

## Security Notes

- Root filesystem is read-only; only `/work` is writable.
- No container device passthrough and no privileged mode.
- All Linux capabilities dropped and no-new-privileges enforced.
- LAN access blocked for Docker bridge networks using nftables; public internet remains open.
