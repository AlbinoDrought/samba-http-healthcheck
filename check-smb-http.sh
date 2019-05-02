#!/bin/sh

if [ -z "$2" ]; then
    echo "usage:   [host] [share] [protocol?=smb2] [port?=8080]"
    echo "example: localhost bar"
    exit 1
fi

HOST=$1
SHARE=$2
PROTOCOL=${3:-smb2}
PORT=${4:-8080}

ROOT=//$HOST/$SHARE

echo "Booting $PROTOCOL healthcheck for $ROOT at :$PORT"

Check () {
    echo "this is an smb healthcheck file" > test.foo

    # make remote dir
    echo "Making remote dir"
    smbclient -N $ROOT -m $PROTOCOL -c "mkdir .smb-healthcheck" || return 1

    # upload file
    echo "Uploading"
    smbclient -N $ROOT -m $PROTOCOL --directory .smb-healthcheck -c "put test.foo" || return 2

    # download file
    echo "Downloading"
    smbclient -N $ROOT -m $PROTOCOL --directory .smb-healthcheck -c "get test.foo test.pulled" || return 3

    echo "Comparing"
    if ! cmp -s test.foo test.pulled; then
        echo "downloaded file does not match"
        return 4
    fi

    rm test.pulled

    # delete uploaded file
    echo "Deleting uploaded file"
    smbclient -N $ROOT -m $PROTOCOL --directory .smb-healthcheck -c "rm test.foo" || return 5

    # delete created directory
    echo "Deleting created directory"
    smbclient -N $ROOT -m $PROTOCOL -c "rmdir .smb-healthcheck" || return 6

    # ensure directory is deleted
    echo "Checking if directory deleted"
    (smbclient -N $ROOT -m $PROTOCOL -c "cd .smb-healthcheck" && return 7) || return 0

    echo "everything ok"
}

GOOD_RESPONSE="HTTP/1.1 200 OK\r\nConnection: keep-alive\r\n\r\nOK\r\n"
BAD_RESPONSE="HTTP/1.1 500 OK\r\nConnection: keep-alive\r\n\r\nNOT OK\r\n"

while true
do
    Check
    if [ $? -eq 0 ]; then
        RESPONSE="$GOOD_RESPONSE"
    else
        RESPONSE="$BAD_RESPONSE"
    fi

    echo "Healthcheck ready"
    echo -en "$RESPONSE" | nc -lp "$PORT"
    echo "Healthcheck sent"
done
