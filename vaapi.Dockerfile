FROM ghcr.io/linuxserver/baseimage-ubuntu:noble AS devel-base

ENV DEBIAN_FRONTEND="noninteractive"
ENV MAKEFLAGS="-j4"

ARG LIBVA=2.22.0
ENV AOM=v3.12.0 \
    FDKAAC=2.0.3 \
    FFMPEG_HARD=7.1.1 \
    FONTCONFIG=2.16.0 \
    FREETYPE=2.13.3 \
    FRIBIDI=1.0.16 \
    GMMLIB=22.3.20 \
    IHD=24.2.5 \
    KVAZAAR=2.3.1 \
    LAME=3.100 \
    LIBASS=0.17.3 \
    LIBDAV1D=1.5.1 \
    LIBDRM=2.4.124 \
    LIBSRT=1.5.4 \
    LIBVA=$LIBVA \
    LIBVDPAU=1.5 \
    LIBVIDSTAB=1.1.1 \
    LIBWEBP=1.5.0 \
    OGG=1.3.5 \
    OPENCOREAMR=0.1.6 \
    OPENJPEG=2.5.3 \
    OPUS=1.5.2 \
    THEORA=1.1.1 \
    VORBIS=1.3.7 \
    VPX=1.15.0 \
    X265=4.1 \
    XVID=1.3.7 \
    ZIMG=3.0.5

RUN apt-get -yqq update && \
    apt-get install -y gpg-agent wget && \
    wget -qO - https://repositories.intel.com/gpu/intel-graphics.key | \
    gpg --dearmor --output /usr/share/keyrings/intel-graphics.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/intel-graphics.gpg] https://repositories.intel.com/gpu/ubuntu noble unified" | \
    tee  /etc/apt/sources.list.d/intel.gpu.noble.list && \
    apt-get -yqq update && \
    apt-get install -yq \
    libmfx-dev \
    libegl1-mesa-dev \
    libgl1-mesa-dev \
    libgles2-mesa-dev \
    libigc-dev \
    intel-igc-cm \
    libigdfcl-dev \
    libigfxcmrt-dev \
    level-zero-dev \
    libvpl-dev && \
    apt-get -yq --no-install-recommends install -y \
    autoconf \
    automake \
    bzip2 \
    ca-certificates \
    cmake \
    curl \
    diffutils \
    doxygen \
    expat \
    g++ \
    gcc \
    git \
    gperf \
    libexpat1-dev \
    libxext-dev \
    libgcc-9-dev \
    libgomp1 \
    libharfbuzz-dev \
    libpciaccess-dev \
    libssl-dev \
    libtool \
    libv4l-dev \
    libx11-dev \
    libxcb-shape0-dev \
    libxml2-dev \
    make \
    meson \
    nasm \
    ninja-build \
    ocl-icd-opencl-dev \
    patch \
    perl \
    pkg-config \
    python3 \
    python3-pip\
    python3-setuptools \
    python3-wheel \
    x11proto-xext-dev \
    xserver-xorg-dev \
    xz-utils \
    yasm \
    zlib1g-dev && \
    apt-get autoremove -y && \
    apt-get clean -y

# aom
RUN mkdir -p /tmp/aom && \
    git clone \
    --branch ${AOM} \
    --depth 1 https://aomedia.googlesource.com/aom \
    /tmp/aom
RUN cd /tmp/aom && \
    rm -rf \
    CMakeCache.txt \
    CMakeFiles && \
    mkdir -p \
    aom_build && \
    cd aom_build && \
    cmake \
    -DBUILD_STATIC_LIBS=0 .. && \
    make && \
    make install

# dav1d
RUN mkdir -p /tmp/dav1d && \
    git clone \
    --branch ${LIBDAV1D} \
    --depth 1 https://github.com/videolan/dav1d.git \
    /tmp/dav1d
RUN mkdir /tmp/dav1d/build && cd /tmp/dav1d/build && \
    meson setup -Denable_tools=false -Denable_tests=false --libdir /usr/local/lib .. && \
    ninja && \
    ninja install

# fdk-aac
RUN mkdir -p /tmp/fdk-aac && \
    curl -Lf \
    https://github.com/mstorsjo/fdk-aac/archive/v${FDKAAC}.tar.gz | \
    tar -zx --strip-components=1 -C /tmp/fdk-aac
