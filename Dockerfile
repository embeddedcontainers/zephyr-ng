FROM debian:12.11-slim

WORKDIR /workdir

# 1. OS dependencies and packages

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
  apt-get -y update \
  && apt-get -y install --no-install-recommends \
  ca-certificates \
  ccache \
  cmake \
  device-tree-compiler \
  git \
  ninja-build \
  python3 python3-pip python3-venv \
  wget \
  xz-utils \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# 2. Zephyr SDK

ARG ZEPHYR_SDK_VERSION=0.17.1
ARG ZEPHYR_SDK_INSTALL_DIR=/opt/toolchains/zephyr-sdk-${ZEPHYR_SDK_VERSION}
ARG ZEPHYR_SDK_TOOLCHAINS="-t arm-zephyr-eabi"

RUN --mount=type=cache,target=/var/cache/zephyr-sdk-downloads \
  export sdk_file_name="zephyr-sdk-${ZEPHYR_SDK_VERSION}_linux-$(uname -m)_minimal.tar.xz" \
  && wget -q "https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${ZEPHYR_SDK_VERSION}/${sdk_file_name}" \
  && mkdir -p ${ZEPHYR_SDK_INSTALL_DIR} \
  && tar -xvf ${sdk_file_name} -C ${ZEPHYR_SDK_INSTALL_DIR} --strip-components=1 \
  && rm ${sdk_file_name} \
  && ${ZEPHYR_SDK_INSTALL_DIR}/setup.sh -c ${ZEPHYR_SDK_TOOLCHAINS}

# 3. Python Virtual Environment

ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

RUN --mount=type=cache,target=/root/.cache/pip \
  pip install --no-cache-dir wheel west