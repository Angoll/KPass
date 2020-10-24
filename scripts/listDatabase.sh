export PATH='/usr/local/bin/:/usr/bin'


useKeePassKeyFile=""
if [[ ! -z ${keePassKeyFile} ]]; then
    useKeePassKeyFile="--key-file \"${keePassKeyFile}\""
fi


function get_keys() {
    security find-generic-password -a $(id -un) -c 'kpas' -C 'kpas' -s "${keychainItem}" -w "${keychain}" |\
           keepassxc-cli ls -R -q  ${useKeePassKeyFile} -f "$database" | grep -Ev '(/|\[empty\]?)$'
}

function get_errorInfo {
    exec 3<&1
    security find-generic-password -a $(id -un) -c 'kpas' -C 'kpas' -s "${keychainItem}" -w "${keychain}" 2>&3 |\
           keepassxc-cli ls -R ${useKeePassKeyFile} -f "$database" 2>&3 | grep -Ev '(/|\[empty\]?)$'
    exec 3>&-
}

function build_entry() {
    local entry=$1
    #local title=${entry##*/}
    local title=${entry}
    jq -n --arg entry ${entry} --arg title ${title} --arg iconPath "${PWD}/icon.png" '{"uid": $entry, "title": $title, "subtitle": $entry , "arg": $entry, "autocomplete": $entry, "icon": {"type":"png", "path": $iconPath}}'
}

if [[ -z ${database} ]] || [[ -z ${keychain} ]];
then
    echo "{\"items\": [{\"title\":\"Not configured, please run: kpassinit\"}]}";
    exit
fi

keys=($(get_keys))
if [ $? -ne 0 ]; then
    info=$(get_errorInfo | sed 's/"/\\"/g')
    info=${info//$'\n'/}
    echo "{\"items\": [{\"title\":\"Error listing database, please check config: Error: ${info}\"}]}";
    exit
fi

OIFS=$IFS
IFS=$'\n'
keys=($(get_keys))
for entry in ${keys[@]}; do
    build_entry ${entry}
done | jq -c -s '{"items": .}'
IFS=$OIFS