RUN cd /tmp/fdk-aac && \
    autoreconf -fiv && \
    ./configure \
    --disable-static \
    --enable-shared && \
    make && \
    make install

# freetype
RUN mkdir -p /tmp/freetype && \
    curl -Lf \
    https://download.savannah.gnu.org/releases/freetype/freetype-${FREETYPE}.tar.gz | \
    tar -zx --strip-components=1 -C /tmp/freetype
RUN cd /tmp/freetype && \
    ./configure \
    --disable-static \
    --enable-shared && \
    make && \
    make install

# fontconfig
RUN mkdir -p /tmp/fontconfig && \
    curl -Lf \
    https://www.freedesktop.org/software/fontconfig/release/fontconfig-${FONTCONFIG}.tar.xz | \
    tar -Jx --strip-components=1 -C /tmp/fontconfig
RUN cd /tmp/fontconfig && \
    ./configure \
    --disable-static \
    --enable-shared && \
    make && \
    make install

# fribidi
RUN mkdir -p /tmp/fribidi && \
    curl -Lf \
    https://github.com/fribidi/fribidi/archive/v${FRIBIDI}.tar.gz | \
    tar -zx --strip-components=1 -C /tmp/fribidi
RUN cd /tmp/fribidi && \
    ./autogen.sh && \
    ./configure \
    --disable-static \
    --enable-shared && \
    make -j 1 && \
    make install

# kvazaar
RUN mkdir -p /tmp/kvazaar && \
    curl -Lf \
    https://github.com/ultravideo/kvazaar/archive/v${KVAZAAR}.tar.gz | \
    tar -zx --strip-components=1 -C /tmp/kvazaar
RUN cd /tmp/kvazaar && \
    ./autogen.sh && \
    ./configure \
    --disable-static \
    --enable-shared && \
    make && \
    make install

# lame
RUN mkdir -p /tmp/lame && \
    curl -Lf \
    http://downloads.sourceforge.net/project/lame/lame/3.100/lame-${LAME}.tar.gz | \
    tar -zx --strip-components=1 -C /tmp/lame
RUN cd /tmp/lame && \
    cp \
    /usr/share/automake-1.16/config.guess \
    config.guess && \
    cp \
    /usr/share/automake-1.16/config.sub \
    config.sub && \
    ./configure \
    --disable-frontend \
    --disable-static \
    --enable-nasm \
    --enable-shared && \
    make && \
    make install

# libass
RUN mkdir -p /tmp/libass && \
    curl -Lf \
    https://github.com/libass/libass/archive/${LIBASS}.tar.gz | \
    tar -zx --strip-components=1 -C /tmp/libass
RUN cd /tmp/libass && \
    ./autogen.sh && \
    ./configure \
    --disable-static \
    --enable-shared && \
    make && \
    make install

# libdrm
RUN mkdir -p /tmp/libdrm && \
    curl -Lf \
    https://dri.freedesktop.org/libdrm/libdrm-${LIBDRM}.tar.xz | \
    tar -Jx --strip-components=1 -C /tmp/libdrm
RUN cd /tmp/libdrm && \
    meson setup \
    --prefix=/usr --libdir=/usr/local/lib/x86_64-linux-gnu \
    -Dvalgrind=disabled \
    . build && \
    ninja -C build && \
    ninja -C build install && \
    strip -d /usr/local/lib/x86_64-linux-gnu/libdrm*.so

# libsrt
RUN mkdir -p /tmp/libsrt && \
    curl -Lf \
    https://github.com/Haivision/srt/archive/v${LIBSRT}.tar.gz | \
    tar -zx --strip-components=1 -C /tmp/libsrt
RUN cd /tmp/libsrt && \
    cmake . && \
    make && \
    make install

# libva
RUN mkdir -p /tmp/libva && \
    git clone \
    --branch master \
    --depth 1 https://github.com/intel/libva.git \
    /tmp/libva
    #curl -Lf \
    #https://github.com/intel/libva/archive/${LIBVA}.tar.gz | \
    #tar -zx --strip-components=1 -C /tmp/libva
RUN cd /tmp/libva && \
    ./autogen.sh && \
    ./configure \
    --disable-static \
    --enable-shared && \
    make && \
    make install

