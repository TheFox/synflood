#!/usr/bin/env bash

set -x

zig build --verbose --summary all --release=small -Dtarget=aarch64-macos
zig build --verbose --summary all --release=small -Dtarget=x86_64-linux
#aarch64-linux x86_64-windows
