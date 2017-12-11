if [ ! -z "$@" ]
then
	QUERY=$@
	coproc (xdg-open https://duckduckgo.com/?q="$QUERY")
	exit
fi
