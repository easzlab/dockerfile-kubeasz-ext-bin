# Download extra binaries needed by 'kubeasz'
# @author:  gjmzj
# @repo:    https://github.com/easzlab/dockerfile-kubeasz-ext-bin
# @ref:     https://github.com/kubernetes/kubernetes/blob/master/build/dependencies.yaml
# build use golang:1.20
FROM golang:1.20 as builder_120
ENV CFSSL_VER=v1.6.4
RUN set -x \
    && mkdir -p /ext-bin \
    && git config --global advice.detachedHead false \
    && git clone --depth 1 -b ${CFSSL_VER} https://github.com/cloudflare/cfssl.git \
    && cd cfssl \
    && go build -tags 'netgo,osusergo,sqlite_omit_load_extension' -ldflags '-s -w -extldflags "-static"' cmd/cfssl/cfssl.go \
    && go build -tags 'netgo,osusergo,sqlite_omit_load_extension' -ldflags '-s -w -extldflags "-static"' cmd/cfssljson/cfssljson.go \
    && go build -tags 'netgo,osusergo,sqlite_omit_load_extension' -ldflags '-s -w -extldflags "-static"' cmd/cfssl-certinfo/cfssl-certinfo.go \
    && mv cfssljson cfssl-certinfo cfssl /ext-bin

# downloader use golang:1.20
FROM golang:1.20 as downloader_120
ENV CNI_VER=v1.3.0
ENV HELM_VER=v3.12.3
ENV CRICTL_VER=v1.28.0
ENV RUNC_VER=v1.1.9
ENV CONTAINERD_VER=1.6.23
ENV DOCKER_COMPOSE_VER=v2.20.3
COPY multi-platform-download.sh .
RUN sh -x ./multi-platform-download.sh

# release image
FROM alpine:3.16
ENV EXT_BIN_VER=1.8.0

COPY --from=quay.io/coreos/etcd:v3.5.9 /usr/local/bin/etcdctl /usr/local/bin/etcd /extra/
COPY --from=calico/ctl:v3.24.6 /calicoctl /extra/
COPY --from=easzlab/kubeasz-ext-build:1.3.0 /ext-bin/* /extra/
COPY --from=builder_120 /ext-bin/* /extra/
COPY --from=downloader_120 /ext-bin/* /extra/
COPY --from=downloader_120 /extra/containerd-bin/* /extra/containerd-bin/
COPY --from=downloader_120 /extra/cni-bin/* /extra/cni-bin/

CMD [ "sleep", "360000000" ]
