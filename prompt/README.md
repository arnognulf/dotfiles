prompt
======

features:


* horizontal delimiter which makes it easy to find where a command started in the scrollback
* minimalistic prompt, shows basename of directory and git branch if available with inverted text - no distracting colors!
* commands that do not write newline (eg. echo -n foo) gets appended a newline
* title which display emoji icon and directory basename or running command
* long running command gets timing statistics and a notification is sent with notify-send + sound is played
* pressing RETURN multiple times gives ls, git status and finally magic shellball answers
