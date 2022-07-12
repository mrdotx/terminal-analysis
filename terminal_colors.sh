#!/bin/sh

# path:   /home/klassiker/.local/share/repos/terminal-colors/terminal_colors.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/terminal-colors
# date:   2022-07-12T11:13:28+0200

script=$(basename "$0")
help="$script [-h/--help] -- script to show terminal colors
  Usage:
    $script [-n]

  Settings:
    [-n] = hide numbers/pattern

  Example:
    $script
    $script -n"

plot() {
    case "$3" in
        1)
            if [ "$1" -eq 7 ] \
                || [ "$1" -ge "$2" ]; then
                    color=30
            else
                color=37
            fi

            printf "\033[48;5;%sm\033[1;%sm %3d \033[0m" "$1" "$color" "$1"
            ;;
        0)
            printf "\033[48;5;%sm     \033[0m" "$1"
            ;;
    esac
}

base_color() {
    start_column=0
    color_toggle=9
    end_column=15
    while [ "$start_column" -le "$end_column" ]; do
        plot "$start_column" "$color_toggle" "$1"
        n=$((start_column - 7))
        [ $((n % 8)) -eq 0 ] \
            && printf "\n"
        start_column=$((start_column + 1))
    done
}

color() {
    start_column=16
    color_toggle=124
    end_column=231
    block=$(($(tput cols) / 30))
    if [ "$block" -ge 6 ]; then
        block=6
    elif [ "$block" -ge 3 ]; then
        block=3
    fi
    column_num=$((block * 6))
    column_counter=0
    while [ "$start_column" -le "$end_column" ]; do
        plot "$start_column" "$color_toggle" "$1"
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
    color_toggle=244
    end_column=255
    block=$(($(tput cols) / 30))
    if [ "$block" -ge 4 ]; then
        block=4
    elif [ "$block" -ge 2 ]; then
        block=2
    fi
    while [ "$start_column" -le "$end_column" ]; do
        plot "$start_column" "$color_toggle" "$1"
        n=$((start_column - 15))
        m=$((block * 6))
        [ $((n % m)) -eq 0 ] \
            && printf "\n"
        start_column=$((start_column + 1))
    done
}

true_color() {
    awk -v pattern="$1" -v column_quantity="$(($(tput cols) * 12))" 'BEGIN{
        for (column = 0; column<column_quantity; column++) {
            r = 255-(column*255/column_quantity);
            g = (column*510/column_quantity);
            b = (column*255/column_quantity);
            if (g>255) g = 510-g;
            printf "\033[48;2;%d;%d;%dm", r,g,b;
            printf "\033[38;2;%d;%d;%dm", 255-r,255-g,255-b;
            printf "%s\033[0m", substr(pattern,column%length(pattern)+1,1);
        }
        printf "\n";
    }'
}

output() {
    printf "%s\n" ":: base colors"
    base_color "$1"
    printf "%s\n" ":: color palette"
    color "$1"
    printf "%s\n" ":: greyscale"
    greyscale "$1"
    printf "%s\n" ":: true colors"
    true_color "$2"
}

if [ $# -eq 0 ]; then
    output "1" "|_|¯"
else
    case "$1" in
        -h | --help)
            printf "%s\n" "$help"
            exit 0
            ;;
        -n)
            output "0" " "
            ;;
        *)
            printf "%s\n" "$help"
            exit 1
            ;;
    esac
fi
