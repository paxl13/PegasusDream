#!/bin/bash

shrinko8 \
  --count --input-count \
  -m --rename-safe-only --focus-token \
  --pico8-dat ~/bin/pico-8/pico8.dat \
  src/pegasus.p8 \
  dist/index.p8.png
