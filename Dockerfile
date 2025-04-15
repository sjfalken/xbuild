FROM rust:latest

WORKDIR /app
COPY . . 
RUN cd xbuild && cargo build --release --bin x

ENTRYPOINT [ "/app/target/release/x" ]