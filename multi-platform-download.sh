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

wget "https://github.com/containernetworking/plugins/releases/download/${CNI_VER}/cni-plugins-linux-${ARCH}-${CNI_VER}.tgz" && \
tar zxf "cni-plugins-linux-${ARCH}-${CNI_VER}.tgz" -C /tmp && \
cd /tmp && mv bridge host-local loopback portmap tuning /ext-bin && \
rm -rf "cni-plugins-linux-${ARCH}-${CNI_VER}.tgz"

wget https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VER}/docker-compose-Linux-${ARC} && \
mv docker-compose-Linux-${ARC} /ext-bin/docker-compose && \
