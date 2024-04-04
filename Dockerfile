FROM node:20-slim AS build
WORKDIR /app

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

COPY . .

RUN --mount=type=cache,id=corepack,target=/app/cache \
		ls -la /app/cache

RUN --mount=type=cache,id=corepack,target=/app/cache \
    if [ ! -f "/app/cache/corepack.tgz" ]; then \
		corepack pnpm --version; \
		mkdir -p /app/cache; \
    corepack pack -o /app/cache/corepack.tgz; \
    fi

RUN --mount=type=cache,id=corepack,target=/app/cache \
    COREPACK_ENABLE_NETWORK=0 corepack install -g --cache-only /app/cache/corepack.tgz

#RUN COREPACK_ENABLE_STRICT=0 COREPACK_ENABLE_NETWORK=0 corepack pnpm --version

RUN \
	--mount=type=cache,id=pnpm,target=/pnpm/store \
	COREPACK_ENABLE_STRICT=0 COREPACK_ENABLE_NETWORK=0 corepack pnpm install --frozen-lockfile --prefer-offline

EXPOSE 80

CMD ["node", "./src/index.js"]
