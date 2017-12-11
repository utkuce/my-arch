if [ ! -z "$@" ]
then
	coproc (xdg-open https://duckduckgo.com/?q="$@")
fi
