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
    make -j $(nproc) && \
    sudo make install && \
    cd .. && \
    rm -rf ninja/ qemu-5.2.0* && \
    du -sk *

RUN sudo sed -i s/1920x1080/1024x768/ /usr/bin/start-vnc-session.sh

RUN echo && echo ultibo && \
    wget -q -O fpc_3.0.0-151205_amd64.deb 'http://downloads.sourceforge.net/project/lazarus/Lazarus%20Linux%20amd64%20DEB/Lazarus%201.6.2/fpc_3.0.0-151205_amd64.deb?r=https%3A%2F%2Fsourceforge.net%2Fprojects%2Flazarus%2Ffiles%2FLazarus%2520Linux%2520amd64%2520DEB%2FLazarus%25201.6.2%2F&ts=1483204950&use_mirror=superb-sea2' && \
    sudo dpkg -i fpc_3.0.0-151205_amd64.deb && \
    rm fpc_3.0.0-151205_amd64.deb && \
    fpc -iV

RUN sudo apt-get update && sudo apt-get install -y bzip2 libc-dev libc6-i386 make unzip && \
    wget -q https://github.com/ultibohub/FPC/archive/master.zip && \
    unzip -q master.zip && \
    rm master.zip && \
    mkdir -p /home/gitpod/ultibo/core && \
    mv FPC-master /home/gitpod/ultibo/core/fpc && \
    wget -q https://github.com/ultibohub/Core/archive/master.zip && \
    unzip -q master.zip && \
    rm master.zip && \
    mkdir -p /home/gitpod/ultibo/core/fpc/source/packages && \
    mv Core-master/source/rtl/ultibo /home/gitpod/ultibo/core/fpc/source/rtl && \
    mv Core-master/source/packages/ultibounits /home/gitpod/ultibo/core/fpc/source/packages && \
    mv Core-master/units /home/gitpod/ultibo/core/fpc && \
    rm -rf Core-master && \
    cd /home/gitpod/ultibo/core/fpc/source && \
    echo && echo first make && \
    make -j $(nproc) distclean > distclean.1.log && \
    make > first.make.all.log all OS_TARGET=linux CPU_TARGET=x86_64 && \
    make > first.make.install.log install OS_TARGET=linux CPU_TARGET=x86_64 INSTALL_PREFIX=/home/gitpod/ultibo/core/fpc && \
    cp /home/gitpod/ultibo/core/fpc/source/compiler/ppcx64 /home/gitpod/ultibo/core/fpc/bin/ppcx64 && \
    /home/gitpod/ultibo/core/fpc/bin/fpcmkcfg -d basepath=/home/gitpod/ultibo/core/fpc/lib/fpc/3.1.1 -o /home/gitpod/ultibo/core/fpc/bin/fpc.cfg && \
    /home/gitpod/ultibo/core/fpc/bin/fpc -i

WORKDIR /home/gitpod/ultibo/core/fpc/source
ENV PATH=/home/gitpod/ultibo/core/fpc/bin:$PATH

RUN wget -q https://launchpadlibrarian.net/287101520/gcc-arm-none-eabi-5_4-2016q3-20160926-linux.tar.bz2 && \
    bunzip2 gcc-arm-none-eabi-5_4-2016q3-20160926-linux.tar.bz2 && \
    tar xf gcc-arm-none-eabi-5_4-2016q3-20160926-linux.tar && \
    rm gcc-arm-none-eabi-5_4-2016q3-20160926-linux.tar && \
    cp gcc-arm-none-eabi-5_4-2016q3/arm-none-eabi/bin/as /home/gitpod/ultibo/core/fpc/bin/arm-ultibo-as && \
    cp gcc-arm-none-eabi-5_4-2016q3/arm-none-eabi/bin/ld /home/gitpod/ultibo/core/fpc/bin/arm-ultibo-ld && \
    cp gcc-arm-none-eabi-5_4-2016q3/arm-none-eabi/bin/objcopy /home/gitpod/ultibo/core/fpc/bin/arm-ultibo-objcopy && \
    cp gcc-arm-none-eabi-5_4-2016q3/arm-none-eabi/bin/objdump /home/gitpod/ultibo/core/fpc/bin/arm-ultibo-objdump && \
    cp gcc-arm-none-eabi-5_4-2016q3/arm-none-eabi/bin/strip /home/gitpod/ultibo/core/fpc/bin/arm-ultibo-strip && \
    rm -rf gcc-arm-none-eabi-5_4-2016q3/ && \
