#!/bin/bash

shrinko8 \
  --count --input-count \
  -m --rename-safe-only --focus-token \
  src/pegasus.p8 \
  dist/pegasus.p8
