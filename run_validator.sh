#!/bin/bash
set -e
if [ $# -ne 1 ]; then
  echo "Usage: ./run_validator.sh <input.json>"
  exit 1
fi
INPUT_FILE="$1"
# cd "$(dirname "$0")"/..
echo "[🔧] Building OCaml validator..."
dune build
_build/default/main.exe "$INPUT_FILE"
