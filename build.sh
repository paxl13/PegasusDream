#!/bin/bash

shrinko8 \
  --count --input-count \
  -m --rename-safe-only \
  --pico8-dat ~/bin/pico-8/pico8.dat \
  --const DEBUG false \
  src/pegasus.p8 \
  bin/index.js

shrinko8 \
  --count \
  --const DEBUG false \
  src/pegasus.p8 \
  bin/pegasus.p8.png

git add bin/index.js
git add bin/pegasus.p8.png
git commit -m "Update bin"
