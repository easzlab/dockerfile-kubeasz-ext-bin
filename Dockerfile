# Download extra binaries needed by 'kubeasz'
# @author:  gjmzj
# @repo:    https://github.com/easzlab/dockerfile-kubeasz-ext-bin
# @ref:     https://github.com/kubernetes/kubernetes/blob/master/build/dependencies.yaml

# downloader use ubuntu:22.04
FROM alpine:3.22 as downloader
ENV CNI_VER=v1.9.1
ENV HELM_VER=v4.2.3
ENV CRICTL_VER=v1.36.0
ENV RUNC_VER=v1.5.1
ENV CONTAINERD_VER=2.3.3
ENV DOCKER_COMPOSE_VER=v5.3.1
ENV CALICOCTL_VER=v3.32.1
COPY multi-platform-download.sh .
RUN set -ex \
    && apk update \
    && apk add --no-cache \
    && curl \
    && sh -x ./multi-platform-download.sh

# release image
FROM alpine:3.22
ENV EXT_BIN_VER=1.14.1

# https://github.com/etcd-io/etcd
COPY --from=quay.io/coreos/etcd:v3.7.0 /usr/local/bin/etcdutl /usr/local/bin/etcdctl /usr/local/bin/etcd /extra/
COPY --from=easzlab/kubeasz-ext-build:1.5.0 /ext-bin/* /extra/
COPY --from=apecloud/minio:RELEASE.2025-10-15T17-29-55Z /bin/minio /bin/mc /extra/
COPY --from=downloader /ext-bin/* /extra/
COPY --from=downloader /extra/containerd-bin/* /extra/containerd-bin/
COPY --from=downloader /extra/cni-bin/* /extra/cni-bin/

CMD [ "sleep", "360000000" ]
