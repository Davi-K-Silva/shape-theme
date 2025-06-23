#!/bin/bash

# Usage: ./wallpaper_multi_monitor.sh /path/to/image.png

# Validate input
if [ -z "$1" ]; then
    echo "Usage: $0 /path/to/image"
    exit 1
fi

INPUT="$1"

if [ ! -f "$INPUT" ]; then
    echo "File not found: $INPUT"
    exit 1
fi

CONF="monitors.conf"
OUTPUT_DIR="output"
mkdir -p "$OUTPUT_DIR"

if [ ! -f "$CONF" ]; then
    echo "Missing monitors.conf"
    exit 1
fi

# Arrays
declare -a positions widths heights names

# Read config
while IFS=',' read -r pos w h name; do
    positions+=("$pos")
    widths+=("$w")
    heights+=("$h")
    names+=("$name")
done < "$CONF"

# Find CENTER index
center_index=-1
for i in "${!positions[@]}"; do
    if [[ "${positions[$i]}" == "CENTER" ]]; then
        center_index=$i
        break
    fi
done

if [ "$center_index" -eq -1 ]; then
    echo "Error: CENTER not found in monitors.conf"
    exit 1
fi

# Calculate total canvas
total_width=0
max_height=0
for i in "${!widths[@]}"; do
    total_width=$(( total_width + widths[i] ))
    (( heights[i] > max_height )) && max_height=${heights[i]}
done

# Image dimensions
img_w=$(identify -format "%w" "$INPUT")
img_h=$(identify -format "%h" "$INPUT")

offset_x=$(( (img_w - total_width) / 2 ))
offset_y=$(( (img_h - max_height) / 2 ))

# Crop and assign to each display
current_x=$offset_x
for i in "${!positions[@]}"; do
    w=${widths[$i]}
    h=${heights[$i]}
    pos=${positions[$i]}
    mon=${names[$i]}
    out_file="$OUTPUT_DIR/${pos,,}.png"

    convert "$INPUT" -crop "${w}x${h}+${current_x}+${offset_y}" +repage "$out_file"
    #crop_y=$(( y_offset + (max_height - h) / 2 ))
    #convert "$INPUT" -crop "${w}x${h}+${current_x}+${crop_y}" +repage "$out_file"
    echo "Created $out_file"

    # Set the image with swww
    swww img "$out_file" --outputs "$mon" \
        --transition-type random --transition-step 255 --transition-fps 60

    current_x=$(( current_x + w ))
done

# Update pywal with original (uncropped) image
wal -n -i "$INPUT"
pywalfox update

# Set hyprlock background
cp "$INPUT" ~/.config/background.png

echo "Multi-monitor wallpaper applied from: $INPUT"

