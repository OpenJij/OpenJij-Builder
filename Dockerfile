FROM --platform=linux/x86_64 quay.io/pypa/manylinux_2_28_x86_64:latest AS manylinux_2_28
COPY config.txt /tmp/config.txt
RUN \ 
  --mount=type=tmpfs,target=/var/cache/dnf \
  --mount=type=tmpfs,target=/var/lib/dnf \
  dnf config-manager --set-enabled powertools && \
  dnf -y --enablerepo=powertools install eigen3-devel && \ 
  dnf -y clean all

#全部入り

FROM manylinux_2_28 AS openjij-builder
RUN \ 
  --mount=type=bind,target=/etc/yum.repos.d/oneAPI.repo,source=oneAPI.repo \ 
  --mount=type=tmpfs,target=/var/cache/dnf \
  --mount=type=tmpfs,target=/var/lib/dnf \
  dnf -y repository-packages "oneAPI" list --available && \
  dnf -y install intel-basekit intel-hpckit && \ 
  dnf -y clean all

#軽量バージョン

FROM manylinux_2_28 AS openjij-builder-minimum 
RUN \ 
  --mount=type=bind,target=/etc/yum.repos.d/oneAPI.repo,source=oneAPI.repo \ 
  --mount=type=tmpfs,target=/var/cache/dnf \
  --mount=type=tmpfs,target=/var/lib/dnf \
  dnf -y install \ 
  intel-oneapi-compiler-dpcpp-cpp-and-cpp-classic \ 
  intel-oneapi-compiler-fortran \ 
  intel-oneapi-mkl \ 
  intel-oneapi-mkl-devel \ 
  intel-oneapi-openmp && \ 
  dnf -y clean all

#古いバージョン
FROM --platform=linux/x86_64 quay.io/pypa/manylinux2014_x86_64:latest AS manylinux2014
COPY config.txt /tmp/config.txt
RUN \ 
  --mount=type=tmpfs,target=/var/cache/yum \
  --mount=type=tmpfs,target=/var/lib/yum \
  yum -y install eigen3-devel

#全部入り

FROM manylinux2014 AS openjij-builder-old
RUN \ 
  --mount=type=bind,target=/etc/yum.repos.d/oneAPI.repo,source=oneAPI.repo \ 
  --mount=type=tmpfs,target=/var/cache/yum \
  --mount=type=tmpfs,target=/var/lib/yum \
  yum -y install intel-basekit intel-hpckit

#軽量バージョン

FROM manylinux2014 AS openjij-builder-old-minimum
RUN \ 
  --mount=type=bind,target=/etc/yum.repos.d/oneAPI.repo,source=oneAPI.repo \ 
  --mount=type=tmpfs,target=/var/cache/yum \
  --mount=type=tmpfs,target=/var/lib/yum \
  yum -y install \
  intel-oneapi-compiler-dpcpp-cpp-and-cpp-classic \ 
  intel-oneapi-compiler-fortran \ 
  intel-oneapi-mkl \ 
  intel-oneapi-mkl-devel \ 
  intel-oneapi-openmp
