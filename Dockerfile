FROM rust:latest
# ARG XBUILD_VERSION

WORKDIR /app
RUN apt-get update
RUN apt-get -y install wget
RUN apt-get -y install lsb-release
RUN apt-get -y install software-properties-common
RUN apt-get -y install gnupg
RUN apt-get -y install adb
RUN apt-get -y install default-jdk
RUN apt-get -y install gradle
RUN apt-get -y install kotlin
RUN apt-get -y install usbmuxd 
RUN apt-get -y install libimobiledevice6 
RUN apt-get -y install libimobiledevice-utils
RUN apt-get -y install ideviceinstaller

# RUN git clone https://github.com/sjfalken/xbuild

# WORKDIR /app/xbuild
RUN cargo install --profile release --git https://github.com/sjfalken/xbuild --branch master --bin x xbuild
RUN cargo install --profile release --git  https://github.com/indygreg/apple-platform-rs.git --bin rcodesign apple-codesign
# WORKDIR /app
RUN wget https://apt.llvm.org/llvm.sh && bash ./llvm.sh
RUN bash -c "ln -s -t /usr/local/bin /usr/lib/llvm-19/bin/*"


ENTRYPOINT [ "x" ]
