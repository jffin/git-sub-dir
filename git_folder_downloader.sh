#!/bin/sh

# usage
# ./git_folder_downloader.sh [[ https://api.github.com/repos/:owner/:repo/contents/:path ]] [[ destination folder ]] [[ directory to remove while following path ]]

null_url="null"
directory="$2"
follow_structure="$3"

download_file() {
        printf ${3}${4}${1}"\n"
        mkdir -p ${3}${4}
        curl -s -o ${3}${4}${1} ${2}
}

loop_json() {
        for row in $(echo ${1} | jq -r '.[] | @base64'); do
                _jq() {
                        echo ${row} | base64 -d | jq -r ${1}
                }

                url=$(_jq '.url')
                file_name=$(_jq '.name')
                path="/"
                download_url=$(_jq '.download_url')
                
                if [[ ! -z ${follow_structure} ]]; then
                        path=$(_jq '.path')
                        path=${path//${follow_structure}/}
                        path=${path//${file_name}/}
                fi

                if [ ${download_url} = ${null_url} ]; then
                        printf ${url}
                        folder_json=$(curl -s -L ${url})
                        loop_json "${folder_json}"
                else
                        download_file ${file_name} ${download_url} ${directory} ${path}
                fi
        done
}

json=$(curl -s -L ${1})

loop_json "${json}"
