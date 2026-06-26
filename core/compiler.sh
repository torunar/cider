function renderTemplate() {
    local templatesDir="${1}"
    local templatePath="${2}"
    local outputPath="${3}"
    local isNested="${4}"

    if [ -z "${isNested}" ]; then
        rm -f "${outputPath}"
    fi

    local currentDir=$(pwd)
    cd "${templatesDir}"

    local currentIFS=$IFS
    IFS=''

    while read -r line || [ -n "${line}" ]; do
        local templateToRender=$(printf "%s" "${line}" | sed -E -n 's/^[ \t]*<!--\{file:(.+)\}-->/\1/p')
        if [ -n "${templateToRender}" ]; then
            if [ -f "${templateToRender}" ]; then
                renderTemplate "${templatesDir}" "${templateToRender}" "${outputPath}" 1
            fi
        else
            echo "${line}" >> "${outputPath}"
        fi
    done < "${templatePath}"

    cd "${currentDir}"

    IFS=$currentIFS
}

function renderVariable() {
    local templatePath="${1}"
    local varName="${2}"
    # escape /, \, &, replace newline with non-printing character, trim newlines
    local varValue=$(printf "%s" "${3}" | sed -e 's~\\~\\\\~g; s~/~\\/~g; s~\&~\\\&~g' | tr '\n' '\r')
    local renderedTemplate=$(sed -e "s/<!--{var:${varName}}-->/${varValue}/g" "${templatePath}" | tr '\r' '\n')
    echo -n "${renderedTemplate}" > "${templatePath}"
}

function stripTags() {
    printf "%s" "${1}" | sed -e 's/<[^>]\+>//g'
}
