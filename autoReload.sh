find * | entr -s '
  echo "reloading"
  xdotool search --class pico8 key ctrl+r
  xdotool search --class pico8 key ctrl+r
  xdotool search --class pico8 key ctrl+r
'
