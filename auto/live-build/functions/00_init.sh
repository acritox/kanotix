unset LIVE_BUILD
export LIVE_BUILD
for _FILE in /usr/share/live/build/functions/*.sh auto/functions/*
do
    if [ -e "${_FILE}" ]
    then
        . "${_FILE}"
    fi
done
