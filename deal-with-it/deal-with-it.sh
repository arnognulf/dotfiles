#!/bin/bash

OLD_PID=$(cat ~/.cache/deal-with-it.pid 2>/dev/null)
if [ "${OLD_PID}" != "$$" ]
then
exit 0
fi
echo -n "$$" >~/.cache/deal-with-it.pid
COUNT=0
WALKCOUNT=0
killAfter10Min ()
{
    sleep 600 && kill -9 $(command ps aux|command grep multi-actions.py|command grep -v grep|command awk '{ print $2 }';) &>/dev/null; 
}
while sleep 1;
do
    if LC_ALL=C gnome-screensaver-command -q | grep "is active"
    then
        COUNT=0
    else
        let COUNT++
    fi

    #if [ $WALKCOUNT -ge 2 ]
    #then
    #    ( killAfter10Min & )
    #    python3 ~/.config/dotfiles/deal-with-it/multi-actions.py "WALK LIKE AN EGYPTIAN" "𓀛𓅱𓃝"
    #    WALKCOUNT=0
    #elif [ $COUNT -ge 1200 ]
    if [ $COUNT -ge 1200 ]
    then
        if type -p notify-send.py &>/dev/null
        then
            notify-send.py "DEAL WITH IT" --action ok:"▝▔▔▀░▒▓▀▔▀▓▀" --icon ~/.config/dotfiles/deal-with-it/deal-with-it.png -u critical
        else
            ( killAfter10Min & )
            python3 ~/.config/dotfiles/deal-with-it/multi-actions.py
        fi
        sleep 20
        mplayer /usr/share/sounds/gnome/default/alerts/drip.ogg
        COUNT=0
        let WALKCOUNT++
    fi
done