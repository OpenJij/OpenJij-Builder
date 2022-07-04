FROM --platform=linux/x86_64 quay.io/pypa/manylinux_2_28_x86_64:latest AS manylinux_2_28

FROM manylinux_2_28 AS intel-one-api-install
RUN \ 
  --mount=type=bind,target=/etc/yum.repos.d/oneAPI.repo,source=oneAPI.repo \ 
  --mount=type=cache,target=/var/cache/dnf \
  --mount=type=cache,target=/var/lib/dnf \
  dnf -y install intel-basekit intel-hpckit

FROM intel-one-api-config-install AS intel-one-api-configure

RUN . /opt/intel/oneapi/compiler/latest/env/vars.sh 
RUN . /opt/intel/oneapi/mkl/latest/env/vars.sh
RUN --mount=type=bind,target=/tmp/config.txt,source=config.txt . /opt/intel/oneapi/setvars.sh --force  --config="/tmp/config.txt"
ENV CC=icx
ENV CXX=icpx
ENV FC=ifx
ENV CFLAGS='-march=haswell -mtune=skylake -fp-model=fast=2' 
ENV CXXFLAGS='-march=haswell -mtune=skylake -fp-model=fast=2' 
ENV FFLAGS='-march=haswell -mtune=skylake -fp-model=fast=2'

FROM intel-one-api-configure AS config-txt
COPY config.txt /tmp/config.txt
RUN export

FROM config-txt AS eigen3-devel

RUN \ 
  --mount=type=cache,target=/var/cache/dnf \
  --mount=type=cache,target=/var/lib/dnf \
  dnf config-manager --set-enabled powertools && 
  dnf -y --enablerepo=powertools install eigen3-devel

FROM eigen3-devel AS openjij-builder
