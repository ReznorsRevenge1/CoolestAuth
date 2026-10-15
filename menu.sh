#!/bin/bash
# this code was originally from modmium; it's been repurposed to be a general TUI menu tool.

selected_index=0
center_menu=${center_menu:-0}
voffset=${voffset:-0}
resize=0

# TUI colors
B=$'\033[38;5;45m'
G=$'\033[38;5;46m'
Y=$'\033[38;5;220m'
R=$'\033[38;5;203m'
P=$'\033[38;5;135m'
N=$'\033[0m'
D=$'\033[1;90m'
UN=$'\033[4m' #underline
RUN=$'\033[24m' #reset underline

selector() {
  for option in ${!options[@]}; do
    if [[ $selected_index == $option ]]; then
      ${functions[$option]}
    fi
  done
}

centermenu() {
  local content="$1" voffset="${2:-0}"
  local rows cols line stripped w start_row start_col row
  local -a lines
  rows=$(tput lines)
  cols=$(tput cols)
  mapfile -t lines <<< "$content"
  start_row=$(( (rows - ${#lines[@]}) / 2 - voffset ))
  (( start_row < 0 )) && start_row=0
  row=$start_row
  for line in "${lines[@]}"; do
    stripped=$(printf '%s' "$line" | sed 's/\x1b\[[^a-zA-Z]*[a-zA-Z]//g; s/\x1b][^\x07]*\x07//g') # colors aren't words bash!
    w=${#stripped}
    start_col=$(( (cols - w) / 2 ))
    (( start_col < 0 )) && start_col=0
    tput cup "$row" "$start_col"
    printf '%s' "$line"
    tput el
    (( row++ ))
  done
}

display_menu() {
  local voffset="${1:-0}"
  local out
  out=$(
    echo -e "$menuText"

    for i in "${!options[@]}"; do
      local keysel="${keymap:$i:1}"
      if [[ $i -eq $selected_index ]]; then
        printf "\e[7m > %s) ${options[$i]} \e[0m\n" "$keysel"
      else
        printf "   %s) ${options[$i]}      \n" "$keysel"
      fi
    done
  )

  if [[ "$center_menu" == "1" ]]; then
    tput cup 0 0
    tput sc
    centermenu "$out" "$voffset"
  else
    tput sc
    printf '%s\n' "$out"
  fi
}

full_menu() {
  keymap="1234567890-=qwertyuiopasdfghjklzxcvbnm" # map of keys for each option, so 11 would be '-', and 13 would be 'q'
  clear
  stty -echo
  tput civis
  [[ "$center_menu" == "1" ]] && trap 'resize=1' WINCH
  while true; do
    display_menu "${voffset:-0}"
    if [[ "$center_menu" == "1" ]]; then
      while ! read -rsn1 -t 1 key 2>/dev/null; do
        if [[ $resize -eq 1 ]]; then 
          resize=0
          clear
          continue 2;
        fi
      done
    else
      read -rsn1 key
    fi
    if [[ "$key" == $'\x1b' ]]; then
      read -rsn2 -t 1 keyseq
      case "$keyseq" in
        '[A')
          selected_index=$(((selected_index - 1 + num_options) % num_options))
          ;;
        '[B')
          selected_index=$(((selected_index + 1) % num_options))
          ;;
      esac
    elif [[ -n "$key" && "$keymap" == *"$key"* ]]; then
      prefix="${keymap%%"$key"*}"
      target_index=${#prefix}
      if [ "$target_index" -lt "$num_options" ]; then
        selected_index=$target_index
      fi
    elif [[ "$key" == "" ]]; then
      break
    fi
    tput rc
  done
  [[ "$center_menu" == "1" ]] && trap - WINCH
  selector
}
quit(){
  stty echo
  tput cnorm
  clear
  command exit 0
}