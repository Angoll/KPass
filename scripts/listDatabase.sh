export PATH='/bin:/usr/local/bin/:/usr/bin:/Applications/KeePassXC.app/Contents/MacOS/:/opt/homebrew/bin:${PATH}'

function get_db_keys {
    if [ ! -z "${keePassKeyFile}" ]; then
        security find-generic-password -a $(id -un) -c 'kpas' -C 'kpas' -s "${keychainItem}" -w "${keychain}" |\
            keepassxc-cli locate --key-file "${keePassKeyFile}" "${database}" / -q
    else
        security find-generic-password -a $(id -un) -c 'kpas' -C 'kpas' -s "${keychainItem}" -w "${keychain}" |\
            keepassxc-cli locate "${database}" / -q
    fi
}

function get_keys {
    if [ -z "${cacheFile}" ]; then
        get_db_keys
    else
        # Cache is enabled
        if [ -f "${cacheFile}" ]; then
            lastModifiedTime=$(GetFileInfo -d "${cacheFile}")
        else
            lastModifiedTime=$(date +"%m/%d/%Y %H:%M:%S")
        fi
        lastModifiedTime=$(date -jf "%m/%d/%Y %H:%M:%S" "${lastModifiedTime}" +%s)
        currTime=$(date +%s)
        interval=$( expr $currTime - $lastModifiedTime )
        if [ ! -f "${cacheFile}" ] || [ "${interval}" -gt "${cacheTimeout}" ]; then
            # Update cache
            echo "$(get_db_keys)" > "${cacheFile}"
        fi
        # Get keys from the cache
        cat "${cacheFile}" | grep -i "${query}"
    fi
}

function get_errorInfo {
    exec 3<&1
    security find-generic-password -a $(id -un) -c 'kpas' -C 'kpas' -s "${keychainItem}" -w "${keychain}" 2>&3 |\
        keepassxc-cli locate ${useKeePassKeyFile} '$database' / -q 2>&3
    exec 3>&-
}

if [[ -z "${database}" ]] || [[ -z "${keychain}" ]];
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
else
    echo ${keys[@]} | sed 's/ \//\n\//g' | awk -v iconPath="${PWD}/icon.png" '{printf "{\"uid\":\"%s\", \"title\":\"%s\", \"subtitle\":\"%s\", \"arg\":\"%s\", \"autocomplete\": \"%s\", \"icon\":{\"type\":\"png\", \"path\": \"%s\"}}", $0, substr($0,2, length($0)), $0, $0, $0, iconPath}' | jq -c -s '{"items": .}'
fi
