#!/bin/bash

pico8 -root_dir . ./src/pegasus.p8 -export bin/index.htmco8 -root_dir . ./src/pegasus.p8 -export bin/index.html

git add bin/index.html
git add bin/index.js
git commit -m "Update bin"
