Litterbox
=========
Simple shell functions using `bubblewrap` to sandbox apps.

_LITTERBOX
----------
* limited readonly view of filesystem
* only r/w /tmp
* no net

_LITTERBOX_READONLY
-------------------
* full readonly view of filesystem
* only r/w /tmp
* no net

_LITTERBOX_NET
--------------
* limited readonly view of filesystem
* only r/w /tmp
* network available

_LITTERBOX_RWCWD
----------------
* full readonly view of filesystem
* r/w /tmp
* r/w current working directory (not home!)
* no net

Credits
-------
Inspired by [https://patrickmccanna.net/a-better-way-to-limit-claude-code-and-other-coding-agents-access-to-secrets/](https://patrickmccanna.net/a-better-way-to-limit-claude-code-and-other-coding-agents-access-to-secrets/)
