hog - version control for multi-gigabyte repos
==============================================

Hog is a version control system loosely modeled after git suitable for mutli-gigabyte artifacts where changes are small but scattered, eg. builds of Yocto or AOSP.


Reflinks are currently supported on XFS, F2FS, btrfs, and bcachefs, while hog can be used on a non-reflink-supported file system, it is not recommended as it will copy files and grow very fast for each commit.


Hog relies on the reflink syscall [1] to create copy-on-write snapshots - "commits" - of the current working tree, these are small in terms of storage and fast to create.


Reflinked files will share blocks, but if a block is re-written, the block needs to be written to another place which allocates more space and disk full may result if too many blocks are re-written.


[1] https://blogs.oracle.com/linux/post/xfs-data-block-sharing-reflink