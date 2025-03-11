FROM buildpack-deps:24.04 AS chisel

ARG CHISEL_RELEASE="1.0.0"
ARG SUEXEC_RELEASE="0.2"
ARG TARGETARCH

WORKDIR /root-fs

RUN \
    wget -qO - "https://github.com/canonical/chisel/releases/download/v${CHISEL_RELEASE}/chisel_v${CHISEL_RELEASE}_linux_${TARGETARCH}.tar.gz" | tar -xz --no-same-owner -C /usr/local/bin chisel

RUN \
    chisel cut --release ubuntu-24.04 --root /root-fs \
    base-files_base base-files_release-info base-passwd_data busybox_bins \
    ca-certificates_data libc-bin_nsswitch tzdata_zoneinfo wget_bins && \
    exec /root-fs/bin/busybox --install /root-fs/bin

RUN  \
    wget -qO - "https://github.com/ncopa/su-exec/archive/refs/tags/v${SUEXEC_RELEASE}.tar.gz" | tar -xz -C /tmp && make -C /tmp/su-exec-${SUEXEC_RELEASE} && mv /tmp/su-exec-${SUEXEC_RELEASE}/su-exec /root-fs/sbin/su-exec

FROM scratch

COPY --link --from=chisel /root-fs /
