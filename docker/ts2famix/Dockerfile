FROM node:20.19.4-bookworm-slim@sha256:6db5e436948af8f0244488a1f658c2c8e55a3ae51ca2e1686ed042be8f25f70a

ARG TS2FAMIX_COMMIT=679f54e7a0990791e8dce3e437ff4915baebfdc5

RUN apt-get update \
    && apt-get install --yes --no-install-recommends ca-certificates git \
    && git clone https://github.com/fuhrmanator/FamixTypeScriptImporter.git /opt/ts2famix \
    && git -C /opt/ts2famix checkout ${TS2FAMIX_COMMIT} \
    && cd /opt/ts2famix \
    && npm ci --ignore-scripts \
    && npm run build \
    && npm install --global --ignore-scripts /opt/ts2famix \
    && apt-get purge --yes git \
    && apt-get autoremove --yes \
    && apt-get clean \
    && npm cache clean --force

ENTRYPOINT ["ts2famix"]
