null_url="null"
download_directory="$2"

download_file() {
        curl -o ${3}/${1} ${2}
}

loop_json() {
        for row in $(echo ${1} | jq -r '.[] | @base64'); do
                _jq() {
                        echo ${row} | base64 -d | jq -r ${1}
                }

                url=$(_jq '.url')
                file_name=$(_jq '.name')
                download_url=$(_jq '.download_url')

                if [ ${download_url} = ${null_url} ]; then
                        folder_json=$(curl -L ${url})
                        loop_json ${forlder_json}
                else
                        download_file ${file_name} ${download_url} ${download_directory}
                fi
        done
}

json=$(curl -L ${1})

loop_json "${json}"
