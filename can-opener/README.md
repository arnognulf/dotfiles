CAN OPENER
==========

Command similar to open in Mac OS X - but shorter to write and some more logic.
Replacement for running

command &

and enable the program to live on once the terminal has been closed.
Aliases will be created for known graphical programs.
If this causes problems, the alias can temporarily be disabled by prepending slash:

\command

'o' without arguments will open the current folder in the file manager 
'o' with a file will try to open it with xdg-open
'o' with a program and argument will put the program in the background, debug output will be hidden.
'o' with a URL will try to open a web browser
