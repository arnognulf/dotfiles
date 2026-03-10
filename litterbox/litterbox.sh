#!/bin/bash
# cred: https://patrickmccanna.net/a-better-way-to-limit-claude-code-and-other-coding-agents-access-to-secrets/
#: <<EOF
#bwrap \
#     --ro-bind /usr /usr \
#     --ro-bind /lib /lib \
#     --ro-bind /lib64 /lib64 \
#     --ro-bind /bin /bin \
#     --ro-bind /etc/resolv.conf /etc/resolv.conf \
#     --ro-bind /etc/hosts /etc/hosts \
#     --ro-bind /etc/ssl /etc/ssl \
#     --ro-bind /etc/passwd /etc/passwd \
#     --ro-bind /etc/group /etc/group \
#     --ro-bind "$HOME/.gitconfig" "$HOME/.gitconfig" \
#     --ro-bind "$HOME/.nvm" "$HOME/.nvm" \
#     --bind "$PROJECT_DIR" "$PROJECT_DIR" \
#     --bind "$HOME/.claude" "$HOME/.claude" \
#     --tmpfs /tmp \
#     --proc /proc \
#     --dev /dev \
#     --share-net \
#     --unshare-pid \
#     --die-with-parent \
#     --chdir "$PROJECT_DIR" \
#     --ro-bind /dev/null "$PROJECT_DIR/.env" \
#     --ro-bind /dev/null "$PROJECT_DIR/.env.local" \
#     --ro-bind /dev/null "$PROJECT_DIR/.env.production" \
#     "$(command -v claude)" --dangerously-skip-permissions "Please review 
#EOF

_LITTERBOX ()
{
if [ -z "$1" ];then
echo "_LITTERBOX: limited readonly view of filesystem, only r/w /tmp, no net"
return 1
fi
bwrap --ro-bind /usr /usr --symlink usr/lib /lib --symlink usr/lib64 /lib64 \
      --symlink usr/bin /bin --proc /proc --dev /dev --tmpfs /tmp \
      --unshare-all --die-with-parent \
      "$@"
}

_LITTERBOX_READONLY ()
{
if [ -z "$1" ];then
echo "_LITTERBOX_READONLY: full readonly view of filesystem, only r/w /tmp, no net"
return 1
fi
bwrap --ro-bind / / --proc /proc --dev /dev --tmpfs /tmp \
      --unshare-all --die-with-parent \
      "$@"
}

_LITTERBOX_NET ()
{
if [ -z "$1" ];then
echo "_LITTERBOX_NET: limited readonly view of filesystem, only r/w /tmp, network available"
return 1
fi
bwrap --ro-bind /usr /usr --symlink usr/lib /lib --symlink usr/lib64 /lib64 \
      --symlink usr/bin /bin --proc /proc --dev /dev --tmpfs /tmp \
      --die-with-parent --unshare-pid \
      --share-net \
      "$@"
}

_LITTERBOX_RWCWD ()
{
if [ -z "$1" ];then
echo '_LITTERBOX_RWCWD: full readonly view of filesystem, r/w /tmp, r/w current working directory (not home!), no net'
return 1
fi
if [[ "$PWD" = "$HOME" ]];then
echo "_LITTERBOX_RWCWD: running in \$HOME not allowed"
return 1
fi
bwrap --ro-bind / / --bind "$PWD" "$PWD" --proc /proc --dev /dev --tmpfs /tmp \
      --unshare-all --die-with-parent \
      "$@"
}


