FROM nvidia/cuda:12.0.0-devel-ubuntu20.04
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get upgrade -y && apt-get install -y nvidia-cuda-toolkit
#Time-------------------------------------------------------
ENV TZ=Asia/Seoul
RUN apt-get install -y tzdata
RUN echo $TZ > /etc/timezone && \
    rm /etc/localtime && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata && \
    apt-get clean
#-----------------------------------------------------------

RUN apt-get install -y wget git cmake nano snapd build-essential git yasm unzip wget sysstat nasm libc6 \
libavcodec-dev libavformat-dev libavutil-dev pkgconf g++ freeglut3-dev \
libx11-dev libxmu-dev libxi-dev libglu1-mesa libglu1-mesa-dev libgstreamer-plugins-bad1.0-dev gstreamer1.0-plugins-good

#!----------------------------------------------------------------------------------------------------------ffmpeg

WORKDIR /root
RUN git clone https://github.com/FFmpeg/nv-codec-headers
WORKDIR /root/nv-codec-headers
RUN make && make install

#!----------------------------------------------------------------------------------------------------------h264

WORKDIR /root
RUN git clone https://code.videolan.org/videolan/x264.git
WORKDIR /root/x264
RUN ./configure --disable-cli --enable-static --enable-shared --enable-strip
RUN make && make install
RUN ldconfig

#!----------------------------------------------------------------------------------------------------------h265

RUN apt-get install -y libx265-dev libnuma-dev

#!----------------------------------------------------------------------------------------------------------ffmpeg

WORKDIR /root
RUN git clone git://source.ffmpeg.org/ffmpeg.git ffmpeg
WORKDIR /root/ffmpeg
RUN ./configure --enable-nonfree --enable-nvenc --enable-libx264 --enable-libx265 --enable-gpl --enable-cuda --enable-cuvid --enable-cuda-nvcc
RUN make

RUN ln -s /root/ffmpeg/ffmpeg /usr/local/bin/ffmpeg

#!----------------------------------------------------------------------------------------------------------go2rtc

WORKDIR /root
RUN wget https://github.com/AlexxIT/go2rtc/releases/download/v1.2.0/go2rtc_linux_amd64
RUN chmod +x go2rtc_linux_amd64

#!----------------------------------------------------------------------------------------------------------ssh(remote)

RUN apt-get install -y openssh-server
RUN echo "PermitRootLogin yes \nPasswordAuthentication yes \nChallengeResponseAuthentication no" >> /etc/ssh/sshd_config
#RUN echo "root:AS!!Dfsa**SADsaSA" | chpasswd
RUN echo "root:1234" | chpasswd
RUN service ssh restart

#!----------------------------------------------------------------------------------------------------------------------



#!----------------------------------------------------------------------------------------------------------------------

WORKDIR /root
ENTRYPOINT ["/bin/sh", "-c" , "service ssh start  && ./go2rtc_linux_amd64"]
