#!/bin/sh

# path:   /home/klassiker/.local/share/repos/terminal-analysis/terminal_colors.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/terminal-analysis
# date:   2025-03-30T06:50:21+0200

# speed up script and avoid language problems by using standard c
LC_ALL=C
LANG=C

# help
script=$(basename "$0")
help="$script [-h/--help] -- script to show terminal colors
  Usage:
    $script [-n]

  Settings:
    [-n] = hide numbers/pattern

  Example:
    $script
    $script -n"

column_quantity="$(stty size | cut -d' ' -f2)"
block_quantity="$((column_quantity / 30))"

plot() {
    case "$2" in
        1)
            case "$1" in
                0 | 8 | 16 | 52 | 88 | 124 | 160 | 196 | 232)
                    color=37
                    ;;
                7 | 9 | 34 | 70 | 106 | 142 | 178 | 214 | 244)
                    color=30
                    ;;
            esac
            printf "\033[48;5;%dm\033[1;%dm %3d \033[0m" "$1" "$color" "$1"
            ;;
        0)
            printf "\033[48;5;%dm     \033[0m" "$1"
            ;;
    esac
}

base_color() {
    start_column=0
    end_column=15
    while [ "$start_column" -le "$end_column" ]; do
        plot "$start_column" "$1"
        n=$((start_column - 7))
        [ $((n % 8)) -eq 0 ] \
            && printf "\n"
        start_column=$((start_column + 1))
    done
}

color() {
    start_column=16
    end_column=231
    case $block_quantity in
        1 | 2 | 3)
            block=$block_quantity
            ;;
        4 | 5)
            block=3
            ;;
        *)
            block=6
            ;;
    esac
    column_num=$((block * 6))
    column_counter=0
    while [ "$start_column" -le "$end_column" ]; do
        plot "$start_column" "$1"
        start_column=$((start_column + 1))
        column_counter=$((column_counter + 1))
        if [ "$column_counter" -eq "$column_num" ]; then
            n=$((start_column - 16))
            [ $((n % 36)) -ne 0 ] \
                && n=$((block - 1)) \
                && start_column=$((start_column - n * 36))
            column_counter=0
            printf "\n"
        elif [ $((column_counter % 6)) -eq 0 ] \
            && [ $((start_column + 30)) -le "$end_column" ]; then
                start_column=$((start_column + 30))
        fi
    done
}

greyscale() {
    start_column=232
    end_column=255
    case $block_quantity in
        1 | 2)
            block=$block_quantity
            ;;
        3)
            block=2
            ;;
        *)
            block=4
            ;;
    esac
    column_num=$((block * 6))
    while [ "$start_column" -le "$end_column" ]; do
        plot "$start_column" "$1"
        n=$((start_column - 15))
        [ $((n % column_num)) -eq 0 ] \
            && printf "\n"
        start_column=$((start_column + 1))
    done
}

true_color() {
    case $1 in
        1)
            pattern="|_|¯|_|¯|_|¯"
            ;;
        0)
            pattern="            "
            ;;
    esac
    while [ "${column:-0}" -lt "$column_quantity" ]; do
        red=$((255 - (column * 255 / column_quantity)))
        green=$((column * 510 / column_quantity))
        blue=$((column * 255 / column_quantity))
        [ $green -gt 255 ] \
            && green=$((510 - green))
        printf "\033[48;2;%d;%d;%dm" \
            "$red" \
            "$green" \
            "$blue"
        printf "\033[38;2;%d;%d;%dm" \
            "$((255 - red))" \
            "$((255 - green))" \
            "$((255 - blue))"
        printf "%s\033[0m" \
            "$pattern"
        column=$((column + 1))
    done
    printf "\n"
}

output() {
    # color variables
    reset="\033[0m"
    bold="\033[1m"
    green="\033[32m"
    blue="\033[94m"

    [ "$column_quantity" -lt 40 ] \
        && printf "sorry, the window must be at least 40 columns wide\n" \
        && exit 1

    printf "%b%b::%b %bbase colors%b\n" \
        "$bold" "$blue" "$reset" "$bold" "$reset"
    base_color "$1"
    printf "%b%b::%b %bcolor palette%b\n" \
        "$bold" "$blue" "$reset" "$bold" "$reset"
    color "$1"
    printf "%b%b::%b %bgreyscale%b\n" \
        "$bold" "$blue" "$reset" "$bold" "$reset"
    greyscale "$1"
    printf "%b%b::%b %btrue colors%b\n" \
        "$bold" "$blue" "$reset" "$bold" "$reset"
    true_color "$1"
}

case $# in
    0)
        output 1
        ;;
    *)
        case "$1" in
            -h | --help)
                printf "%s\n" "$help"
                exit 0
                ;;
            -n)
                output 0
                ;;
            *)
                printf "%s\n" "$help"
                exit 1
                ;;
        esac
        ;;
esac
