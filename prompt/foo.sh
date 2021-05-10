_foo ()
{
	test "x${1}" = x && return 1

	if [ -d "${1}/.repo" ]
	then
	cat "${1}"/.repo/manifest.xml |grep revision=|cut -d\" -f2|head -n1
	else
		_foo "${1%/*}"
	fi
}

