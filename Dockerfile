FROM --platform=linux/x86_64 quay.io/pypa/manylinux_2_28_x86_64:latest AS manylinux_2_28

FROM manylinux_2_28 AS intel-one-api-install
RUN \ 
  --mount=type=bind,target=/etc/yum.repos.d/oneAPI.repo,source=oneAPI.repo \ 
  --mount=type=cache,target=/var/cache/dnf \
  --mount=type=cache,target=/var/lib/dnf \
  dnf -y install intel-basekit intel-hpckit && \ 
  dnf clean all

FROM intel-one-api-install AS intel-one-api-configure

ONBUILD COPY config.txt /tmp/config.txt

FROM intel-one-api-configure AS config-txt

RUN export

FROM config-txt AS eigen3-devel

RUN \ 
  --mount=type=cache,target=/var/cache/dnf \
  --mount=type=cache,target=/var/lib/dnf \
  dnf config-manager --set-enabled powertools && \
  dnf -y --enablerepo=powertools install eigen3-devel && \ 
  dnf clean all

FROM eigen3-devel AS openjij-builder

FROM manylinux_2_28 AS intel-one-api-install-minimum

RUN \ 
  --mount=type=bind,target=/etc/yum.repos.d/oneAPI.repo,source=oneAPI.repo \ 
  --mount=type=cache,target=/var/cache/dnf \
  --mount=type=cache,target=/var/lib/dnf \
  dnf repository-packages "oneAPI" list --available
  
RUN \ 
  --mount=type=bind,target=/etc/yum.repos.d/oneAPI.repo,source=oneAPI.repo \ 
  --mount=type=cache,target=/var/cache/dnf \
  --mount=type=cache,target=/var/lib/dnf \
  dnf -y install \ 
  intel-oneapi-compiler-dpcpp-cpp-and-cpp-classic \ 
  intel-oneapi-compiler-fortran \ 
  intel-oneapi-mkl && \ 
  dnf clean all

FROM intel-one-api-install-minimum AS intel-one-api-configure-minimum

ONBUILD COPY config.txt /tmp/config.txt

FROM intel-one-api-configure-minimum AS config-txt-minimum

RUN export

FROM config-txt-minimum AS eigen3-devel-minimum

RUN \ 
  --mount=type=cache,target=/var/cache/dnf \
  --mount=type=cache,target=/var/lib/dnf \
  dnf config-manager --set-enabled powertools && \
  dnf -y --enablerepo=powertools install eigen3-devel && \ 
  dnf clean all

FROM eigen3-devel-minimum AS openjij-builder-minimum

FROM --platform=linux/x86_64 quay.io/pypa/manylinux2014_x86_64:latest AS manylinux2014

FROM manylinux2014 AS intel-one-api-install-old
RUN \ 
  --mount=type=bind,target=/etc/yum.repos.d/oneAPI.repo,source=oneAPI.repo \ 
  --mount=type=cache,target=/var/cache/yum \
  --mount=type=cache,target=/var/lib/yum \
  yum -y install intel-basekit intel-hpckit

FROM intel-one-api-install-old AS intel-one-api-configure-old

ONBUILD COPY config.txt /tmp/config.txt

FROM intel-one-api-configure-old AS config-txt-old

RUN export

FROM config-txt-old AS eigen3-devel-old

RUN \ 
  --mount=type=cache,target=/var/cache/yum \
  --mount=type=cache,target=/var/lib/yum \
  yum -y install eigen3-devel

FROM eigen3-devel-old AS openjij-builder-old