\
    echo && echo second make && \
    make -j $(nproc) distclean > distclean.2.log OS_TARGET=ultibo CPU_TARGET=arm SUBARCH=armv7a BINUTILSPREFIX=arm-ultibo- FPCOPT="-dFPC_ARMHF" CROSSOPT="-CpARMV7A -CfVFPV3 -CIARM -CaEABIHF -OoFASTMATH" FPC=/home/gitpod/ultibo/core/fpc/bin/ppcx64 && \
    make > second.make.all.log all OS_TARGET=ultibo CPU_TARGET=arm SUBARCH=armv7a BINUTILSPREFIX=arm-ultibo- FPCOPT="-dFPC_ARMHF" CROSSOPT="-CpARMV7A -CfVFPV3 -CIARM -CaEABIHF -OoFASTMATH" FPC=/home/gitpod/ultibo/core/fpc/bin/ppcx64 && \
    make crossinstall BINUTILSPREFIX=arm-ultibo- FPCOPT="-dFPC_ARMHF" CROSSOPT="-CpARMV7A -CfVFPV3 -CIARM -CaEABIHF -OoFASTMATH" OS_TARGET=ultibo CPU_TARGET=arm SUBARCH=armv7a FPC=/home/gitpod/ultibo/core/fpc/bin/ppcx64 INSTALL_PREFIX=/home/gitpod/ultibo/core/fpc && \
\
    cp /home/gitpod/ultibo/core/fpc/source/compiler/ppcrossarm /home/gitpod/ultibo/core/fpc/bin/ppcrossarm

RUN echo && echo armv7a rtl && \
    make -j $(nproc) rtl_clean > rtl_clean.armv7a.1.log CROSSINSTALL=1 OS_TARGET=ultibo CPU_TARGET=arm SUBARCH=armv7a FPCFPMAKE=/home/gitpod/ultibo/core/fpc/bin/fpc CROSSOPT="-CpARMV7A -CfVFPV3 -CIARM -CaEABIHF -OoFASTMATH" FPC=/home/gitpod/ultibo/core/fpc/bin/fpc && \
    make > rtl.armv7a.log rtl OS_TARGET=ultibo CPU_TARGET=arm SUBARCH=armv7a FPCFPMAKE=/home/gitpod/ultibo/core/fpc/bin/fpc CROSSOPT="-CpARMV7A -CfVFPV3 -CIARM -CaEABIHF -OoFASTMATH" FPC=/home/gitpod/ultibo/core/fpc/bin/fpc && \
    make rtl_install CROSSINSTALL=1 FPCFPMAKE=/home/gitpod/ultibo/core/fpc/bin/fpc CROSSOPT="-CpARMV7A -CfVFPV3 -CIARM -CaEABIHF -OoFASTMATH" OS_TARGET=ultibo CPU_TARGET=arm SUBARCH=armv7a FPC=/home/gitpod/ultibo/core/fpc/bin/fpc INSTALL_PREFIX=/home/gitpod/ultibo/core/fpc INSTALL_UNITDIR=/home/gitpod/ultibo/core/fpc/units/armv7-ultibo/rtl && \
