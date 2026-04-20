#!/bin/bash

# Use playerctl to get status (lowercase)
# If spotify isn't running, this returns nothing
class=$(playerctl metadata --player=spotify --format '{{lc(status)}}' 2>/dev/null)

if [ -z "$class" ]; then
    echo "" # Output nothing if Spotify is closed
    exit 0
fi

icon=""

if [ "$class" == "playing" ]; then
    # Get metadata and escape double quotes so they don't break the JSON
    info=$(playerctl metadata --player=spotify --format '{{artist}} - {{title}}' | sed 's/"/\\"/g')
    
    # Use -gt for numerical comparison, not >
    if [ "${#info}" -gt 40 ]; then
        info=$(echo "$info" | cut -c1-40)"..."
    fi
    text="$info $icon"
elif [ "$class" == "paused" ]; then
    text="$icon"
else
    text=""
fi

# Output valid JSON
echo "{\"text\": \"$text\", \"class\": \"$class\"}"