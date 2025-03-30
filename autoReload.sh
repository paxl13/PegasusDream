w=$1 || '*'
find $w | entr -s '
  clear
  echo "reloading"
  xdotool search --class pico8 key ctrl+r
  xdotool search --class pico8 key ctrl+r
  xdotool search --class pico8 key ctrl+r
'
