FROM nimlang/nim:alpine AS build

COPY . /userdef

WORKDIR /userdef

RUN nimble dbuild

FROM scratch

ARG BUILD_VERSION
ARG BUILD_REVISION
ARG BUILD_DATE

LABEL maintainer="Akito <the@akito.ooo>"
LABEL org.opencontainers.image.authors="Akito <the@akito.ooo>"
LABEL org.opencontainers.image.vendor="Akito"
LABEL org.opencontainers.image.version="${BUILD_VERSION}"
LABEL org.opencontainers.image.revision="${BUILD_REVISION}"
LABEL org.opencontainers.image.created="${BUILD_DATE}"
LABEL org.opencontainers.image.title="userdef"
LABEL org.opencontainers.image.description="Creates and sets up custom OS user of any ID. Useful for BusyBox based images, like Alpine."
LABEL org.opencontainers.image.url="https://hub.docker.com/r/akito13/userdef"
LABEL org.opencontainers.image.documentation="https://github.com/theAkito/userdef/wiki"
LABEL org.opencontainers.image.source="https://github.com/theAkito/userdef"
LABEL org.opencontainers.image.licenses="GPL-3.0+"

COPY --from=build /userdef/userdef_debug /userdef