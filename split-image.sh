#!/bin/bash

# Usage: ./crop_wallpaper.sh path/to/image.png

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <image-file>"
    exit 1
fi

INPUT="$1"
CONF="monitors.conf"
OUTPUT_DIR="output"
mkdir -p "$OUTPUT_DIR"

if [[ ! -f "$INPUT" ]]; then
    echo "Error: File '$INPUT' not found"
    exit 1
fi

if [[ ! -f "$CONF" ]]; then
    echo "Error: Config file '$CONF' not found"
    exit 1
fi

# Read monitors config
declare -a positions widths heights

while IFS=',' read -r position width height; do
    positions+=("$position")
    widths+=("$width")
    heights+=("$height")
done < "$CONF"

# Find index of CENTER monitor
center_index=-1
for i in "${!positions[@]}"; do
    if [[ "${positions[$i]}" == "CENTER" ]]; then
        center_index=$i
        break
    fi
done

if [[ $center_index -eq -1 ]]; then
    echo "Error: CENTER monitor not found in config"
    exit 1
fi

# Compute total width and max height
total_width=0
max_height=0
for i in "${!widths[@]}"; do
    total_width=$(( total_width + widths[i] ))
    (( heights[i] > max_height )) && max_height=${heights[i]}
done

# Get input image dimensions
img_w=$(identify -format "%w" "$INPUT")
img_h=$(identify -format "%h" "$INPUT")

# Compute X offset (centered around CENTER)
center_offset_x=0
for ((i = 0; i < center_index; i++)); do
    center_offset_x=$(( center_offset_x + widths[i] ))
done
offset_x=$(( (img_w - total_width) / 2 ))
offset_y=$(( (img_h - max_height) / 2 ))

# Crop each region
current_x=$offset_x
for i in "${!positions[@]}"; do
    w=${widths[$i]}
    h=${heights[$i]}
    pos=${positions[$i]}
    out_file="$OUTPUT_DIR/${pos,,}.png"  # lowercase name
    convert "$INPUT" -crop "${w}x${h}+${current_x}+${offset_y}" +repage "$out_file"
    echo "Created $out_file"
    current_x=$(( current_x + w ))
done

echo "All crops done."

