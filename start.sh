#!/bin/bash

trap 'kill $PICOID; exit' INT

pico8 -root_path ./src -run ./src/pegasus.p8 -width 1160 -height 1160 -windowed 1 &
PICOID=$!

echo 'Waiting for pico to start'
sleep 3
echo 'Done waiting'
wmctrl -r 'PICO-8' -b add,above
#wmctrl -r 'PICO-8' -e 0,2600,-100,1160,1160

./autoReload.sh
