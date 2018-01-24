#!/bin/bash
 
# This program is free software. It comes without any warranty, to
# the extent permitted by applicable law. 
# See http://sam.zoy.org/wtfpl/COPYING for more details.
 
for fgbg in 38 48 ; do # Foreground / Background
    for color in {0..255} ; do # Colors
        # Display the color
        printf "\e[${fgbg};5;%sm  %3s  \e[0m" $color $color
        # Display 6 colors per lines
        if [ $((($color + 1) % 6)) == 4 ] ; then
            echo # New line
        fi
    done
    echo # New line
done
 
exit 0


