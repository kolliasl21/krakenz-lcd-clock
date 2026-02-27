#!/bin/bash

BRIGHTNESS=-1
SPEED=()
GIF=
FONT="/usr/share/fonts/noto/NotoSansKannadaUI-Light.ttf"
CLOCK=

print_usage() {
	cat <<-EOF
		Wrong input! Available flags:
		-b brightness:0-100%
		-l liquid lcd mode
		-g gif lcd mode
		-s pump speed:0-100%,0-100C
		-c change .gif
		-t clock mode
		-d load default profile
		-p load user profile
	EOF
}

set_lcd_mode() {
	[[ -z $GIF ]] && echo "GIF not set!" && exit 1
	liquidctl --match NZXT set lcd screen "$1" "$2"
}

draw_clock_image() {
	while true; do
		magick	-gravity center \
			-background black \
			-fill purple \
			-size 320x320 \
			-font ${FONT} \
			caption:"$(date +%H:%M)" /tmp/time.png
		set_lcd_mode "static" "/tmp/time.png"
		sleep 60
	done
}

liquidctl initialize all > /dev/null 2>&1

while getopts "b:lgs:c:tdp" flag; do
	case "${flag}" in
		b) BRIGHTNESS="${OPTARG}" ;;
		l) set_lcd_mode "liquid" ;;
		g) set_lcd_mode "gif" "${GIF}" ;;
		s) SPEED+=("${OPTARG}") ;;
		c) GIF="${OPTARG}" ;; 
		t) CLOCK=1 ;; 
		d) BRIGHTNESS=50 SPEED=(20 40 23 50 30 70); set_lcd_mode "liquid"; break ;;
		p) BRIGHTNESS=0  SPEED=(35); set_lcd_mode "gif" "${GIF}"; break ;;
		*) print_usage; exit 0 ;;
	esac
done

[[ ${BRIGHTNESS} -ge 0 ]] && [[ ${BRIGHTNESS} -le 100 ]]  && \
	liquidctl --match NZXT set lcd screen brightness "${BRIGHTNESS}"

[[ ${#SPEED[@]} -gt 0 ]] && \
	(IFS=,; liquidctl --match NZXT set pump speed ${SPEED[*]})

[[ -n $CLOCK ]] && draw_clock_image
