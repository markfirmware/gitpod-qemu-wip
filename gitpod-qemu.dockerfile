FROM gitpod/workspace-full-vnc

USER gitpod

RUN sudo apt-get update && \
    mkdir /home/gitpod/ninja && \
    cd /home/gitpod/ninja && \
    wget -q https://github.com/ninja-build/ninja/releases/download/v1.10.2/ninja-linux.zip && \
    unzip ninja-linux.zip && \
    export PATH=/home/gitpod/ninja:$PATH && \
    cd /home/gitpod && \
    wget -q https://download.qemu.org/qemu-5.2.0.tar.xz && \
    tar Jxf qemu-5.2.0.tar.xz && \
    cd qemu-5.2.0 && \
    mkdir build && \
    cd build && \
    sudo apt-get install -y libgtk-3-dev && \
    ../configure --enable-gtk --target-list=arm-softmmu,aarch64-softmmu && \
    make -j 6 && \
    sudo make install && \
    cd .. && \
    rm -rf ninja/ qemu-5.2.0* && \
    du -sk *

    sudo sed -i s/1920x1080/1440x1080/ /usr/bin/start-vnc-session.sh
