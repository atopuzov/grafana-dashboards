#!/bin/sh
set -e

USERNAME=gosu

if [[ ! -z "${GROUP_ID+x}" && "${GROUP_ID}" -gt 0 ]]
then
    addgroup -g "${GROUP_ID}" -S "${USERNAME}"
fi

if [[ ! -z "${USER_ID+x}" && "${USER_ID}" -gt 0  ]]
then

    adduser -S -G ${USERNAME} -u ${USER_ID} -s /bin/sh ${USERNAME}
fi

if [[ ! -z "${GROUP_ID+x}" ]]
then
   /usr/bin/gosu ${USERNAME} "$@"
else
    "$@"
fi
