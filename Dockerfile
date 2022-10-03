# Download extra binaries needed by 'kubeasz'
# @author:  gjmzj
# @repo:    https://github.com/easzlab/dockerfile-kubeasz-ext-bin
# @ref:     https://github.com/kubernetes/kubernetes/blob/master/build/dependencies.yaml
# build use golang:1.19
FROM golang:1.19 as builder_119
ENV CFSSL_VER=v1.6.2
RUN set -x \
    && mkdir -p /ext-bin \
    && git config --global advice.detachedHead false \
    && git clone --depth 1 -b ${CFSSL_VER} https://github.com/cloudflare/cfssl.git \
    && cd cfssl && make && cd bin \
    && mv cfssljson cfssl-certinfo cfssl /ext-bin \
    && cd /go \
    \
    && CILIUM_CLI_VER=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/master/stable.txt) \
    && git clone --depth 1 -b ${CILIUM_CLI_VER} https://github.com/cilium/cilium-cli.git \
    && cd cilium-cli && make install \
    && mv /usr/local/bin/cilium /ext-bin/ \
    && cd /go \
    \
    && HUBBLE_VER=$(curl -s https://raw.githubusercontent.com/cilium/hubble/master/stable.txt) \
    && git clone --depth 1 -b ${HUBBLE_VER} https://github.com/cilium/hubble.git \
    && cd hubble && make install \
    && mv /usr/local/bin/hubble /ext-bin/

# build use golang:1.18
FROM golang:1.18 as builder_118
ENV CNI_VER=v1.1.1
ENV HELM_VER=v3.9.4
ENV CRICTL_VER=v1.25.0
ENV RUNC_VER=v1.1.4
ENV CONTAINERD_VER=1.6.8
ENV DOCKER_COMPOSE_VER=1.28.6
RUN set -x \
    && mkdir -p /ext-bin /extra/containerd-bin \
    && git config --global advice.detachedHead false \
    && git clone --depth 1 -b ${CNI_VER} https://github.com/containernetworking/plugins.git \
    && cd plugins && ./build_linux.sh && cd bin \
    && mv bridge host-local loopback portmap tuning /ext-bin \
    && cd /go \
    \
    && git clone --depth 1 -b ${HELM_VER} https://github.com/helm/helm.git \
    && cd helm && make \
    && mv bin/helm /ext-bin/ \
    && cd /go \
    \
    && git clone --depth 1 -b ${CRICTL_VER} https://github.com/kubernetes-sigs/cri-tools.git \
    && cd cri-tools && make \
    && mv build/bin/crictl /extra/containerd-bin \
    && cd /go \
    \
    && apt update && apt install libseccomp-dev -y \
    && git clone --depth 1 -b ${RUNC_VER} https://github.com/opencontainers/runc.git \
    && cd runc && make \
    && mv ./runc /extra/containerd-bin
# download containerd
COPY multi-platform-download.sh .
RUN sh -x ./multi-platform-download.sh

# release image
FROM alpine:3.12
ENV EXT_BIN_VER=1.4.0

COPY --from=quay.io/coreos/etcd:v3.5.4 /usr/local/bin/etcdctl /usr/local/bin/etcd /extra/
COPY --from=calico/ctl:v3.23.3 /calicoctl /extra/
COPY --from=easzlab/kubeasz-ext-build:1.1.0 /ext-bin/* /extra/
COPY --from=builder_119 /ext-bin/* /extra/
COPY --from=builder_118 /ext-bin/* /extra/
COPY --from=builder_118 /extra/containerd-bin/* /extra/containerd-bin/

CMD [ "sleep", "360000000" ]