# libvdpau
RUN mkdir -p /tmp/libvdpau && \
    git clone \
    --branch ${LIBVDPAU} \
    --depth 1 https://gitlab.freedesktop.org/vdpau/libvdpau.git \
    /tmp/libvdpau
RUN cd /tmp/libvdpau && \
    meson setup \
    --prefix=/usr --libdir=/usr/local/lib \
    -Ddocumentation=false build && \
    ninja -C build install

# gmm
RUN mkdir -p /tmp/gmmlib && \
    curl -Lf \
    https://github.com/intel/gmmlib/archive/refs/tags/intel-gmmlib-${GMMLIB}.tar.gz | \
    tar -zx --strip-components=1 -C /tmp/gmmlib
RUN mkdir -p /tmp/gmmlib/build && \
    cd /tmp/gmmlib/build && \
    cmake \
    -DCMAKE_BUILD_TYPE=Release \
    .. && \
    make && \
    make install && \
    strip -d /usr/local/lib/libigdgmm.so

# iHD
RUN mkdir -p /tmp/ihd && \
    curl -Lf \
    https://github.com/intel/media-driver/archive/refs/tags/intel-media-${IHD}.tar.gz | \
    tar -zx --strip-components=1 -C /tmp/ihd
RUN mkdir -p /tmp/ihd/build && \
    cd /tmp/ihd/build && \
    cmake \
    -DLIBVA_DRIVERS_PATH=/usr/local/lib/x86_64-linux-gnu/dri/ \
    .. && \
    make && \
    make install && \
    strip -d /usr/local/lib/x86_64-linux-gnu/dri/iHD_drv_video.so

# libwebp
RUN mkdir -p /tmp/libwebp && \
    curl -Lf \
    https://storage.googleapis.com/downloads.webmproject.org/releases/webp/libwebp-${LIBWEBP}.tar.gz | \
    tar -zx --strip-components=1 -C /tmp/libwebp
RUN cd /tmp/libwebp && \
    ./configure \
    --disable-static \
    --enable-shared && \
    make && \
    make install

# ogg
RUN mkdir -p /tmp/ogg && \
    curl -Lf \
    http://downloads.xiph.org/releases/ogg/libogg-${OGG}.tar.gz | \
    tar -zx --strip-components=1 -C /tmp/ogg
RUN cd /tmp/ogg && \
    ./configure \
    --disable-static \
    --enable-shared && \
    make && \
    make install

# opencore-amr
RUN mkdir -p /tmp/opencore-amr && \
    curl -Lf \
    http://downloads.sourceforge.net/project/opencore-amr/opencore-amr/opencore-amr-${OPENCOREAMR}.tar.gz | \
    tar -zx --strip-components=1 -C /tmp/opencore-amr
RUN cd /tmp/opencore-amr && \
    ./configure \
    --disable-static \
    --enable-shared  && \
    make && \
    make install

# openjpeg
RUN mkdir -p /tmp/openjpeg && \
    curl -Lf \
    https://github.com/uclouvain/openjpeg/archive/v${OPENJPEG}.tar.gz | \
    tar -zx --strip-components=1 -C /tmp/openjpeg
