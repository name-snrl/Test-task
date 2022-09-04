#!/usr/bin/env bash

interval=3
url=localhost:80

sender=zxc123zxc.pupkin@mail.ru
password=$(< mail_pass)
recipient=demogorgon-74@ya.ru

status=alive

while true; do

    if [[ $status == alive ]]; then
        if curl -Is "$url" > /dev/null; then
            status=alive
            echo ALIVE
            sleep "$interval"
        else
            status=dead
            echo DIED
            curl smtps://smtp.mail.ru:465 \
                --ssl-reqd --silent \
                --user "$sender:$password" \
                --mail-from "$sender" \
                --mail-rcpt "$recipient" \
                --upload-file <(echo Server died!)
        fi
    fi

    while [[ $status == dead ]]; do
        sleep 3
        if curl -Is "$url" > /dev/null; then
            status=alive
        else
            echo STILL DEAD
        fi
    done
done
