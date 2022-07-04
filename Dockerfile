FROM --platform=linux/x86_64 quay.io/pypa/manylinux_2_28_x86_64:2022-06-26-9a2ca4b AS manylinux_2_28

FROM manylinux_2_28 AS eigen3-devel

RUN dnf config-manager --set-enabled powertools
RUN dnf -y --enablerepo=powertools install eigen3-devel

FROM --platform=linux/x86_64 eigen3-devel AS intel-one-api-config-file

COPY oneAPI.repo /etc/yum.repos.d/

FROM intel-one-api-config-file AS intel-one-api-config-install
RUN dnf -y install intel-basekit intel-hpckit

FROM intel-one-api-config-install AS intel-one-api-configure

COPY config.txt /tmp/
RUN source /opt/intel/oneapi/compiler/latest/env/vars.sh 
RUN source /opt/intel/oneapi/mkl/latest/env/vars.sh
RUN source /opt/intel/oneapi/setvars.sh --force  --config="/tmp/config.txt"
ENV CC=icx
ENV CXX=icpx
ENV FC=ifx
ENV CFLAGS='-march=haswell -mtune=skylake -fp-model=fast=2' 
ENV CXXFLAGS='-march=haswell -mtune=skylake -fp-model=fast=2' 
ENV FFLAGS='-march=haswell -mtune=skylake -fp-model=fast=2'

FROM intel-one-api-configure AS test
RUN export

FROM test AS jij-builder

