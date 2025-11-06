if [ "$(acpi -a)" == "Adapter 0: on-line" ]
then
hyprctl keyword monitor "eDP-1, disable"
hyprctl keyword monitor "DP-1, enable" hyprctl reload
else
hyprctl keyword monitor "DP-1, disable" hyprctl reload
fi
