[![Build Status](https://travis-ci.org/p2pcollab/ocaml-vicinity.svg?branch=master)](https://travis-ci.org/p2pcollab/ocaml-vicinity)

# VICINITY: P2P topology management protocol

This is an OCaml implementation of VICINITY, a P2P topology management protocol
described in the paper [VICINITY: A Pinch of Randomness Brings
out the Structure](https://hal.inria.fr/hal-01480790/document).
The protocol takes care of overlay construction & maintenance,
and can be used for e.g. clustering nodes in groups
or organizing them in a coordinate system.

This implementation is distributed under the MPL-2.0 license.

## Installation

``vicinity`` can be installed via `opam`:

    opam install vicinity
    opam install vicinity-lwt

## Building

To build from source, generate documentation, and run tests, use `dune`:

    dune build
    dune build @doc
    dune runtest -f -j1 --no-buffer

In addition, the following `Makefile` targets are available
 as a shorthand for the above:

    make all
    make build
    make doc
    make test

## Documentation

The documentation and API reference is generated from the source interfaces.
It can be consulted [online][doc] or via `odig`:

    odig doc vicinity
    odig doc vicinity-lwt

[doc]: https://p2pcollab.github.io/doc/ocaml-vicinity/
