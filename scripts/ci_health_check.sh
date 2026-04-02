#!/usr/bin/env bash
set -euo pipefail

printf "🚦 VeriPDE CI healthcheck start\n"

printf "⏳ Ensuring OCaml dependencies are installed...\n"
opam install -y ounit2 yojson || {
  printf "❌ Failed to install dependencies. Run 'opam update' then retry.\n" >&2
  exit 1
}

printf "⏳ Building all targets...\n"
dune build --root "$PWD" @all || {
  printf "❌ Build failed. Check compiler output.\n" >&2
  exit 1
}

printf "⏳ Running test suite...\n"
dune runtest --root "$PWD" || {
  printf "❌ Tests failed.\n" >&2
  exit 1
}

printf "⏳ Running CLI smoke test...\n"
dune exec --root "$PWD" veripde-validator -- validate examples/validator_smoke.json --thresholds examples/thresholds.json --output text || {
  printf "❌ CLI smoke test failed.\n" >&2
  exit 1
}

printf "✅ VeriPDE CI healthcheck passed\n" 
