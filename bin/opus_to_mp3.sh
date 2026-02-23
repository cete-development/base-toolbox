#!/bin/bash

# Directory to scan, defaults to current directory
INPUT_DIR="${1:-.}"

# Bitrate for MP3 output (change if needed)
BITRATE="192k"

# Check for ffmpeg
if ! command -v ffmpeg &> /dev/null; then
    echo "Error: ffmpeg is not installed." >&2
    exit 1
fi

# Loop through all .opus files
for opus_file in "$INPUT_DIR"/*.opus; do
    # Skip if no files found
    [ -e "$opus_file" ] || continue

    # Extract filename without extension
    base_name="${opus_file%.*}"
    mp3_file="${base_name}.mp3"

    echo "Converting: $opus_file -> $mp3_file"

    # Convert using ffmpeg
    ffmpeg -i "$opus_file" -ab "$BITRATE" -acodec libmp3lame "$mp3_file"
done

echo "Conversion complete."
