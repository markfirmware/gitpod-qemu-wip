#!/bin/bash
set -e

docker build -t markformware/gitpod-qemu -f gitpod-qemu.dockerfile . |& tee build.log
