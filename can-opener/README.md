CAN OPENER
==========

A command that forks a process and hides its output. Useful starting graphical which outputs
lots of GTK logging and continuing to work another task in the same terminal.

A better replacement for running

command &

Aliases will be created for known graphical programs.
If this causes problems, the alias can temporarily be disabled by prepending slash:

\command

'o' without arguments will open the current folder in the file manager 

'o' with a file will try to open it with xdg-open

'o' with a program and argument will put the program in the background, debug output will be hidden.

'o' with a URL will try to open a web browser
