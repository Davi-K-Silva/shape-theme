#!/bin/bash

# Check if a path was provided
if [ -z "$1" ]; then
    echo "Usage: $0 /path/to/image"
    exit 1
fi

# Check if the file exists
if [ ! -f "$1" ]; then
    echo "File not found!"
    exit 1
fi

# Run pywal with the provided image path
wal -n -i "$1"
exec ~/.config/waybar/waybar.sh &
pywalfox update
swww img --transition-type random --transition-step 255 --transition-fps 60 $1

# Optionally, reload terminal and other applications that support pywal
# Uncomment the line below if you want to reload terminal settings
# wal -R

echo "pywal applied with image: $1"
