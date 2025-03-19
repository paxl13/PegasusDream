#!/bin/bash

trap 'kill $PICOID; exit' INT

pico8 -root_path ./src -run ./src/pegasus.p8 &
PICOID=$!
./autoReload.sh

