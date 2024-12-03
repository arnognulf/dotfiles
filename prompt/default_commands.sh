#!/bin/bash
# editors and debuggers need to be responsive
interactive_command 📝 nvim 
interactive_command 📝 vim 
interactive_command 📝 joe 
interactive_command 📝 mg 
interactive_command 📝 nano 
interactive_command 📝 pico 
interactive_command 📝 em 
interactive_command 📓 man
interactive_command 📈 top
interactive_command 📈 ntop
interactive_command 📈 nvtop
interactive_command 📈 htop
interactive_command 📈 nload
interactive_command 🤖 adb
interactive_command 🤖 gdb

# shells are listed as batch commands
# since these are often used to call a heavy batch script
# for interactive use, call the shell as 'exec bash'
batch_command 🐚 bash
batch_command 🐚 zsh
batch_command 🐚 ksh
batch_command 🐚 sh

# Compilers and build systems can take a long time and use lots of computer
# resources.
# Use low priority so rest of the system becomes available in the mean time
batch_command 🛠️ clang
batch_command 🛠️ gcc
batch_command 🛠️ gcc
batch_command 🛠️ g++
batch_command 🛠️ snapcraft
batch_command 🛠️ ninja
batch_command 🛠️ make
batch_command 🛠️ bitbake

batch_command 🗜️ gzip
batch_command 🗜️ unrar
batch_command 🗜️ 7z
batch_command 🗜️ unar
batch_command 🗜️ bzip2
batch_command 🗜️ xz
batch_command 🧮 bc
batch_command 🪚 awk
batch_command 🐱 cat
batch_command Δ delta
batch_command Δ diff
batch_command 💽 cp
batch_command 💽 dd
batch_command 📼 tar
batch_command 🪣 repo
batch_command 🪣 git
batch_command 🪣 svn
batch_command 🪣 hg
batch_command 🪣 cvs
batch_command 🔎 fd
batch_command 🔎 fdfind
batch_command 🔎 find
batch_command 🔎 rga
batch_command 🔎 rg
batch_command 👣 strace
batch_command ♻️  rm 
batch_command ♻️  jdupes
batch_command ♻️  fclones

