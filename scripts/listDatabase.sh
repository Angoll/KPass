export PATH=/usr/local/bin/:/usr/bin:/Applications/KeePassXC.app/Contents/MacOS/:/opt/homebrew/bin/:$PATH


useKeePassKeyFile=""
if [[ ! -z ${keePassKeyFile} ]]; then
    useKeePassKeyFile="--key-file ${keePassKeyFile}"
fi

cacheDir=$(dirname ${keychain})
cacheFile="$cacheDir/kpass_db.cache"
if [ ! -f "$cacheFile" ];then
	lastModifiedTime=0
else
	lastModifiedTime=$(/opt/homebrew/opt/coreutils/libexec/gnubin/stat -c %Y $cacheFile)
fi
currTime=$(date +%s)
interval=$(expr $currTime - $lastModifiedTime)

function get_keys() {

    #security find-generic-password -a $(id -un) -c 'kpas' -C 'kpas' -s "${keychainItem}" -w "${keychain}" |keepassxc-cli locate -q ${useKeePassKeyFile} "$database" "{query}" 
    security find-generic-password -a $(id -un) -c 'kpas' -C 'kpas' -s "${keychainItem}" -w "${keychain}" |keepassxc-cli locate ${useKeePassKeyFile} "$database" / -q 
} 

function get_errorInfo {
    exec 3<&1
    security find-generic-password -a $(id -un) -c 'kpas' -C 'kpas' -s "${keychainItem}" -w "${keychain}" 2>&3 |\
           keepassxc-cli locate ${useKeePassKeyFile} "$database" / -q 2>&3
    exec 3>&-
}

if [[ -z ${database} ]] || [[ -z ${keychain} ]];
then
    echo "{\"items\": [{\"title\":\"Not configured, please run: kpassinit\"}]}";
    exit
fi

if [ ! -f "$cacheFile" ] || [ $interval -gt 60 ];then
	# update cache file
	echo "$(get_keys)" > "$cacheFile"
fi
# get keys from cache 
keys=($(cat $cacheFile | grep -i "{query}" ))
if [ $? -ne 0 ]; then
    info=$(get_errorInfo | sed 's/"/\\"/g')
    info=${info//$'\n'/}
    echo "{\"items\": [{\"title\":\"Error listing database, please check config: Error: ${info}\"}]}";
    exit
else
    echo ${keys[@]} | sed 's/ \//\n\//g' | awk -v iconPath="${PWD}/icon.png" '{printf "{\"uid\":\"%s\", \"title\":\"%s\", \"subtitle\":\"%s\", \"arg\":\"%s\", \"autocomplete\": \"%s\", \"icon\":{\"type\":\"png\", \"path\": \"%s\"}}", $0, $0, $0, $0, $0, iconPath}' | jq -c -s '{"items": .}'
fi