RUN cd /tmp/openjpeg && \
    rm -Rf \
    thirdparty/libpng/* && \
    curl -Lf \
    https://download.sourceforge.net/libpng/libpng-1.6.37.tar.gz | \
    tar -zx --strip-components=1 -C thirdparty/libpng/ && \
    cmake \
    -DBUILD_STATIC_LIBS=0 \
    -DBUILD_THIRDPARTY:BOOL=ON . && \
    make && \
    make install

# opus
RUN mkdir -p /tmp/opus && \
    curl -Lf \
    https://downloads.xiph.org/releases/opus/opus-${OPUS}.tar.gz | \
    tar -zx --strip-components=1 -C /tmp/opus
RUN cd /tmp/opus && \
    autoreconf -fiv && \
    ./configure \
    --disable-static \
    --enable-shared && \
    make && \
    make install

# theora
RUN mkdir -p /tmp/theora && \
    curl -Lf \
    http://downloads.xiph.org/releases/theora/libtheora-${THEORA}.tar.gz | \
    tar -zx --strip-components=1 -C /tmp/theora
RUN cd /tmp/theora && \
    cp \
    /usr/share/automake-1.16/config.guess \
    config.guess && \
    cp \
    /usr/share/automake-1.16/config.sub \
    config.sub && \
    curl -fL \
    'https://gitlab.xiph.org/xiph/theora/-/commit/7288b539c52e99168488dc3a343845c9365617c8.diff' \
    > png.patch && \
    patch ./examples/png2theora.c < png.patch && \
    ./configure \
    --disable-static \
    --enable-shared && \
    make && \
    make install

# vid.stab
RUN mkdir -p /tmp/vid.stab && \
    curl -Lf \
    https://github.com/georgmartius/vid.stab/archive/v${LIBVIDSTAB}.tar.gz | \
    tar -zx --strip-components=1 -C /tmp/vid.stab
RUN cd /tmp/vid.stab && \
    cmake \
    -DBUILD_STATIC_LIBS=0 . && \
    make && \
    make install

# vorbis
RUN mkdir -p /tmp/vorbis && \
    curl -Lf \
    http://downloads.xiph.org/releases/vorbis/libvorbis-${VORBIS}.tar.gz | \
    tar -zx --strip-components=1 -C /tmp/vorbis
RUN cd /tmp/vorbis && \
    ./configure \
    --disable-static \
    --enable-shared && \
    make && \
    make install

# vpx
RUN mkdir -p /tmp/vpx && \
    curl -Lf \
    https://github.com/webmproject/libvpx/archive/v${VPX}.tar.gz | \
    tar -zx --strip-components=1 -C /tmp/vpx
RUN cd /tmp/vpx && \
    ./configure \
    --disable-debug \
    --disable-docs \
    --disable-examples \
    --disable-install-bins \
    --disable-static \
    --disable-unit-tests \
    --enable-pic \
    --enable-shared \
    --enable-vp8 \
    --enable-vp9 \
    --enable-vp9-highbitdepth && \
    make && \
    make install

# x264
RUN mkdir -p /tmp/x264 && \
    git clone --branch stable --depth 1 https://github.com/mirror/x264 /tmp/x264
RUN cd /tmp/x264 && \
    ./configure \
    --disable-cli \
    --disable-static \
    --enable-pic \
    --enable-shared && \
    make && \
    make install

# x265
RUN mkdir -p /tmp/x265 && \
    curl -Lf \
    https://bitbucket.org/multicoreware/x265_git/downloads/x265_${X265}.tar.gz | \
    tar -zx --strip-components=1 -C /tmp/x265
RUN cd /tmp/x265/build/linux && \
    ./multilib.sh && \
    make -C 8bit install

# xvid
RUN mkdir -p /tmp/xvid && \
    curl -Lf \
    https://downloads.xvid.com/downloads/xvidcore-${XVID}.tar.gz | \
    tar -zx --strip-components=1 -C /tmp/xvid
RUN cd /tmp/xvid/build/generic && \
    ./configure && \ 
    make && \
    make install

# zimg
RUN mkdir -p /tmp/zimg && \
    git clone \
    --branch release-${ZIMG} --depth 1 \
    https://github.com/sekrit-twc/zimg.git \
    /tmp/zimg
RUN cd /tmp/zimg && \
    ./autogen.sh && \
    ./configure \
    --disable-static \
    --enable-shared && \
    make && \
    make install

# ffmpeg
RUN if [ -z ${FFMPEG_VERSION+x} ]; then \
   FFMPEG=${FFMPEG_HARD}; \
   else \
   FFMPEG=${FFMPEG_VERSION}; \
   fi && \
   mkdir -p /tmp/ffmpeg && \
   echo "https://ffmpeg.org/releases/ffmpeg-${FFMPEG}.tar.bz2" && \
   curl -Lf \
   https://ffmpeg.org/releases/ffmpeg-${FFMPEG}.tar.bz2 | \
   tar -jx --strip-components=1 -C /tmp/ffmpeg

RUN cd /tmp/ffmpeg && \
    ./configure \
    --disable-debug \
    --disable-doc \
    --disable-ffplay \
    --enable-ffprobe \
    --enable-fontconfig \
    --enable-gpl \
    --enable-libaom \
    --enable-libdav1d \
    --enable-libass \
    --enable-libfdk_aac \
    --enable-libfreetype \
    --enable-libkvazaar \
    --enable-libvpl \
    --enable-libmp3lame \
    --enable-libopencore-amrnb \
    --enable-libopencore-amrwb \
    --enable-libopenjpeg \
    --enable-libopus \
    --enable-libsrt \
    --enable-libtheora \
    --enable-libv4l2 \
    --enable-libvidstab \
    --enable-libvorbis \
    --enable-libvpx \
    --enable-libwebp \
    --enable-libxml2 \
    --enable-libx264 \
    --enable-libx265 \
    --enable-libxvid \
    --enable-libzimg \
    --enable-nonfree \
    --enable-opencl \
    --enable-openssl \
    --enable-small \
    --enable-stripping \
    --enable-vaapi \
    --enable-vdpau \
    --enable-version3 \
    --extra-libs=-ldl \
    --extra-libs=-lpthread && \
    make

RUN ldconfig && \
    mkdir -p \
    /buildout/usr/local/bin \
    /buildout/usr/lib \
    /buildout/usr/local/lib/x86_64-linux-gnu/dri \
    /buildout/usr/local/lib/x86_64-linux-gnu/vdpau \
    /buildout/usr/share/libdrm && \
    cp \
    /tmp/ffmpeg/ffmpeg \
    /buildout/usr/local/bin && \
    cp \
    /tmp/ffmpeg/ffprobe \
    /buildout/usr/local/bin && \
    cp -a \
    /usr/local/lib/lib*so* \
    /buildout/usr/local/lib/ && \
    cp -a \
    /usr/local/lib/x86_64-linux-gnu/lib*so* \
    /buildout/usr/local/lib/x86_64-linux-gnu/ && \
    cp -a \
    /usr/local/lib/x86_64-linux-gnu/dri/*.so \
    /buildout/usr/local/lib/x86_64-linux-gnu/dri/ && \
    #cp -a \
    #/usr/local/lib/x86_64-linux-gnu/vdpau/*.so \
    #/buildout/usr/local/lib/x86_64-linux-gnu/vdpau/ && \
    cp -a \
    /usr/share/libdrm/amdgpu.ids \
    /buildout/usr/share/libdrm/ && \
    ldd /tmp/ffmpeg/ffmpeg \
    | awk '/local/ {print $3}' \
    | xargs -i cp -L {} /buildout/usr/lib/

FROM ghcr.io/linuxserver/baseimage-ubuntu:noble AS runtime-base

ENV MAKEFLAGS="-j4" \
    LIBVA_DRIVERS_PATH="/usr/lib/x86_64-linux-gnu/dri" \
    LD_LIBRARY_PATH="/usr/lib/x86_64-linux-gnu" \
    LIBVA_MESSAGING_LEVEL=0 \
    LIBVA_DISPLAY=drm

RUN apt-get -yqq update && \
    apt-get install -yq --no-install-recommends ca-certificates expat libgomp1 libharfbuzz-bin libxcb-shape0 libv4l-0 \
    && apt autoremove -y \
    && rm -rf /var/lib/apt/lists/*

COPY --from=devel-base /buildout/ /

RUN apt-get -yqq update && \
    DEBIAN_FRONTEND="noninteractive" apt-get install -y gpg-agent wget && \
    wget -qO - https://repositories.intel.com/gpu/intel-graphics.key | \
    gpg --dearmor --output /usr/share/keyrings/intel-graphics.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/intel-graphics.gpg] https://repositories.intel.com/gpu/ubuntu noble unified" | \
    tee  /etc/apt/sources.list.d/intel.gpu.noble.list && \
    apt-get -yqq update && \
    DEBIAN_FRONTEND="noninteractive" apt-get install -yq \
    tzdata \
    fontconfig \
    fonts-noto-core \
    fonts-noto-cjk \
    libgdiplus \
    intel-opencl-icd=24.26.30049.10-950~24.04 intel-level-zero-gpu level-zero libze1 \
    libmfxgen1 libvpl2 \
    libegl-mesa0 libegl1-mesa-dev libgbm1 libgl1-mesa-dev libgl1-mesa-dri \
    libglapi-mesa libgles2-mesa-dev libglx-mesa0 libigdgmm12 libxatracker2 mesa-va-drivers \
    mesa-vdpau-drivers mesa-vulkan-drivers va-driver-all vainfo hwinfo clinfo \
    i965-va-driver-shaders \
    && apt autoremove -y \
    && rm -rf /tmp/intel \
    && rm -rf /var/lib/apt/lists/*

CMD         ["--help"]
ENTRYPOINT  ["ffmpeg"]
