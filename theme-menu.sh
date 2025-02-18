#!/bin/bash

# Define the directory where wallpapers are stored
WALLPAPER_DIR="$HOME/Wallpapers"

# Check if the directory exists
if [ ! -d "$WALLPAPER_DIR" ]; then
    echo "Wallpaper directory not found: $WALLPAPER_DIR"
    exit 1
fi

# Use wofi to select a file from the wallpaper directory
selected_wallpaper=$(ls "$WALLPAPER_DIR" | wofi --dmenu --prompt "Select Wallpaper")

# Check if a wallpaper was selected
if [ -z "$selected_wallpaper" ]; then
    echo "No wallpaper selected."
    exit 1
fi

# Full path of the selected wallpaper
wallpaper_path="$WALLPAPER_DIR/$selected_wallpaper"

# Check if the selected file exists
if [ ! -f "$wallpaper_path" ]; then
    echo "Selected file not found: $wallpaper_path"
    exit 1
fi

# Run change script with the selected t
exec ~/Desktop/shape-theme/change-theme.sh "$wallpaper_path"
