#!/bin/sh
mkdir -p /ext-bin /extra/containerd-bin
ARC=$(uname -m)
ARCH="amd64"

case "$ARC" in
  x86_64)
      ARCH="amd64"
      ;;
  aarch64)
      ARCH="arm64"
      ;;
  ?)
      echo "error: not supported platform right now, exit"
      exit 1
      ;;
esac

wget https://github.com/containerd/containerd/releases/download/v${CONTAINERD_VER}/containerd-${CONTAINERD_VER}-linux-${ARCH}.tar.gz && \
tar zxf containerd-${CONTAINERD_VER}-linux-${ARCH}.tar.gz -C /tmp && \
mv /tmp/bin/* /extra/containerd-bin && \
rm -rf containerd-${CONTAINERD_VER}-linux-${ARCH}.tar.gz

wget https://github.com/kubernetes-sigs/cri-tools/releases/download/${CRICTL_VER}/crictl-${CRICTL_VER}-linux-${ARCH}.tar.gz && \
tar zxf crictl-${CRICTL_VER}-linux-${ARCH}.tar.gz && \
mv crictl /extra/containerd-bin && \
rm -rf crictl-${CRICTL_VER}-linux-${ARCH}.tar.gz

wget https://github.com/opencontainers/runc/releases/download/${RUNC_VER}/runc.${ARCH} && \
mv runc.${ARCH} /extra/containerd-bin/runc
