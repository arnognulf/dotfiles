CHDIR ALL THE THINGS!
=====================

Usage: 

c <directory>
-------------
Recurse cd into all single subdirectories if no other files exists - handy when entering java packages.

c ..
----
Recurse backwards all single subdirectories if no other files exists.

c <archive>
-----------
Create a directory for the archive, cd into it and unpack it in the root of that directory.
This means that it will not matter if archive was compressed with a subfolder or not.
If a directory part is included as part of the archive argument, CHDIR ALL THE THINGS! will not directly
decompress if file is of mime type application/
However, if no directory part is included, it will directly decompress.
This is an extra safety measure against eg. exe files, that mostly aren't expected to be decompressed.

The archive will be disposed in the xdg wastebasket unless -k is given as argument.

c <git-repo>
------------
Do a shallow git clone and cd into it's working directory

c <file>
--------
Go to directory containing file

c tmp
-----
Create temp dir with tab compatible prefix + ISO8601isch date + three random words from dict

c <non-existant dir>
--------------------
Create directory with name, and enter.
If no files are created in the directory, it will be removed once CHDIR ALL THE THINGS! away from the directory.
If basename is similar to already existing dir, the directory will not be created.

c <file1> <file2> <file3>
-------------------------
Decompress multiple files on command line, but do not chdir into them.

c //WORKSPACE/windows_share/dir
-------------------------------
Open Windows share
