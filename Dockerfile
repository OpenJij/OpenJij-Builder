FROM --platform=linux/x86_64 quay.io/pypa/manylinux_2_28_x86_64:latest AS manylinux_2_28

FROM manylinux_2_28 AS intel-one-api-install
RUN \ 
  --mount=type=bind,target=/etc/yum.repos.d/oneAPI.repo,source=oneAPI.repo \ 
  --mount=type=cache,target=/var/cache/dnf \
  --mount=type=cache,target=/var/lib/dnf \
  dnf -y install intel-basekit intel-hpckit

FROM intel-one-api-config-install AS intel-one-api-configure

ONBUILD COPY config.txt /tmp/config.txt

FROM intel-one-api-configure AS config-txt

RUN export

FROM config-txt AS eigen3-devel

RUN \ 
  --mount=type=cache,target=/var/cache/dnf \
  --mount=type=cache,target=/var/lib/dnf \
  dnf config-manager --set-enabled powertools && 
  dnf -y --enablerepo=powertools install eigen3-devel

FROM eigen3-devel AS openjij-builder
