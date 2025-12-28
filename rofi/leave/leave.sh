#!/usr/bin/env bash

choice=$(printf "Lock\nLogout\nSuspend\nReboot\nShutdown" | rofi -dmenu)
if [[ $choice == "Lock" ]];then
    bash pactl set-sink-mute @DEFAULT_SINK@ 1 && hyprlock
elif [[ $choice == "Logout" ]];then
    pkill -KILL -u "$USER"
elif [[ $choice == "Suspend" ]];then
    systemctl suspend
elif [[ $choice == "Reboot" ]];then
    systemctl reboot
elif [[ $choice == "Shutdown" ]];then
    systemctl poweroff
fi
