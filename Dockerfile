FROM buildpack-deps:24.04 AS chisel

ARG CHISEL_RELEASE="1.4.0"
ARG SUEXEC_RELEASE="0.3"
ARG TARGETARCH

WORKDIR /root-fs

RUN <<EOF
    wget -qO - "https://github.com/canonical/chisel/releases/download/v${CHISEL_RELEASE}/chisel_v${CHISEL_RELEASE}_linux_${TARGETARCH}.tar.gz" | tar -xz --no-same-owner -C /usr/local/bin chisel

    chisel cut --release ubuntu-24.04 --root /root-fs \
    base-files_base base-files_release-info base-passwd_data \
    ca-certificates_data libc-bin_nsswitch tzdata_zoneinfo wget_bins && \

    wget -qO - "https://github.com/ncopa/su-exec/archive/refs/tags/v${SUEXEC_RELEASE}.tar.gz" | tar -xz -C /tmp && make -C /tmp/su-exec-${SUEXEC_RELEASE} && mv /tmp/su-exec-${SUEXEC_RELEASE}/su-exec /root-fs/sbin/su-exec
EOF

FROM --platform=${BUILDPLATFORM} authelia/crossbuild AS crossbuild

ARG BUSYBOX_RELEASE=1.37.0
ARG BUSYBOX_REV=4
ARG TARGETARCH

SHELL ["/bin/bash", "-c"]

COPY --link patches /tmp/patches

RUN <<EOF
    set -euo pipefail

    cd /tmp
    wget -qO - "https://archive.ubuntu.com/ubuntu/pool/main/b/busybox/busybox_${BUSYBOX_RELEASE}.orig.tar.bz2" | tar -xj
    wget -qO - "https://archive.ubuntu.com/ubuntu/pool/main/b/busybox/busybox_${BUSYBOX_RELEASE}-${BUSYBOX_REV}ubuntu1.debian.tar.xz" | tar -xJ -C busybox-${BUSYBOX_RELEASE}

    cd busybox-${BUSYBOX_RELEASE}

    for f in CVE-2024-58251-2.patch CVE-2025-46394.patch; do
      wget -q -P debian/patches https://raw.githubusercontent.com/wolfi-dev/os/050b3a5b2846b85cb385aa72cabbd457964a42a6/busybox/${f}
      echo ${f} >> debian/patches/series
    done

    cp /tmp/patches/busybox/CVE-2025-60876.patch debian/patches/
    echo "CVE-2025-60876.patch" >> debian/patches/series

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

FROM buildpack-deps:24.04 AS final

COPY --link --from=chisel /root-fs /root-fs
COPY --link --from=crossbuild /root-fs/bin/busybox /root-fs/bin/busybox

RUN <<EOF
    /root-fs/bin/busybox --install /root-fs/bin
EOF

FROM scratch

COPY --link --from=final /root-fs /
