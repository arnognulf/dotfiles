#!/bin/bash

COUNT=0
while sleep 1;
do
    if LC_ALL=C gnome-screensaver-command -q | grep "is active"
    then
        COUNT=0
    else
        let COUNT++
    fi

    if [ $COUNT -ge 1200 ]
    then
        notify-send.py "DEAL WITH IT" --action ok:"▝▔▔▀▀▀▀▔▀▀▀" --icon ~/.config/dotfiles/deal-with-it/deal-with-it.png -u critical
        sleep 20
        mplayer /usr/share/sounds/gnome/default/alerts/drip.ogg
        COUNT=0
    fi
done