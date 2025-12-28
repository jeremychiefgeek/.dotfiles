#!/usr/bin/env bash
set -euo pipefail

# Requires: hyprctl, jq, base64
active_ws="$(hyprctl -j activeworkspace | jq -r '.id')"

# Rosé Pine (dark/main) accent for active workspace
ROSE_PINE_FOAM="#9ccfd8"

icon_for_class() {
  local c="${1,,}"
  case "$c" in
    brave-browser|brave|firefox) echo "" ;;
    code|code-oss|vscodium) echo "" ;;
    wezterm|alacritty|kitty|foot) echo "" ;;
    thunar|nautilus|dolphin) echo "" ;;
    discord) echo "" ;;
    slack) echo "󰒱" ;;
    spotify) echo "" ;;
    obsidian) echo "󰠮" ;;
    *) echo "" ;;
  esac
}

# Pango-safe escape
pango_escape() {
  sed -e 's/&/\&amp;/g' \
      -e 's/</\&lt;/g' \
      -e 's/>/\&gt;/g' \
      -e 's/"/\&quot;/g' \
      -e "s/'/\&apos;/g"
}

ws_data="$(
  hyprctl -j clients | jq -r '
    map({ws:(.workspace.id|tostring), cls:(.class // .initialClass // "")})
    | map(select(.cls != ""))
    | group_by(.ws)
    | map({ws:(.[0].ws|tonumber), classes:(map(.cls)|unique)})
    | sort_by(.ws)
    | .[]
    | @base64
  '
)"

text=""
tooltip="Workspaces with windows"

while IFS= read -r row; do
  [[ -z "$row" ]] && continue

  json="$(printf '%s' "$row" | base64 -d)"
  ws="$(jq -r '.ws' <<<"$json")"
  classes="$(jq -r '.classes[]' <<<"$json")"

  # Build icon string from classes (unique already)
  icons=""
  while IFS= read -r cls; do
    [[ -z "$cls" ]] && continue
    icons+="$(icon_for_class "$cls") "
  done <<< "$classes"
  icons="${icons%% }"

  segment="$ws $icons"
  safe_segment="$(printf '%s' "$segment" | pango_escape)"

  if [[ "$ws" == "$active_ws" ]]; then
    # Active: bold + underline + rose-pine foam color
    text+="<span foreground=\"${ROSE_PINE_FOAM}\" weight=\"bold\" underline=\"single\">${safe_segment}</span>  "
  else
    # Inactive: dim via alpha
    text+="<span alpha=\"70%\">${safe_segment}</span>  "
  fi

  # Tooltip: list classes in that workspace
  tooltip+=$'\n'"$ws: $(echo "$classes" | tr '\n' ' ' | pango_escape)"
done <<< "$ws_data"

text="${text%%  }"
if [[ -z "$text" ]]; then
  text="—"
  tooltip="No windows"
fi

jq -cn --arg text "$text" --arg tooltip "$tooltip" '{text:$text, tooltip:$tooltip}'

