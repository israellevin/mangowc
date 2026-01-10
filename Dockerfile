# Dockerfile to build mangowc and its dependencies from source on Debian.

FROM debian:sid

RUN mkdir /artifacts

RUN apt-get update
RUN apt-get install -y \
    cmake \
    git \
    meson \
    pkgconf \
    glslang-tools \
    hwdata \
    libcairo2-dev \
    libdisplay-info-dev \
    libdrm-dev \
    libegl-dev \
    libgbm-dev \
    libgles-dev \
    libinput-dev \
    liblcms2-dev \
    libliftoff-dev \
    libpixman-1-dev \
    libseat-dev \
    libudev-dev \
    libvulkan-dev \
    libwayland-dev \
    libxcb-composite0-dev \
    libxcb-dri3-dev \
    libxcb-errors-dev \
    libxcb-ewmh-dev \
    libxcb-icccm4-dev \
    libxcb-present-dev \
    libxcb-render-util0-dev \
    libxcb-res0-dev \
    libxcb-shm0-dev \
    libxcb-xinput-dev \
    libxkbcommon-dev \
    wayland-protocols \
    xwayland

# Build wlroots.
WORKDIR /root
RUN git clone --depth 1 --branch 0.19.2 https://gitlab.freedesktop.org/wlroots/wlroots.git
WORKDIR /root/wlroots
RUN meson build
RUN ninja -C build install

RUN cp -a --parents \
    /usr/local/include/wlroots-* \
    /usr/local/lib/x86_64-linux-gnu/libwlroots-* \
    /usr/local/lib/x86_64-linux-gnu/pkgconfig/wlroots-* \
    /artifacts/.

# Build scenefx.
WORKDIR /root
RUN git clone --depth 1 -b 0.4.1 https://github.com/wlrfx/scenefx.git
WORKDIR /root/scenefx
RUN meson build
RUN ninja -C build install

RUN cp -a --parents \
    /usr/local/include/scenefx-* \
    /usr/local/lib/x86_64-linux-gnu/libscenefx-* \
    /usr/local/lib/x86_64-linux-gnu/pkgconfig/scenefx-* \
    /artifacts/.

# Use `docker build --build-arg NEW_MANGO=$(date +%s)` to force rebuild from here.
ARG NEW_MANGO=date

# Build mangowc.
WORKDIR /root
RUN git clone -b master https://github.com/israellevin/mangowc.git
WORKDIR /root/mangowc
RUN meson build
RUN ninja -C build install

RUN cp -a --parents \
    /usr/local/bin/mango \
    /usr/local/bin/mmsg \
    /usr/local/etc/mango/config.conf \
    /artifacts/.

# Serve the artifacts directory all tarred up.
RUN apt install -y netcat-openbsd
EXPOSE 8000
CMD sh -c '( \
    printf "HTTP/1.0 200 OK\r\nContent-Type: application/x-tar\r\n\r\n"; \
    tar -C /artifacts -cf - . \; \
    echo \
) | nc -lp8000 -q0'
