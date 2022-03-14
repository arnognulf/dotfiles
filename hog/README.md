hog - version control for multi-gigabyte repos
==============================================

Hog is a version control system loosely modeled after git suitable for mutli-gigabyte artifacts where changes are small but scattered, eg. builds of Yocto or AOSP.


Reflinks are currently supported on XFS, F2FS, btrfs, and bcachefs, while hog can be used on a non-reflink-supported file system, it is not recommended as it will copy files and grow very fast for each commit.


Hog relies on the reflink syscall [1] to create copy-on-write snapshots - "commits" - of the current working tree, these are small in terms of storage and fast to create.


Reflinked files will share blocks, but if a block is re-written, the block needs to be written to another place which allocates more space and disk full may result if too many blocks are re-written.


Where is diff/status/merge/branch/etc
-------------------------------------
Hog only creates non-atomic snapshots, these reflink snapshots onlly consume a fraction of what the real data would take, however if these files are read, it would take the same time as reading non-reflinked files.


Doing a diff (even a smart one) on two snapshots could be a very time consuming task.

When to use git and when to use hog
-----------------------------------
If your working directory is larger than ~50% of your disk space, use hog.
If git is painfully slow when handling your repository (and VFSForGit is not an option), use hog.
Otherwise, use git.

[1] https://blogs.oracle.com/linux/post/xfs-data-block-sharing-reflink