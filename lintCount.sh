mkdir -p dist/
#
#    --count --input-count \
#    -m --rename-safe-only \
#    --no-minify-lines \
#
find src/ | entr -s ' \
  clear; \
  shrinko8 \
    --lint \
    --no-lint-unused-global \
    --no-lint-fail \
    --script ./preprocessor/splitkeys.py \
    -m --rename-safe-only \
    --count --input-count \
    --no-minify-lines \
    src/pegasus.p8 \
    dist/pegasus.p8 \
'
