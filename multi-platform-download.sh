#!/bin/sh
mkdir -p /extra/containerd-bin
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
