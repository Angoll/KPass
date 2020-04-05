query="{query}"

export PATH='/usr/local/bin/:/usr/bin'

if [[ -z ${database} ]] || [[ -z ${keychain} ]];
then
    
    echo "{\"items\": [{\"title\":\"Not configured, please run: kpassinit\"}]}";

else
    
    keys=$(security find-generic-password -a $(id -un) -c 'kpas' -C 'kpas' -s "AlfredWorkflow" -w "${keychain}" |\
           keepassxc-cli ls -R -q -f "$database" | grep -Ev '(/|\[empty\]?)$')

    if [ $? -eq 0 ]; then 
        echo -n '{"items": ['
        first=
        for entry in ${keys[@]}; do
            if [ $first ] ; then echo -n ","; fi
            echo -n "{\"uid\":\"${entry}\",\"title\":\"${entry}\",\"arg\":\"${entry}\",\"autocomplete\":\"${entry}\",\"icon\":{\"type\":\"png\",\"path\":\"${PWD}/icon.png\"}}";
            first=false
        done
        echo ']}'

    else
        echo -n "{\"items\": [{\"title\":\"Error listing database, please check config\"}]}"
    fi

fi
