# Download extra binaries needed by 'kubeasz'
# @author:  gjmzj
# @repo:    https://github.com/easzlab/dockerfile-kubeasz-ext-bin
# @ref:     https://github.com/kubernetes/kubernetes/blob/master/build/dependencies.yaml

# downloader use ubuntu:22.04
FROM alpine:3.22 as downloader
ENV CNI_VER=v1.9.1
ENV RUNC_VER=v1.5.2
ENV CONTAINERD_VER=2.3.7
ENV CALICOCTL_VER=v3.32.2
ENV CILIUM_CLI_VER=v0.20.1
ENV HUBBLE_CLI_VER=v1.20.2
ENV HELM_VER=v4.3.1
ENV CRICTL_VER=v1.37.0
ENV DOCKER_COMPOSE_VER=v5.6.1
COPY multi-platform-download.sh .
RUN  sh -x ./multi-platform-download.sh

# release image
FROM alpine:3.22
ENV EXT_BIN_VER=1.14.3

# https://github.com/etcd-io/etcd
COPY --from=quay.io/coreos/etcd:v3.7.3 /usr/local/bin/etcdutl /usr/local/bin/etcdctl /usr/local/bin/etcd /extra/
COPY --from=easzlab/kubeasz-ext-build:1.3.0 /ext-bin/* /extra/
COPY --from=easzlab/kubeasz-ext-build:1.5.0 /ext-bin/cfssl* /extra/
COPY --from=apecloud/minio:RELEASE.2025-10-15T17-29-55Z /bin/minio /bin/mc /extra/
COPY --from=downloader /ext-bin/* /extra/
COPY --from=downloader /extra/containerd-bin/* /extra/containerd-bin/
COPY --from=downloader /extra/cni-bin/* /extra/cni-bin/

CMD [ "sleep", "360000000" ]
