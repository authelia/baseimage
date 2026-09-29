FROM buildpack-deps:26.04 AS chisel

ARG CHISEL_RELEASE="1.5.1"
ARG SUEXEC_RELEASE="0.3"
ARG TARGETARCH

WORKDIR /root-fs

RUN <<EOF
    wget -qO - "https://github.com/canonical/chisel/releases/download/v${CHISEL_RELEASE}/chisel_v${CHISEL_RELEASE}_linux_${TARGETARCH}.tar.gz" | tar -xz --no-same-owner -C /usr/local/bin chisel

    chisel cut --release ubuntu-26.04 --root /root-fs \
    base-files_base base-files_release-info base-passwd_data \
    ca-certificates_data libc-bin_nsswitch tzdata_zoneinfo wget_bins && \

    wget -qO - "https://github.com/ncopa/su-exec/archive/refs/tags/v${SUEXEC_RELEASE}.tar.gz" | tar -xz -C /tmp && make -C /tmp/su-exec-${SUEXEC_RELEASE} && mv /tmp/su-exec-${SUEXEC_RELEASE}/su-exec /root-fs/sbin/su-exec
EOF

FROM --platform=${BUILDPLATFORM} authelia/crossbuild AS crossbuild

ARG BUSYBOX_VERSION=1.38.0-3ubuntu3
ARG TARGETARCH

SHELL ["/bin/bash", "-c"]

RUN <<EOF
    set -euo pipefail

    BUSYBOX_RELEASE="${BUSYBOX_VERSION%%-*}"

    cd /tmp
    wget -qO - "https://archive.ubuntu.com/ubuntu/pool/main/b/busybox/busybox_${BUSYBOX_RELEASE}.orig.tar.bz2" | tar -xj
    wget -qO - "https://archive.ubuntu.com/ubuntu/pool/main/b/busybox/busybox_${BUSYBOX_VERSION}.debian.tar.xz" | tar -xJ -C busybox-${BUSYBOX_RELEASE}

    cd busybox-${BUSYBOX_RELEASE}

    if [ -f debian/patches/series ]; then \
        while read p; do \
            [ -z "$p" ] && continue; \
            [[ "$p" == \#* ]] && continue; \
            echo "Applying patch: $p"; \
            patch -p1 < "debian/patches/$p"; \
        done < debian/patches/series; \
    fi

    if [[ ${TARGETARCH} == "arm" ]]; then
      export CROSS_COMPILE=arm-linux-gnueabihf-
    elif [[ ${TARGETARCH} == "arm64" ]]; then
      export CROSS_COMPILE=aarch64-linux-gnu-
    fi

    cp debian/config/pkg/deb .config
    make oldconfig
    make -j"$(nproc)"
    make CONFIG_PREFIX=/root-fs install
EOF

FROM buildpack-deps:26.04 AS final

COPY --link --from=chisel /root-fs /root-fs
COPY --link --from=crossbuild /root-fs/bin/busybox /root-fs/bin/busybox

RUN <<EOF
    /root-fs/bin/busybox --install /root-fs/bin
EOF

RUN --network=none <<EOF
    set -eu

    cp -a /root-fs /smoke-test
    mkdir -p /smoke-test/dev /smoke-test/tmp/www
    cp -a /dev/null /smoke-test/dev/null
    echo "ok" > /smoke-test/tmp/www/index.html

    chroot /smoke-test /bin/env -i PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin /bin/ash -eu -c '
        echo "--- ash"
        [ "$(command -v sh)" = "/bin/sh" ]
        [ "$(echo foo | sed s/foo/bar/)" = "bar" ]
        [ "$((6 * 7))" = "42" ]
        [ "$(sh -c "echo nested")" = "nested" ]

        echo "--- wget"
        [ "$(command -v wget)" = "/usr/bin/wget" ]
        wget --version | head -n 1 | grep -q "^GNU Wget"

        httpd -f -p 127.0.0.1:8080 -h /tmp/www &
        HTTPD_PID=$!
        trap "kill ${HTTPD_PID}" EXIT
        for i in 1 2 3 4 5; do wget -qO /dev/null http://127.0.0.1:8080/ && break; sleep 1; done

        [ "$(wget -qO - http://127.0.0.1:8080/)" = "ok" ]
        wget --quiet --no-check-certificate --tries=1 --spider http://127.0.0.1:8080/

        echo "--- smoke tests passed"
    '

    rm -rf /smoke-test
EOF

FROM scratch

COPY --link --from=final /root-fs /
