FROM gcc:9.4.0 AS builder

LABEL maintainer="Free5GC <support@free5gc.org>"

ENV DEBIAN_FRONTEND noninteractive

ARG CACHEBUST=1
LABEL build_version=${CACHEBUST}

# Install dependencies + my own version of UERANSIM
RUN apt-get update \
    && apt-get install libsctp-dev lksctp-tools iproute2 -y \
    && wget https://github.com/Kitware/CMake/releases/download/v3.22.1/cmake-3.22.1-linux-x86_64.sh -O cmake_installer.sh \
    && chmod +x cmake_installer.sh \
    && ./cmake_installer.sh --skip-license \
    && git clone -b master -j `nproc` https://github.com/Chiller2121/UERANSIM-5g-relays \
    && cd ./UERANSIM-5g-relays \
    && make

FROM bitnami/minideb:bullseye

ENV DEBIAN_FRONTEND noninteractive

# Install runtime dependencies + ping + dnsutils
RUN apt-get update \
    && apt-get install libsctp-dev lksctp-tools iproute2 iputils-ping procps psmisc -y dnsutils \
    && apt-get clean

WORKDIR /ueransim-5g-relays

RUN mkdir -p config/ binder/

COPY --from=builder /UERANSIM-5g-relays/build/nr-rgnb .
COPY --from=builder /UERANSIM-5g-relays/build/nr-cli .
COPY --from=builder /UERANSIM-5g-relays/build/nr-binder binder/
COPY --from=builder /UERANSIM-5g-relays/build/libdevbnd.so binder/

VOLUME [ "/ueransim-5g-relays/config" ]
