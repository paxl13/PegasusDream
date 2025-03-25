mkdir -p dist/
find src/ | entr -s ' \
  clear; \
  shrinko8 \
    --lint \
    --no-lint-unused-global \
    --count --input-count \
    -m --rename-safe-only --focus-token \
    src/pegasus.p8 \
    dist/pegasus.p8.png \
'
