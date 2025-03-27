FROM rust:latest
# ARG XBUILD_VERSION

WORKDIR /setup
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
RUN apt-get -y install ruby-rubygems
RUN apt-get -y install ruby-dev
RUN cargo install --profile release --git https://github.com/sjfalken/xbuild --branch master --bin x xbuild

RUN wget https://apt.llvm.org/llvm.sh && bash ./llvm.sh
RUN bash -c "ln -s -t /usr/local/bin /usr/lib/llvm-19/bin/*"

WORKDIR /app
COPY Gemfile .

RUN gem install bundler
RUN bundle update
RUN PRODUCE_COMPANY_NAME="Stefan Falkenstein" fastlane init




ENTRYPOINT [ "x" ]
