# bootdir depends on raspianos version
BOOTDIR=$(/usr/lib/raspberrypi-sys-mods/get_fw_loc)

function SETKEY() {
    local kvkey=$1
    local kvassign='='
    local kvvalue=''
    local kvfilename=''

    case "$#" in
      "3")
        kvalue=$2
        kvfilename=$3
        ;;

      "4")
        kvassign=$2
        kvalue=$3
        kvfilename=$4
        ;;

      *)
        echo -e "\033[0;31m### Error: RUN SETKEY FILENAME KEY [ASSIGNCHAR:=] VALUE\033[0m"
        return 1
        ;;
    esac

    if [[ -z $(grep -R "^[#[:space:]]*${kvkey}${kvassign}.*" ${kvfilename}) ]]; then
        echo ${kvkey}${kvassign}${kvalue//\//\\/} >> ${kvfilename}
    else
        sed -ri "s/^[#[:space:]]*${kvkey}${kvassign}.*/${kvkey}${kvassign}${kvalue//\//\\/}/" ${kvfilename}
    fi
}

function RMLINE() {
    linematch=$1
    filename=$2
    sed -ir "/${linematch}/d" '${filename}'
}

function UNCOMMENT() {
    linematch=$1
    filename=$2
    sed -i "/${linematch}/s/^[#[:space:]]*#//g" ${filename}
}

function COMMENT() {
    linematch=$1
    filename=$2
    sed -i "/${linematch}/s/^/#/" ${filename}
}
