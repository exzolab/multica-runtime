# syntax=docker/dockerfile:1

ARG BASE_IMAGE=ghcr.io/exzolab/base-devel:latest
FROM ${BASE_IMAGE}

SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

ARG CODEX_VERSION=latest
ARG PI_VERSION=latest
ARG MULTICA_VERSION=latest

# OpenAI Codex CLI (https://github.com/openai/codex)
RUN npm install -g "@openai/codex@${CODEX_VERSION}" \
    && npm cache clean --force

# Pi coding agent CLI (https://pi.dev)
RUN npm install -g --ignore-scripts "@earendil-works/pi-coding-agent@${PI_VERSION}" \
    && npm cache clean --force

# Google Antigravity CLI (https://antigravity.google/download?os=linux)
RUN curl -fsSL https://antigravity.google/cli/install.sh | bash \
    && rm -rf "${HOME}/.cache/antigravity"

# Multica CLI (https://multica.ai/docs/cli)
RUN if [ "${MULTICA_VERSION}" = "latest" ]; then \
        curl -fsSL https://raw.githubusercontent.com/multica-ai/multica/main/scripts/install.sh \
            | MULTICA_BIN_DIR="${HOME}/.local/bin" bash; \
    else \
        arch="$(dpkg --print-architecture)"; \
        tag="v${MULTICA_VERSION#v}"; \
        ver="${MULTICA_VERSION#v}"; \
        tmp_dir="$(mktemp -d)"; \
        curl -fsSL "https://github.com/multica-ai/multica/releases/download/${tag}/multica-cli-${ver}-linux-${arch}.tar.gz" \
            -o "${tmp_dir}/multica.tar.gz"; \
        tar -xzf "${tmp_dir}/multica.tar.gz" -C "${tmp_dir}" multica; \
        install -m 0755 "${tmp_dir}/multica" "${HOME}/.local/bin/multica"; \
        rm -rf "${tmp_dir}"; \
    fi

# Preserve toolchain and agent CLI directories in login shells (/etc/profile resets PATH)
RUN sudo tee /etc/profile.d/99-multica-runtime-path.sh >/dev/null <<'EOF'
export PATH="${HOME}/.local/bin:${HOME}/.bun/bin:${NPM_CONFIG_PREFIX:-${HOME}/.npm-global}/bin:${GOPATH:-${HOME}/go}/bin:/usr/local/go/bin:${CARGO_HOME:-/usr/local/cargo}/bin:${PATH}"
EOF

# Smoke-test installed CLIs during build (both non-login and login shells)
RUN codex --version \
    && agy --version \
    && pi --version \
    && multica version \
    && bash -lc 'command -v codex agy pi multica >/dev/null'

CMD ["/bin/bash"]
