#!/bin/bash
# origal author   : chinatree <chinatree2012@gmail.com>
# NOTE:the original verion was to post things to qzone,I adapt it to post for pengyou.com

# [global]
SCRIPT_PATH=$(cd "$(dirname "$0")"; pwd)
SCRIPT_NAME=$(basename "$0")
COMMON_FILE=""${SCRIPT_PATH}"/common.sh"
AUTO_LOGIN=""${SCRIPT_PATH}"/auto_login.sh"
PARA_NUM="$#"
USER_AGENT="Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 5.1; Trident/4.0; QQDownload 734; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729; .NET CLR 1.1.4322)"
POST_TIME=$(date +%s)
POST_RANDOM="${POST_TIME}${RANDOM:0:3}"

if [ ! -f "${COMMON_FILE}" ];
then
    echo "The common function file "${COMMON_FILE}" not exists, please check it and try again!"
    exit 1
else
    . "${COMMON_FILE}"
fi

function usage () {
    echo -e "`get_color "Usage:" GOLDYELLOW` \
    \n    ./"${SCRIPT_NAME}" <QQ> <PASS> <CONTENT>"
    exit 2
}
if [ "${PARA_NUM}" -lt "3" ]; then
    usage
fi

#encode the content
function encodeurl()
{
        encoded_str=`echo "$*" | awk 'BEGIN {
        split ("1 2 3 4 5 6 7 8 9 A B C D E F", hextab, " ")
        hextab [0] = 0
        for (i=1; i<=255; ++i) { 
            ord [ sprintf ("%c", i) "" ] = i + 0
        }
    }
    {
        encoded = ""
        for (i=1; i<=length($0); ++i) {
            c = substr ($0, i, 1)
            if ( c ~ /[a-zA-Z0-9.-]/ ) {
                encoded = encoded c             # safe character
            } else if ( c == " " ) {
                encoded = encoded "+"   # special handling
            } else {
                # unsafe character, encode it as a two-digit hex-number
                lo = ord [c] % 16
                hi = int (ord [c] / 16);
                encoded = encoded "%" hextab [hi] hextab [lo]
            }
        }
        print encoded
    }' 2>/dev/null`
}

#get the UIN_U parameter for post
function getUIN () {
    POST_URL='http://home.pengyou.com/index.php?mod=home'
    UIN_u=`/usr/bin/curl -b "${COOKIE_FILE}" "${POST_URL}" | awk -F ':' '/"hash"/{print $2}'| awk -F '"' '/c/{print $2}'`
}

#post text
function post () {
    encodeurl ${STR}
    echo ${encoded_str}
    POST_DATA="plattype=2&format=json&con="${encoded_str}"&feedversion=1&ver=1&hostuin="${UIN_u}"&entryuin="${UIN_u}"&noFormSender=1&plat=pengyou"
    POST_URL="http://taotao.pengyou.com/cgi-bin/emotion_cgi_publish_v6?g_tk=${GTK}"
    /usr/bin/curl -v -A "${USER_AGENT}" -b "${COOKIE_FILE}" -c "${COOKIE_FILE}" -d "${POST_DATA}" "${POST_URL}"
}

QQ="$1"
PASS="$2"
CONTENT="$3"
if [ ! -f "${AUTO_LOGIN}" ];
then
    echo "The common function file "${AUTO_LOGIN}" not exists, please check it and try again!"
    exit 1
else
    . "${AUTO_LOGIN}" "$1" "$2" 
    #echo "hello"
fi

COOKIE_FILE="${SCRIPT_PATH}/cookie/${QQ}.cookie.txt"
SKEY=$(cat "${COOKIE_FILE}" | grep skey | awk '{print $NF}')
GTK=$(node ${SCRIPT_PATH}/encode_g_tk.js "${SKEY}")
n=0
for i in $@;do
	((++n))
        [[ n -gt 2 ]] && STR=${STR}" "$i;
done
getUIN
post
exit
