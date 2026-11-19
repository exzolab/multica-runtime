# multica-runtime

Container image based on [`ghcr.io/exzolab/base-devel:latest`](https://github.com/exzolab/base-devel/pkgs/container/base-devel) (`debian:trixie-slim`), adding agent CLIs and the Multica CLI:

- **OpenAI Codex CLI** (`codex`) — [github.com/openai/codex](https://github.com/openai/codex)
- **Google Antigravity CLI** (`agy`) — [antigravity.google/download?os=linux](https://antigravity.google/download?os=linux)
- **Pi Coding Agent** (`pi`) — [pi.dev](https://pi.dev)
- **Multica CLI** (`multica`) — [multica.ai/docs/cli](https://multica.ai/docs/cli)

## Build Locally

Using Apple `container`:

```bash
container build -t multica-runtime:latest .
```

Or with Docker:

```bash
docker build -t multica-runtime:latest .
```

### Pinning Versions

Tool versions and base image are configurable via `--build-arg`:

```bash
container build -t multica-runtime:latest \
  --build-arg BASE_IMAGE=ghcr.io/exzolab/base-devel:latest \
  --build-arg CODEX_VERSION=latest \
  --build-arg PI_VERSION=latest \
  --build-arg MULTICA_VERSION=latest \
  .
```

## Run

```bash
container run --rm -it -v "$PWD:/workspace" multica-runtime:latest
```

All tool binaries live under `/home/dev/.npm-global/bin` and `/home/dev/.local/bin`, so you can safely mount auth/state directories (such as `~/.codex`, `~/.gemini`, `~/.pi`, `~/.multica`) into `/home/dev/` without shadowing any binaries.

## Publishing via GitHub Actions

Pushing a `v*` tag (e.g. `v1.0.0`) or triggering **Build and Publish Image** manually builds and publishes multi-arch (`linux/amd64`, `linux/arm64`) images to GHCR using `.github/workflows/publish.yml`.
