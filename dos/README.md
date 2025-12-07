bullsh and SH-DOS
=================

Motivation
----------
It is 2025 and people \*still\* send me paths with backslashes like it's the early eighties.


Bullsh and SH-DOS solves this insufferable problem by allowing slashes to be entered the wrong way.

SH-DOS
------
Fake DOS command.com in Linux for gags and giggles with backslashes and SCREAMCASE.

Use the colors from IBM 5153 so type'ed `.nfo` and ascii art looks decent.

`type` uses CP437 and prints at whooping 300 baud.

bullsh
------
Still backslashes, but without SCREAMCASE. Any resemblence to PowerShell is purely coincidental.
Front slashes and backslashes can be mixed freely. Normal shell syntax is available.

Useful for accessing `\\SHARE\With\sub\Directory\`

Tip: Manually create a link to SHARE in the root, then the UNC path above can be resolved.

Bugs
----
`printf` is unusable
