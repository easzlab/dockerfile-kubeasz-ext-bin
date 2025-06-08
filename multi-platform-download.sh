#!/bin/sh
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

mkdir -p /ext-bin /extra/containerd-bin /extra/cni-bin

wget https://get.helm.sh/helm-${HELM_VER}-linux-${ARCH}.tar.gz && \
tar zxf helm-${HELM_VER}-linux-${ARCH}.tar.gz -C /tmp && \
mv /tmp/linux-${ARCH}/helm /ext-bin || exit 1

wget https://github.com/containerd/containerd/releases/download/v${CONTAINERD_VER}/containerd-static-${CONTAINERD_VER}-linux-${ARCH}.tar.gz && \
tar zxf containerd-static-${CONTAINERD_VER}-linux-${ARCH}.tar.gz -C /tmp && \
mv /tmp/bin/* /extra/containerd-bin && \
rm -rf containerd-${CONTAINERD_VER}-linux-${ARCH}.tar.gz || exit 1

wget https://github.com/kubernetes-sigs/cri-tools/releases/download/${CRICTL_VER}/crictl-${CRICTL_VER}-linux-${ARCH}.tar.gz && \
tar zxf crictl-${CRICTL_VER}-linux-${ARCH}.tar.gz && \
mv crictl /ext-bin && \
rm -rf crictl-${CRICTL_VER}-linux-${ARCH}.tar.gz || exit 1

wget https://github.com/opencontainers/runc/releases/download/${RUNC_VER}/runc.${ARCH} && \
mv runc.${ARCH} /extra/containerd-bin/runc || exit 1

wget "https://github.com/containernetworking/plugins/releases/download/${CNI_VER}/cni-plugins-linux-${ARCH}-${CNI_VER}.tgz" && \
tar zxf "cni-plugins-linux-${ARCH}-${CNI_VER}.tgz" -C /extra/cni-bin && \
rm -rf "cni-plugins-linux-${ARCH}-${CNI_VER}.tgz" || exit 1

wget https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VER}/docker-compose-Linux-${ARC} && \
mv docker-compose-Linux-${ARC} /ext-bin/docker-compose && \
chmod +x /ext-bin/docker-compose || exit 1

wget "https://github.com/projectcalico/calico/releases/download/${CALICOCTL_VER}/calicoctl-linux-${ARCH}" && \
mv calicoctl-linux-${ARCH} /ext-bin/calicoctl && \
chmod +x /ext-bin/calicoctl || exit 1

CILIUM_CLI_VER=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/master/stable.txt)
wget https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VER}/cilium-linux-${ARCH}.tar.gz && \
tar zxf cilium-linux-${ARCH}.tar.gz -C /ext-bin || exit 1

HUBBLE_VER=$(curl -s https://raw.githubusercontent.com/cilium/hubble/master/stable.txt)
wget https://github.com/cilium/hubble/releases/download/${HUBBLE_VER}/hubble-linux-${ARCH}.tar.gz && \
tar zxf hubble-linux-${ARCH}.tar.gz -C /ext-bin || exit 1
