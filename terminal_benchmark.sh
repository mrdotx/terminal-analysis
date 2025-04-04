#!/bin/sh

# path:   /home/klassiker/.local/share/repos/terminal-analysis/terminal_benchmark.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/terminal-analysis
# date:   2025-03-29T06:04:08+0100

# speed up script and avoid language problems by using standard c
LC_ALL=C
LANG=C

#config
ascii="x"
unicode="😀"
lines="$(stty size | cut -d' ' -f1)"
columns="$(stty size | cut -d' ' -f2)"
columns_unicode="$((columns / 2))"
columns_mixed="$((columns * 2 / 3))"

[ "$1" -ge 1 ] > /dev/null 2>&1 \
    && outputs="$1" \
    || outputs=100000

# color variables
reset="\033[0m"
bold="\033[1m"
blue="\033[94m"

# help
script=$(basename "$0")
help="$script [-h/--help] -- script to benchmark the terminal
  Usage:
    $script [outputs]

  Settings:
    [outputs] = number of outputs for the sections (default: $outputs)

  Example:
    $script
    $script 250000"

case "$1" in
    -h | --help)
        printf "%s\n" "$help"
        exit 0
        ;;
    *)
        [ $# -ge 1 ] \
            && ! [ "$1" -ge 1 ] > /dev/null 2>&1 \
            && printf "%s\n" "$help" \
            && exit 1
        ;;
esac

# helper functions
calc() {
    printf "%s\n" "$*" | bc -l
}

line_fill() {
    for i in $(seq 1 "$((columns / $2))"); do
        printf "%s" "$1"
    done
}

output_reading() {
    start=$(date +%s.%N)
    for i in $(seq 1 "$outputs"); do
        printf "%b" "$*"
    done
    end=$(date +%s.%N)
}

# ansi seq chars
r="\033[31m"
g="\033[32m"
y="\033[33m"
b="\033[34m"
m="\033[35m"
c="\033[36m"
ansi_colors="$r red $g green $y yellow $b blue $m magenta $c cyan "
re="\033[0m"
bo="\033[1m"
it="\033[3m"
ul="\033[4m"
in="\033[7m"
ansi_string="\
$bo$it$ul${in}bold & italic & underline & invert$re
${bo}bold$re ${it}italic$re ${ul}underline$re ${in}invert$re
$in$ansi_colors$re
$ansi_colors$re
$in$bo$ansi_colors$re
$bo$ansi_colors$re
$in$it$ansi_colors$re
$it$ansi_colors$re
$in$ul$ansi_colors$re
$ul$ansi_colors$re
"
ansi_num=$((8 * 41 + 62))
output_reading "$ansi_string"
ansi_duration=$(calc "$end - $start")
ansi_chars=$(calc "$ansi_num * $outputs / $ansi_duration")

# ascii chars
ascii_string=$(line_fill "$ascii" 1)
output_reading "$ascii_string\n"
ascii_duration=$(calc "$end - $start")
ascii_chars=$(calc "$columns * $outputs / $ascii_duration")

# unicode chars
unicode_string=$(line_fill "$unicode" 2)
output_reading "$unicode_string\n"
unicode_duration=$(calc "$end - $start")
unicode_chars=$(calc "$columns_unicode * $outputs / $unicode_duration")

# mixed chars
mixed_string=$(line_fill "$bo$in$r$ascii$unicode$re" 3)
output_reading "$mixed_string\n"
mixed_duration=$(calc "$end - $start")
mixed_chars=$(calc "$columns_mixed * $outputs / $mixed_duration")

# results
printf "\033c%b%b::%b %b%s ansi seq chars%b\n%b" \
    "$bold" "$blue" "$reset" "$bold" "$ansi_num" "$reset" "$ansi_string"
printf "%b%b::%b %b%s(+-1) ascii chars%b\n%b\n" \
    "$bold" "$blue" "$reset" "$bold" "$columns" "$reset" "$ascii_string"
printf "%b%b::%b %b%s(+-1) unicode chars%b\n%b\n" \
    "$bold" "$blue" "$reset" "$bold" "$columns_unicode" "$reset" "$unicode_string"
printf "%b%b::%b %b%s(+-1) mixed chars%b\n%b\n" \
    "$bold" "$blue" "$reset" "$bold" "$columns_mixed" "$reset" "$mixed_string"
printf "%b%b::%b %b%s terminal outputs per section%b\n" \
    "$bold" "$blue" "$reset" "$bold" "$i" "$reset"
printf "%s;%.3f;%.0f\n%s;%.3f;%.0f\n%s;%.3f;%.0f\n%s;%.3f;%.0f\n%s;%s;%s\n%s;%.3f;%.0f\n" \
    "ansi seq" "$ansi_duration" "$ansi_chars" \
    "ascii" "$ascii_duration" "$ascii_chars" \
    "unicode" "$unicode_duration" "$unicode_chars" \
    "mixed" "$mixed_duration" "$mixed_chars" \
    "[$((outputs * 4))]" "in seconds" "per second" \
    "total" \
    "$(calc "$ansi_duration + $ascii_duration + $unicode_duration + $mixed_duration")" \
    "$(calc "$ansi_chars + $ascii_chars + $unicode_chars + $mixed_chars")" \
        | column \
            --separator ";" \
            --table \
            --table-columns "[${columns}x$lines],duration,chars" \
            --table-right "2-3"
