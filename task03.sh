#!/usr/bin/env bash

random_port () {
    # 48655-48999
    port=$((48655 + RANDOM % 344))
    while ss -tulpn | grep LISTEN | awk '{print $4}' | grep -q "$port"; do
        port=$((48655 + RANDOM % 344))
    done
    echo "$port"
}

change_config () {

    path=/etc/ssh
    path_to_file=$path/sshd_config

    [[ -f $path_to_file ]] || {
        mkdir -p $path
        touch $path_to_file
    }

    if grep -q "^$1" $path_to_file; then

        sed -i "s/^$1.*/$*/g" $path_to_file

    elif grep -q "^#$1" $path_to_file; then

        sed -i "s/^#$1.*/$*/g" $path_to_file
    else
        echo "$*" >> $path_to_file
    fi
}

# Import your publik key to the server. You can also use
# `ssh-copy-id userName@hostName` from the client host.
if command -v ssh-import-id &> /dev/null; then
    ssh-import-id gh:name-snrl
    echo -e "\nYour public key was imported"
else
    echo -e "\nYou must add your public keys"
fi

# Set a random port.
new_port="$(random_port)"
echo -e "-----\nYour new port is $new_port"
change_config Port "$new_port"

# Deny root login.
change_config PermitRootLogin no

# Disallow password access.
change_config PasswordAuthentication no

# Restart daemon.
systemctl restart sshd.service
