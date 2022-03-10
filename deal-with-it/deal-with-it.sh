#!/bin/bash

OLD_PID=$(cat ~/.cache/deal-with-it.pid 2>/dev/null)
if [ "${OLD_PID}" != "$$" ]
then
exit 0
fi
echo -n "$$" >~/.cache/deal-with-it.pid
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
        if type -p notify-send.py &>/dev/null
        then
            notify-send.py "DEAL WITH IT" --action ok:"▝▔▔▀░▒▓▀▔▀▓▀" --icon ~/.config/dotfiles/deal-with-it/deal-with-it.png -u critical
        else
            python3 ~/.config/dotfiles/deal-with-it/multi-actions.py
        fi
        sleep 20
        mplayer /usr/share/sounds/gnome/default/alerts/drip.ogg
        COUNT=0
    fi
done