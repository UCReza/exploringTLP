#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
docker run --rm -it -v "$PWD":/work -w /work ubuntu:22.04 bash -lc '
  set -e
  apt-get update
  apt-get install -y build-essential gcc-aarch64-linux-gnu file
  make arm-static
  echo "Built binary:"
  file daxpy_aarch64
'
