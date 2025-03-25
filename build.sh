#!/bin/bash

shrinko8 \
  --count --input-count \
  -m --rename-safe-only \
  --pico8-dat ~/bin/pico-8/pico8.dat \
  src/pegasus.p8 \
  bin/index.js

# pico8 -root_dir . ./src/pegasus.p8 -export bin/index.html -root_dir . ./src/pegasus.p8 -export bin/index.html

git add bin/index.js
git commit -m "Update bin"
