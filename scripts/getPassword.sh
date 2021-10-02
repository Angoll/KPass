export PATH='/usr/local/bin/:/usr/bin:/Applications/KeePassXC.app/Contents/MacOS/:${PATH}'

keePassKeyFile=""
if [[ ! -z ${keyfile} ]]; then
    keePassKeyFile="--key-file \"${keyfile}\""
fi

function get_keys() {
    security find-generic-password -a $(id -un) -c 'kpas' -C 'kpas' -s "${keychainItem}" -w "${keychain}" |\
           keepassxc-cli show -q ${keePassKeyFile} -a Password "$database" "$1"
}

function get_errorInfo {
    exec 3<&1
    security find-generic-password -a $(id -un) -c 'kpas' -C 'kpas' -s "${keychainItem}" -w "${keychain}" 2>&3 |\
           keepassxc-cli ls -R ${keePassKeyFile} -f "$database" 2>&3 | grep -Ev '(/|\[empty\]?)$'
    exec 3>&-
}


data=$(get_keys "$1")
if [ $? -ne 0 ]; then
	echo $(get_errorInfo)
else
	echo $data
fi
