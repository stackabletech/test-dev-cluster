FROM debian:buster

SHELL ["/bin/bash", "-c"]

# Install prerequisites
RUN apt-get update \
 && apt-get install -y apt-utils \
 && apt-get install -y curl gcc make libdbus-1-dev pkg-config libdbus-1-3 liblzma-dev libssl-dev libsystemd-dev python3-pip
 
# Install required Python-Libs
RUN pip3 install PyYAML

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
 && source $HOME/.cargo/env \
 && cargo install cargo-deb \
 && rustup toolchain install stable \
 && rustup default stableCMD ["cargo", "--version"]

CMD ["cargo", "--version"] 