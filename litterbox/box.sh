#!/usr/bin/env bash
# from:
# https://bxt.rs/blog/easy-sandboxing-on-linux-with-bubblewrap/

set -euo pipefail

PASS_KVM="${PASS_KVM:-1}"

if [[ "$PASS_KVM" -eq 1 ]]; then
	[[ -c /dev/kvm ]] && BWRAP+=(--dev-bind /dev/kvm /dev/kvm)
fi

# Export PASS_WAYLAND=1 to enable Wayland access.
# Warning: it is currently NOT SANDBOXED (e.g. with security-context protocol).
# See https://niri-wm.github.io/niri/Security-Model.html#unsandboxed-clients
# for an example of what that implies.
PASS_WAYLAND="${PASS_WAYLAND:-0}"

# Export PASS_X11=1 to enable X11 (Xwayland) access.
PASS_X11="${PASS_X11:-0}"

# Wayland: bind only the socket into a fresh runtime dir.
XDG_RT="${XDG_RUNTIME_DIR:-}"
WAYLAND_SOCK="${WAYLAND_DISPLAY:-wayland-0}"
if [[ "$PASS_WAYLAND" -eq 1 && -n "$XDG_RT" && -S "$XDG_RT/$WAYLAND_SOCK" ]]; then
	BWRAP+=(--dir /run/user
		--dir /run/user/1000-sbox
		--bind "$XDG_RT/$WAYLAND_SOCK" "/run/user/1000-sbox/$WAYLAND_SOCK"
		--setenv XDG_RUNTIME_DIR /run/user/1000-sbox
		--setenv WAYLAND_DISPLAY "$WAYLAND_SOCK")
else
	BWRAP+=(--unsetenv WAYLAND_DISPLAY)
fi

# X11.
DISPLAY_VAR="${DISPLAY:-}"
if [[ "$PASS_X11" -eq 1 && -n "$DISPLAY_VAR" && -d /tmp/.X11-unix ]]; then
	BWRAP+=(--ro-bind /tmp/.X11-unix /tmp/.X11-unix
		--setenv DISPLAY "$DISPLAY_VAR")
else
	# Make it harder for accidental X11: unset DISPLAY.
	BWRAP+=(--unsetenv DISPLAY)
fi

# Export PASS_DRI=1 to enable DRI (GPU) access for hardware acceleration.
PASS_DRI="${PASS_DRI:-0}"

if [[ "$PASS_DRI" -eq 1 ]]; then
	[[ -d /dev/dri ]] && BWRAP+=(--dev-bind /dev/dri /dev/dri)

	# ROCm/HIP compute.
	[[ -c /dev/kfd ]] && BWRAP+=(--dev-bind /dev/kfd /dev/kfd)

	# CUDA compute and Unified Memory.
	for p in /dev/nvidiactl /dev/nvidia-uvm /dev/nvidia[0-9]*; do
		[[ -c "$p" ]] && BWRAP+=(--dev-bind "$p" "$p")
	done
fi

# EGL complains without this.
BWRAP+=(--ro-bind /sys /sys)

# Export ALLOW_NET=0 to disable network access inside the sandbox.
#
# Keep in mind that if your X11/Xwayland doesn't check Xauth,
# then network access lets the sandbox connect to your X11
# via an abstract Unix socket. This is quite dangerous.
ALLOW_NET="${ALLOW_NET:-1}"

# The current folder that we're binding read-write.
REPO="$(readlink -f .)"

BWRAP=(bwrap
	--die-with-parent
	# Unshare (isolate) a bunch of things inside the sandbox.
	--unshare-pid
	--unshare-uts
	--unshare-cgroup
	--unshare-user
	--cap-drop ALL
	# Create/mount important folders.
	--proc /proc
	--dev /dev
	--tmpfs /tmp
	--tmpfs /var
	--dir /run
	--dir /etc
	--hostname sandbox

	# Warning: this script shares all environment variables.
	# If on your system the environment can contain secrets,
	# you may want to clear them:
	# --clearenv

	# Sandbox cannot access the host tmux.
	--unsetenv TMUX
	--unsetenv TMUX_PANE

	# Bind the current folder read-write and chdir there.
	--bind "$REPO" "$REPO"
	--chdir "$REPO"
)

# --- Read-only system binds ---
SYS_RO_BINDS=(
	# Folders with binaries and libraries.
	/usr
	/bin
	/sbin
	/lib
	/lib64
	# Random configuration files that programs tend to need.
	/etc/alternatives
	/etc/nsswitch.conf
	/etc/hosts
	/etc/localtime
	/etc/timezone
	/etc/pki
	/etc/ca-certificates
	/etc/ssl
	/etc/crypto-policies
	/etc/fonts
	# I fill these as I bump into problems, more or less.
	/etc/java
	/etc/texlive
	/etc/apt
	/var/lib/texmf
	/var/lib/command-not-found
	/usr/lib/jvm
	/usr/share/java
)
# Bind all of them read-only.
for p in "${SYS_RO_BINDS[@]}"; do
	[[ -e "$p" ]] && BWRAP+=(--ro-bind "$p" "$p")
done

BWRAP+=(--ro-bind-try /etc/ld.so.cache /etc/ld.so.cache)

# resolv.conf is fun because it's a symlink into /run,
# a folder which we do not want to expose.
RESOLV_REAL="$(readlink -f /etc/resolv.conf 2>/dev/null || true)"
if [[ -n "$RESOLV_REAL" && -f "$RESOLV_REAL" ]]; then
	BWRAP+=(--ro-bind "$RESOLV_REAL" /etc/resolv.conf)
fi

# Unshare the network if needed.
if [[ "$ALLOW_NET" -eq 0 ]]; then
	BWRAP+=(--unshare-net)
fi

# Create a fresh home directory.
# The username and the path is the same as on the host
# so that everything keeps working.
BWRAP+=(--setenv HOME "$HOME"
	--dir "$HOME")

# --- Home read-only binds ---
HOME_RO_BINDS=(
	.cargo/bin
	.cargo/config.toml
	.local/bin
	.local/lib/node_modules
	.rustup
	.fonts
	.local/share/fonts
	.local/share/nvim/site/parser
	.gitconfig
	.config/git
	.config/tmux
	.cache/ms-playwright
	.cache/corepack
)
for rel in "${HOME_RO_BINDS[@]}"; do
	[[ -e "$HOME/$rel" ]] && BWRAP+=(--ro-bind "$HOME/$rel" "$HOME/$rel")
done

# --- Home overlays ---
# The sandbox can write here, but the changes
# will not affect the host filesystem.
HOME_TMP_OVERLAYS=(
	.cache/fontconfig
	.cache/uv
	.cargo/registry
	.cargo/git
	.gradle
	.npm
	.cache/npm
	.local/share/pnpm/store
	.cache/yarn
	.cache/cpm
	.texlive2023
)
for rel in "${HOME_TMP_OVERLAYS[@]}"; do
	[[ -d "$HOME/$rel" ]] && BWRAP+=(--overlay-src "$HOME/$rel" --tmp-overlay "$HOME/$rel")
done

# Set up $PATH with the paths that we have inside this sandbox.
BWRAP+=(--setenv PATH "$HOME/.cargo/bin:$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin")

# Execute our big commandline and pass it
# the rest of the arguments (the command to run).
CMD=("${@:-bash}")
exec "${BWRAP[@]}" "${CMD[@]}"
