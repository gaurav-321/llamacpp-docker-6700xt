FROM rocm/dev-ubuntu-24.04:7.0-complete

ARG LLAMACPP_REPO=https://github.com/ggml-org/llama.cpp.git
ARG LLAMACPP_BRANCH=master
ARG LLAMACPP_ROCM_ARCH=gfx1030

ENV DEBIAN_FRONTEND=noninteractive
ENV HSA_OVERRIDE_GFX_VERSION=10.3.0
ENV HIP_VISIBLE_DEVICES=0
ENV LLAMACPP_ROCM_ARCH=${LLAMACPP_ROCM_ARCH}

RUN apt-get update && apt-get install -y \
    git \
    cmake \
    ninja-build \
    build-essential \
    libcurl4-openssl-dev \
    ca-certificates \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

RUN git clone --depth 1 --branch ${LLAMACPP_BRANCH} ${LLAMACPP_REPO} llama.cpp

WORKDIR /workspace/llama.cpp

RUN HIPCXX="$(hipconfig -l)/clang" HIP_PATH="$(hipconfig -R)" \
    cmake -S . -B build -G Ninja \
      -DGGML_HIP=ON \
      -DAMDGPU_TARGETS=${LLAMACPP_ROCM_ARCH} \
      -DCMAKE_BUILD_TYPE=Release \
      -DLLAMA_CURL=ON \
 && cmake --build build -j$(nproc)

EXPOSE 8080

CMD ["/workspace/llama.cpp/build/bin/llama-server"]
