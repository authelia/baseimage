FROM buildpack-deps:24.04 AS chisel

ARG CHISEL_RELEASE="1.0.0"
ARG SUEXEC_RELEASE="1.3"
ARG TARGETARCH

WORKDIR /root-fs

RUN \
    wget -qO - "https://github.com/canonical/chisel/releases/download/v${CHISEL_RELEASE}/chisel_v${CHISEL_RELEASE}_linux_${TARGETARCH}.tar.gz" | tar -xz --no-same-owner -C /usr/local/bin chisel && \
    git clone -b feat-wget-24.04 https://github.com/nightah/chisel-releases/ /chisel-releases

RUN \
    chisel cut --release /chisel-releases --root /root-fs \
    base-files_base base-files_release-info base-passwd_data busybox_bins \
    ca-certificates_data libc-bin_nsswitch tzdata_zoneinfo wget_bins && \
    exec /root-fs/bin/busybox --install /root-fs/bin

RUN  \
    wget -qO /root-fs/sbin/su-exec "https://github.com/songdongsheng/su-exec/releases/download/${SUEXEC_RELEASE}/su-exec-glibc-shared" && chmod +x /root-fs/sbin/su-exec

FROM scratch

COPY --link --from=chisel /root-fs /
