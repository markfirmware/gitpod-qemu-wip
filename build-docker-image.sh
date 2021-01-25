#!/bin/bash
set -e

docker build -t markformware/abc -f gitpod-qemu.dockerfile .
