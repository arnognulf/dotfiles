Litterbox
=========
Simple auditable shell functions using `bubblewrap` to sandbox apps.

_LITTERBOX
----------
* limited readonly view of filesystem
* only r/w /tmp
* no net

_LITTERBOX_RO
-------------
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

_LITTERBOX_RWCWD_NET
--------------------
* full readonly view of filesystem
* r/w /tmp
* r/w current working directory (not home!)
* network available

Credits
-------
Inspired by [https://patrickmccanna.net/a-better-way-to-limit-claude-code-and-other-coding-agents-access-to-secrets/](https://patrickmccanna.net/a-better-way-to-limit-claude-code-and-other-coding-agents-access-to-secrets/)
