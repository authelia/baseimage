FROM buildpack-deps:24.04 AS chisel

ARG BUSYBOX_RELEASE=1.37.0
ARG BUSYBOX_REV=4
ARG CHISEL_RELEASE="1.2.0"
ARG SUEXEC_RELEASE="0.2"
ARG TARGETARCH

WORKDIR /root-fs

RUN <<EOF
    set -e
    wget -qO - "https://github.com/canonical/chisel/releases/download/v${CHISEL_RELEASE}/chisel_v${CHISEL_RELEASE}_linux_${TARGETARCH}.tar.gz" | tar -xz --no-same-owner -C /usr/local/bin chisel

    chisel cut --release ubuntu-24.04 --root /root-fs \
    base-files_base base-files_release-info base-passwd_data \
    ca-certificates_data libc-bin_nsswitch tzdata_zoneinfo wget_bins && \

    cd /tmp
    wget -qO - "https://archive.ubuntu.com/ubuntu/pool/main/b/busybox/busybox_${BUSYBOX_RELEASE}.orig.tar.bz2" | tar -xj
    wget -qO - "https://archive.ubuntu.com/ubuntu/pool/main/b/busybox/busybox_${BUSYBOX_RELEASE}-${BUSYBOX_REV}ubuntu1.debian.tar.xz" | tar -xJ -C busybox-${BUSYBOX_RELEASE}

    cd busybox-${BUSYBOX_RELEASE}

    for f in CVE-2024-58251-2.patch CVE-2025-46394.patch; do
      wget -q -P debian/patches https://raw.githubusercontent.com/wolfi-dev/os/050b3a5b2846b85cb385aa72cabbd457964a42a6/busybox/${f}
      echo ${f} >> debian/patches/series
    done

    if [ -f debian/patches/series ]; then \
        grep -vE '^[[:space:]]*(#|$)' debian/patches/series | while read -r p; do \
            echo "Applying patch: $p"; \
            patch -p1 < "debian/patches/$p"; \
        done; \
    fi

    cp debian/config/pkg/deb .config
    make oldconfig
    make -j"$(nproc)"
    make CONFIG_PREFIX=/root-fs install
    /root-fs/bin/busybox --install /root-fs/bin

    wget -qO - "https://github.com/ncopa/su-exec/archive/refs/tags/v${SUEXEC_RELEASE}.tar.gz" | tar -xz -C /tmp && make -C /tmp/su-exec-${SUEXEC_RELEASE} && mv /tmp/su-exec-${SUEXEC_RELEASE}/su-exec /root-fs/sbin/su-exec
EOF

FROM scratch

COPY --link --from=chisel /root-fs /
