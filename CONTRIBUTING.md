# Contributing to VeriPDE

Thank you for your interest in contributing to VeriPDE!

## Development Setup

```bash
git clone https://github.com/yourusername/veripde.git
cd veripde
opam install --deps-only .
dune build
dune runtest