\
    echo && echo armv7a packages && \
    make -j $(nproc) rtl_clean > rtl_clean.armv7a.2.log CROSSINSTALL=1 OS_TARGET=ultibo CPU_TARGET=arm SUBARCH=armv7a FPCFPMAKE=/home/gitpod/ultibo/core/fpc/bin/fpc CROSSOPT="-CpARMV7A -CfVFPV3 -CIARM -CaEABIHF -OoFASTMATH" FPC=/home/gitpod/ultibo/core/fpc/bin/fpc && \
    make -j $(nproc) > packages_clean.armv7a.1.log packages_clean CROSSINSTALL=1 OS_TARGET=ultibo CPU_TARGET=arm SUBARCH=armv7a FPCFPMAKE=/home/gitpod/ultibo/core/fpc/bin/fpc CROSSOPT="-CpARMV7A -CfVFPV3 -CIARM -CaEABIHF -OoFASTMATH" FPC=/home/gitpod/ultibo/core/fpc/bin/fpc && \
    make > packages.armv7a.log -j $(nproc) packages OS_TARGET=ultibo CPU_TARGET=arm SUBARCH=armv7a FPCFPMAKE=/home/gitpod/ultibo/core/fpc/bin/fpc CROSSOPT="-CpARMV7A -CfVFPV3 -CIARM -CaEABIHF -OoFASTMATH -Fu/home/gitpod/ultibo/core/fpc/units/armv7-ultibo/rtl" FPC=/home/gitpod/ultibo/core/fpc/bin/fpc && \
    make packages_install CROSSINSTALL=1 FPCFPMAKE=/home/gitpod/ultibo/core/fpc/bin/fpc CROSSOPT="-CpARMV7A -CfVFPV3 -CIARM -CaEABIHF -OoFASTMATH" OS_TARGET=ultibo CPU_TARGET=arm SUBARCH=armv7a FPC=/home/gitpod/ultibo/core/fpc/bin/fpc INSTALL_PREFIX=/home/gitpod/ultibo/core/fpc INSTALL_UNITDIR=/home/gitpod/ultibo/core/fpc/units/armv7-ultibo/packages && \
\
    echo && echo armv6 rtl && \
    make -j $(nproc) rtl_clean > rtl_clean.armv6.1.log CROSSINSTALL=1 OS_TARGET=ultibo CPU_TARGET=arm SUBARCH=armv6 FPCFPMAKE=/home/gitpod/ultibo/core/fpc/bin/fpc CROSSOPT="-CpARMV6 -CfVFPV2 -CIARM -CaEABIHF -OoFASTMATH" FPC=/home/gitpod/ultibo/core/fpc/bin/fpc && \
    make > rtl.armv6.log rtl OS_TARGET=ultibo CPU_TARGET=arm SUBARCH=armv6 FPCFPMAKE=/home/gitpod/ultibo/core/fpc/bin/fpc CROSSOPT="-CpARMV6 -CfVFPV2 -CIARM -CaEABIHF -OoFASTMATH" FPC=/home/gitpod/ultibo/core/fpc/bin/fpc && \
    make rtl_install CROSSINSTALL=1 FPCFPMAKE=/home/gitpod/ultibo/core/fpc/bin/fpc CROSSOPT="-CpARMV6 -CfVFPV2 -CIARM -CaEABIHF -OoFASTMATH" OS_TARGET=ultibo CPU_TARGET=arm SUBARCH=armv6 FPC=/home/gitpod/ultibo/core/fpc/bin/fpc INSTALL_PREFIX=/home/gitpod/ultibo/core/fpc INSTALL_UNITDIR=/home/gitpod/ultibo/core/fpc/units/armv6-ultibo/rtl && \
