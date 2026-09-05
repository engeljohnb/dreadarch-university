#!/usr/bin/env bash

# Rename:
#   frame0012.png -> 0012.png
#   ...
#   frame0021.png -> 0021.png
#
# And:
#   0012.png -> frame0012.png
#   ...
#   0021.png -> frame0021.png
#
# Uses temporary filenames to avoid collisions.

set -euo pipefail

START=12
END=21

# Step 1: Move existing target files out of the way
for i in $(seq -f "%04g" $START $END); do
    if [[ -f "${i}.png" ]]; then
        mv "${i}.png" "__tmp_${i}.png"
    fi
done

# Step 2: Rename frameXXXX.png -> XXXX.png
for i in $(seq -f "%04g" $START $END); do
    if [[ -f "frame${i}.png" ]]; then
        mv "frame${i}.png" "${i}.png"
    fi
done

# Step 3: Rename original XXXX.png -> frameXXXX.png
for i in $(seq -f "%04g" $START $END); do
    if [[ -f "__tmp_${i}.png" ]]; then
        mv "__tmp_${i}.png" "frame${i}.png"
    fi
done

echo "Done."
