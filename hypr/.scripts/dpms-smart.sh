#!/bin/bash
# ~/.config/hypr/scripts/dpms-smart.sh

action="$1"  # "on" or "off"

# Get laptop lid state (closed = true, open = false)
lid_closed=false
if [ -f /proc/acpi/button/lid/LID/state ]; then
    grep -q "closed" /proc/acpi/button/lid/LID/state && lid_closed=true
elif [ -f /proc/acpi/button/lid/LID0/state ]; then
    grep -q "closed" /proc/acpi/button/lid/LID0/state && lid_closed=true
fi

if $lid_closed; then
    # Laptop closed - only control external monitors
    monitors=$(hyprctl monitors -j | jq -r '.[] | select(.name | startswith("eDP") | not) | .name')
    
    if [ -z "$monitors" ]; then
        # No external monitors, apply to all (fallback)
        hyprctl dispatch dpms "$action"
    else
        # Apply to each external monitor
        while IFS= read -r monitor; do
            hyprctl dispatch dpms "$action" "$monitor"
        done <<< "$monitors"
    fi
else
    # Laptop open - control all displays
    hyprctl dispatch dpms "$action"
fi

# Sleep after turning off to prevent immediate wake
if [ "$action" = "off" ]; then
    sleep 2
fi