\
    echo && echo armv6 packages && \
    make -j $(nproc) rtl_clean > rtl_clean.armv6.2.log CROSSINSTALL=1 OS_TARGET=ultibo CPU_TARGET=arm SUBARCH=armv6 FPCFPMAKE=/home/gitpod/ultibo/core/fpc/bin/fpc CROSSOPT="-CpARMV6 -CfVFPV2 -CIARM -CaEABIHF -OoFASTMATH" FPC=/home/gitpod/ultibo/core/fpc/bin/fpc && \
    make -j $(nproc) > packages_clean.armv6.1.log packages_clean CROSSINSTALL=1 OS_TARGET=ultibo CPU_TARGET=arm SUBARCH=armv6 FPCFPMAKE=/home/gitpod/ultibo/core/fpc/bin/fpc CROSSOPT="-CpARMV6 -CfVFPV2 -CIARM -CaEABIHF -OoFASTMATH" FPC=/home/gitpod/ultibo/core/fpc/bin/fpc && \
    make > packages.armv6.log -j $(nproc) packages OS_TARGET=ultibo CPU_TARGET=arm SUBARCH=armv6 FPCFPMAKE=/home/gitpod/ultibo/core/fpc/bin/fpc CROSSOPT="-CpARMV6 -CfVFPV2 -CIARM -CaEABIHF -OoFASTMATH -Fu/home/gitpod/ultibo/core/fpc/units/armv6-ultibo/rtl" FPC=/home/gitpod/ultibo/core/fpc/bin/fpc && \
    make packages_install CROSSINSTALL=1 FPCFPMAKE=/home/gitpod/ultibo/core/fpc/bin/fpc CROSSOPT="-CpARMV6 -CfVFPV2 -CIARM -CaEABIHF -OoFASTMATH" OS_TARGET=ultibo CPU_TARGET=arm SUBARCH=armv6 FPC=/home/gitpod/ultibo/core/fpc/bin/fpc INSTALL_PREFIX=/home/gitpod/ultibo/core/fpc INSTALL_UNITDIR=/home/gitpod/ultibo/core/fpc/units/armv6-ultibo/packages

WORKDIR /home/gitpod

RUN touch make_cfg_file.sh && \
    echo >> make_cfg_file.sh '#!/bin/bash' && \
    echo >> make_cfg_file.sh 'file_name=$1' && \
    echo >> make_cfg_file.sh 'message=$2' && \
    echo >> make_cfg_file.sh 'arch=$3' && \
    echo >> make_cfg_file.sh 'fpv=$4' && \
    echo >> make_cfg_file.sh 'cd /home/gitpod/ultibo/core/fpc/bin' && \
    echo >> make_cfg_file.sh 'touch $file_name' && \
    echo >> make_cfg_file.sh 'echo >> $file_name "#"' && \
    echo >> make_cfg_file.sh 'echo >> $file_name "# $message specific config file"' && \
    echo >> make_cfg_file.sh 'echo >> $file_name "#"' && \
    echo >> make_cfg_file.sh 'echo >> $file_name "-CfV$fpv"' && \
    echo >> make_cfg_file.sh 'echo >> $file_name "-CIARM"' && \
    echo >> make_cfg_file.sh 'echo >> $file_name "-CaEABIHF"' && \
    echo >> make_cfg_file.sh 'echo >> $file_name "-OoFASTMATH"' && \
    echo >> make_cfg_file.sh 'echo >> $file_name "-Fu/home/gitpod/ultibo/core/fpc/units/$arch-ultibo/rtl"' && \
    echo >> make_cfg_file.sh 'echo >> $file_name "-Fu/home/gitpod/ultibo/core/fpc/units/$arch-ultibo/packages"' && \
    echo >> make_cfg_file.sh 'echo >> $file_name "-Fl/home/gitpod/ultibo/core/fpc/units/$arch-ultibo/lib"' && \
    chmod u+x make_cfg_file.sh && \
    ./make_cfg_file.sh qemuvpb.cfg "QEMU armv7" armv7 FPV3 && \
    ./make_cfg_file.sh rpi.cfg "Raspberry Pi (A/B/A+/B+/Zero)" armv6 FPV2 && \
    ./make_cfg_file.sh rpi2.cfg "Raspberry Pi 2B" armv7 FPV3 && \
    ./make_cfg_file.sh rpi3.cfg "Raspberry Pi 3B" armv7 FPV3

RUN mkdir test
COPY build-examples.sh test
RUN cd test && ./build-examples.sh && cd .. && rm -rf test
