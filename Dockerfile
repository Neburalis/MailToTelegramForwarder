FROM python:3.12-slim

COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

WORKDIR /app

# Dependencies layer — cached separately from source code
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev

# Source code layer
COPY mailToTelegramForwarder.py ./

CMD ["uv", "run", "python", "mailToTelegramForwarder.py", "--config", "/config/mailToTelegramForwarder.conf"]
