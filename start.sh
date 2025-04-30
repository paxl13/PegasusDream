#!/bin/bash

trap 'kill $PICOID; pkill -P $$; exit' INT

# pico8 -root_path ./src/ -run ./src/pegasus.p8 -width 1160 -height 1160 -windowed 1 &
pico8 -root_path ./src/ -run ./src/pegasus.p8 -width 768 -height 768 -windowed 1 &
PICOID=$!

echo 'Waiting for pico to start'
sleep 3
echo 'Done waiting'
wmctrl -r 'PICO-8' -b add,above
#wmctrl -r 'PICO-8' -e 0,2600,-100,1160,1160

find src/ | entr -s '
  echo "reloading in 1s";
  sleep 2;
  clear;
  echo "=================================";
  echo "LINTS:";
  shrinko8 \
    --lint \
    --no-lint-unused-global \
    --no-lint-fail \
    -m --rename-safe-only \
    --count \
    src/pegasus.p8 \
    dist/pegasus.p8;
  echo "=================================";
  xdotool search --class pico8 key ctrl+r;
'
  # xdotool search --class pico8 key ctrl+r
  # xdotool search --class pico8 key ctrl+r
  # xdotool search --class pico8 key ctrl+r
