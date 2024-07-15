#!/usr/bin/env bash


# Current Theme
dir="/home/will/.config/hypr/waybar/scripts/power-menu/"
theme='style-4'

# CMDs
#uptime="$(uptime  | sed -e 's/up //g')"
#uptime="$(uptime | sed -e 's/up //g' -e 's/ days\?,/d/g' -e 's/ hours\?,\?/h/g' -e 's/ minutes\?/m/g')"
uptime="$(uptime | sed -E 's/.*(up.*), [[:digit:]]+ user.*/\1/')"
host=$(hostname)

# Options
shutdown=' Shutdown'
reboot=' Reboot'
lock=' Lock'
suspend=' Suspend'
logout=' Logout'
yes=' Yes'
no=' No'

# Prevent release key not getting registered
sleep 0.05

# Rofi CMD
rofi_cmd() {
	rofi -dmenu \
		-p "$host" \
		-mesg "Uptime: $uptime" \
		-theme ${dir}/${theme}.rasi
}

# Confirmation CMD
confirm_cmd() {
	rofi -theme-str 'window {location: center; anchor: center; fullscreen: false; width: 250px;}' \
		-theme-str 'mainbox {children: [ "message", "listview" ];}' \
		-theme-str 'listview {columns: 2; lines: 1;}' \
		-theme-str 'element-text {horizontal-align: 0.5;}' \
		-theme-str 'textbox {horizontal-align: 0.5;}' \
		-dmenu \
		-p 'Confirmation' \
		-mesg 'Are you Sure?' \
		-theme ${dir}/${theme}.rasi
}

# Ask for confirmation
confirm_exit() {
	echo -e "$yes\n$no" | confirm_cmd
}

# Pass variables to rofi dmenu
run_rofi() {
	echo -e "$lock\n$suspend\n$logout\n$reboot\n$shutdown" | rofi_cmd
}

# Execute Command
run_cmd() {
	selected="$(confirm_exit)"
	if [[ "$selected" == "$yes" ]]; then
		if [[ $1 == '--shutdown' ]]; then
			systemctl poweroff
		elif [[ $1 == '--reboot' ]]; then
			systemctl reboot
		elif [[ $1 == '--suspend' ]]; then
			mpc -q pause
			amixer set Master mute
			systemctl suspend
		elif [[ $1 == '--logout' ]]; then
			hyprctl dispatch exit 1
		fi
	else
		exit 0
	fi
}

# Actions
chosen="$(run_rofi)"
case ${chosen} in
$shutdown)
	run_cmd --shutdown
	;;
$reboot)
	run_cmd --reboot
	;;
$lock)
    swaylock
	;;
$suspend)
	run_cmd --suspend
	;;
$logout)
	run_cmd --logout
	;;
esac
