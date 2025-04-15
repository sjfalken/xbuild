FROM rust:latest

WORKDIR /app
COPY . . 
RUN cd xbuild && cargo build --release --bin x
RUN apt-get update
RUN apt-get install -y lsb-release
RUN apt-get install -y wget
RUN apt-get install -y software-properties-common
RUN apt-get install -y gnupg

RUN wget -O - https://apt.llvm.org/llvm.sh | bash
RUN ln -s -t /usr/local/bin /usr/lib/llvm-19/bin/*

ENTRYPOINT [ "/app/target/release/x" ]