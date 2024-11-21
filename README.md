# My dotfiles


You may not like it, but this is what peak dotfiles look like

# link:
ln -s ${PWD}/bashrc ~/.bashrc



bashrc


[can-opener](can-opener/README.md) - open files/directories/executables in the background: o


[chdir(2) ALL THE THINGS](chdir-all-the-things/README.md) - chdir into directores, archives, and more


[dos](dos/README.md) - because backslashes


[emojify](emojify/README.md) - translate github emoji names to emojis :poop:


[ermahgerd](ermahgerd/README.md) - rm emulator putting files in xdg trash instead of actually deleting, handy restore cmd named 'doh'


[fubbick](fubbick/README.md) - git in Swedish scanian dialect - skånska


[fonts](fonts/README.md) - hacked and patched fonts


fonts.conf - font substitutions


[fuuuu](fuuuu/README.md) - select field using awk, optionally set separator as first arg


[i-like-to-move-it](i-like-to-move-it/README.md) - rencwd() unspace()


[moar](moar/README.md) - less for the lazy


git-prompt


bash-preexec - https://github.com/rcaloras/bash-preexec


Functions
=========
Conventions
-----------
Functions starting with '_' and uppercase are internal and not intended to be 
called by the user interactively.
Internal functions may have a alias definition such that they can be called, 
superceeded or renamed by the user:

eg.
```
alias retry=_RETRY
```

This way, the user may call a binary in the path by writing
```
\retry 
```


Should such a collision occur, the user may override it in ~/.bashrc.local


Interactive helper functions/aliases
====================================
f: field selector:
```
echo a b c| f 1
a
``` 
optional delimiter as first argument
```
echo a-b-c|f - 2
b
```


loop: run command in loop endlessly


retry: run command until succeeds


untilfail: run command until failure


d: universal file previewer


fz: fuzzy find files and assign to the 'f' variable


dz: fuzzy find text from last logged output (with _LOG()) and assign to the 'f' variable


b: fuzzy select git branch to switch to


timer: simple timer app, first argument is minutes


o: open applications, directories, files, and urls in an associated windowed application


z: zip-compress a file, and select it in the file manager.


s: select a file in file manager


dl: move latest file from Downloads to current directory


rm: like regular rm(1), but files are placed in Trash, override with \rm


doh: restore last removed file from Trash

cplast: provide multiple source items to `cplast` only last source item will be copied, ie. use with globbing:
```
cplast Screenshot* .
```

ls: like regular ls(1), but entries listed in .hidden are ignored, override with \ls


gradient: create prompt gradient

Alias helper functions
======================
These are the helper functions to aid the user in writing rich aliases for commands.

Eg. 
```
alias mycommand='_ICON 🚀 _NO_MEASAURE _IDLE_PRIO mycommand'
```

Commands
--------
_LOG () : log all output to a file. This can later be viewed with dogeview without parameters: 'd'; also implies low priority, cannot be used with _LOW_PRIO()


_ICON () : first argument becomes the title icon for the command, further custom editing of the command line as printed in the title may occur.


_LOW_PRIO () : use low priority for processes: useful for heavy non-interactive processes as to not disturb low-latency tasks such as playing audio and video conferencing, must be last in alias list, cannot be used with _LOG()


_NO_MEASURE () : do not print timing statistics for programs as this is not needed for instance in interactive commands.


_MOAR (): prints stdout to a pager if not in a pipe


_CHROME-POLISHER (): wipe chrome data and start a new browser


_SPINNER_START(): print an ascii spinner


_SPINNER_STOP(): stop the ascii spinner

Prompt
======
Beautiful gradient line as prompt with git prompt, timing statistics, tab icon, and magic shellball answers when pressing enter multiple times.


Read more: [prompt/README.md](prompt/README.md)

Shabacus
========
[shabacus](shabacus/README.md) - type regular mathematical infix notation formulas at the prompt:
eg.
```
3 * 942
```

Stawkastic
==========
[stawkastic](stawkastic/README.md) - handy awk statistical functions


