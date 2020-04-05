export PATH='/usr/local/bin/:/usr/bin'

echo $(security find-generic-password -a $(id -un) -c 'kaiw' -C 'kaiw' -s "KPass_AlfredWorkflow" -w $keychain) |\
       keepassxc-cli show -q -a Password "$database" "$1";