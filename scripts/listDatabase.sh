query="{query}"

export PATH='/usr/local/bin/:/usr/bin'

if [[ -z ${database} ]] || [[ -z ${keychain} ]];
then

    echo "{\"items\": [{\"title\":\"Not configured, please run: kpassinit\"}]}";
fi

function get_keys(){
    local keys
    keys=$(security find-generic-password -a $(id -un) -c 'kpas' -C 'kpas' -s "AlfredWorkflow" -w "${keychain}" |\
                 keepassxc-cli locate -q "$database" "{query}" | grep -Ev '(/|\[empty\]?)$')
    echo "${keys}"
}

keys=$(get_keys)
if [ $? -ne 0 ]; then
    echo -n "{\"items\": [{\"title\":\"Error listing database, please check config\"}]}";
    exit
fi

echo "${keys}" | while read entry
do
    jq -n --arg uid "${entry}" --arg title "${entry##*/}" --arg subtitle "${entry}" '{"uid": $uid, "title": $title, "subtitle": $subtitle }'
done | jq -c -s '{"items": .}'
