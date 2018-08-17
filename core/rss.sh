#
# load compiler
#
source "${CIDER_cellar}/core/compiler.sh"

function formatDateRfc822() {
    if [ -z "${1}" ]; then
        if [ $(uname | grep Darwin) ]; then
            date +"%a, %d %b %Y %T %z"
        else
            date -R
        fi
    else
        if [ $(uname | grep Darwin) ]; then
            date -j -f "%Y/%m/%d %T" "${1} 00:00:00" +"%a, %d %b %Y %T %z"
        else
            date -R -d "${1}"
        fi
    fi
}

function writeRssHeader() {
    local title=$(stripTags "${2}")
    local link="${3}"
    local description=$(stripTags "${4}")
    local language="${5}"
    local lastBuildDate=$(formatDateRfc822)

    cat > "${1}/rss.xml" <<XML
<?xml version="1.0"?>
<rss version="2.0">
    <channel>
        <title>${title}</title>
        <link>${link}</link>
        <description>${description}</description>
        <language>${language}</language>
        <lastBuildDate>${lastBuildDate}</lastBuildDate>
        <generator>Cider</generator>
XML
}

function writeRssEntry() {
    local title=$(stripTags "${2}")
    local link="${3}"
    local description=$(echo -n "${4}" | sed -e "s~<img src=\"\.~<img src=\"${link}~g" | sed -e "s~<a href=\"\.~<a href=\"${link}~g")
    local pubDate=$(formatDateRfc822 "${5}")

    cat >> "${1}/rss.xml" <<XML
        <item>
            <title>${title}</title>
            <link>${link}</link>
            <guid>${link}</guid>
            <description><![CDATA[${description}]]></description>
            <pubDate>${pubDate}</pubDate>
        </item>
XML
}

function writeRssFooter() {
    cat >> "${1}/rss.xml" <<XML
    </channel>
</rss>
XML
}
