ARG BALENA_ARCH=%%BALENA_ARCH%%
ARG BALENALIB_ARCH=%%BALENA_ARCH%%
ARG DISTRO=debian

FROM balenalib/${BALENALIB_ARCH}-debian:buster-build AS debian

ARG BALENA_ARCH=%%BALENA_ARCH%%
ENV BUILD_FLAGS='--prefix=/'
ENV DEST_DIR=node-v${NODE_VERSION}-linux-${BALENA_ARCH}
ENV TAR_FILE=node-v${NODE_VERSION}-linux-${BALENA_ARCH}.tar.gz

FROM balenalib/${BALENALIB_ARCH}-alpine:3.18-build AS alpine

ARG BALENA_ARCH=%%BALENA_ARCH%%
ENV BUILD_FLAGS='--prefix=/ --shared-zlib'
ENV DEST_DIR=node-v${NODE_VERSION}-linux-${BALENA_ARCH}-alpine
ENV TAR_FILE=node-v${NODE_VERSION}-linux-${BALENA_ARCH}-alpine.tar.gz

# hadolint ignore=DL3006
FROM ${DISTRO} AS build

WORKDIR /src

RUN git clone https://github.com/nodejs/node.git .

ARG NODE_VERSION
COPY commit-table ./commit-table

RUN commit="$(awk -v version="v${NODE_VERSION}" '$2 == version {print $1}' commit-table)" && \
	if [ -z "${commit}" ]; then echo "commit for v$NODE_VERSION not found!" ; exit 1 ; fi && \
	git -c advice.detachedHead=false checkout "${commit}"

# hadolint ignore=SC2086
RUN ./configure $BUILD_FLAGS \
	&& make install -j"$(nproc)" DESTDIR="${DEST_DIR}" V=1 PORTABLE=1

RUN	tar -cvzf "${TAR_FILE}" "${DEST_DIR}"

FROM scratch AS output

COPY --from=build /src/node-*.tar.gz /
