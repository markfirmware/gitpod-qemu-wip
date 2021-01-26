#!/bin/bash
set -e

docker build -t markformware/gitpod-ultibo -f gitpod-ultibo.dockerfile . |& tee build.log
