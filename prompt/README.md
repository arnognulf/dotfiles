prompt
======

features:


* horizontal delimiter which makes it easy to find where a command started in the scrollback
* minimalistic prompt, shows basename of directory and git branch if available with inverted text - no distracting colors!
* commands that do not write newline (eg. echo -n foo) gets appended a newline
* title which display emoji icon and directory basename or running command
* long running command gets timing statistics and a notification is sent with notify-send + sound is played
  these can be disabled by setting '_MEASURE=0;' before running the command, note the semi-colon
* pressing RETURN multiple times gives ls, git status and finally magic shellball answers

support
=======
gradient colors are supported on
* libvte based terminals: gnome-terminal, xfce4-terminal
* kitty
* alacritty
* konsole
* xterm
* screen
* stterm

truecolor is not supported on
* rxvt, rxvt-unicode
* vt100
* Mac OS X Terminal

FAQ
===
Q: Gradient turns grey or disappears mid-line/mid-text, why?
A: The gradient look-up-table may be malformed. Verify that all elements have three parameters in the range of 0-255, separated by semicolons ';', eg. "64;29;128".

