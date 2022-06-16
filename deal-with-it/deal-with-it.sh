#!/bin/bash
# great research in stretchly: https://hovancik.net/stretchly/research/

OLD_PID=$(cat ~/.cache/deal-with-it.pid 2>/dev/null)
if [ "${OLD_PID}" != "$$" ]
then
exit 0
fi
echo -n "$$" >~/.cache/deal-with-it.pid
COUNT=0
WALKCOUNT=0
killAfter5Min ()
{
    sleep 300 && kill -9 $(command ps aux|command grep multi-actions.py|command grep -v grep|command awk '{ print $2 }';) &>/dev/null; 
}
while sleep 1;
do
    if LC_ALL=C gnome-screensaver-command -q | grep "is active"
    then
        COUNT=0
        WALKCOUNT=0
    else
        let COUNT++
    fi
    
    BEEP=0
    if [ $COUNT -ge 1200 ]
    then
        if type -p notify-send.py &>/dev/null
        then
            notify-send.py "DEAL WITH IT" --action ok:"▝▔▔▀░▒▓▀▔▀▓▀" --icon ~/.config/dotfiles/deal-with-it/deal-with-it.png -u critical
        else
            ## if notification is forgotten or placed behind another notification, kill it after 5min
            ( killAfter5Min & )
            if [ ${WALKCOUNT} -ge 3 ]
            then
                ## every hour, take 5min walk
                ## make your cardiologist happy
                python3 ~/.config/dotfiles/deal-with-it/multi-actions.py "𓀟 𓀟 𓀟" "WALK THE WALK"
            else
                ## 20-20-20 rule:
                ## every 20 minutes, look 20 feet (6m) away for 20 seconds
                ## make your ophtologist happy
                python3 ~/.config/dotfiles/deal-with-it/multi-actions.py "▝▔▔▀▓▒▓▀▔▀▓▀" "DEAL WITH IT" && BEEP=1
                let WALKCOUNT++
            fi
        fi
        sleep 20
        [[ $BEEP == 1 ]] && mplayer /usr/share/sounds/gnome/default/alerts/drip.ogg
        COUNT=0
        let WALKCOUNT++
    fi
done