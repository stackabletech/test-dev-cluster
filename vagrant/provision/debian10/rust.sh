#!/usr/bin/env bash

#------------------------------------------------------------------------------
# Install Rust
#------------------------------------------------------------------------------
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
 && . $HOME/.cargo/env \
 && cargo install cargo-deb \
 && rustup toolchain install stable \
 && rustup default stable

