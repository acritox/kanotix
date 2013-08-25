unset LIVE_BUILD
export LIVE_BUILD
for _FILE in /usr/share/live/build/functions/*.sh auto/functions/*
do
    if [ -e "${_FILE}" ]
    then
        . "${_FILE}"
    fi
done
Set_defaults() {
    # hide this script from the real Set_defaults
    # to make sure that no path is set to this local folder
    mv local local.tmp
    . /usr/share/live/build/functions/defaults.sh
    Set_defaults "@"
    mv local.tmp local
}
