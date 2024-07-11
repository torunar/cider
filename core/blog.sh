#
# load compiler
#
source "${CIDER_cellar}/core/compiler.sh"
source "${CIDER_cellar}/core/sitemap.sh"
source "${CIDER_cellar}/core/rss.sh"

function getPostTitle() {
    head -n 1 "${1}" | sed -n -E -e 's/^<h1>(.*)<\/h1>$/\1/gp'
}

# search for a block between two <hr>'s
function getPostPreview() {
    local postFilePath="${1}"
    local postLink="${2}"

    sed -n -e $'/<hr>/{
        n
        :loop
        p
        n
        /<hr>/{
            q
        }
        b loop
    }' "${postFilePath}" \
        | sed -E -e "s~(src=|href=)\"\./~\1\"${postLink}~g" \
        | sed -E -e "s~(src=|href=)\"/~\1\"${CIDER_homepage}/~g"

}

# search for a line where description ends
function getPostPreviewPosition() {
    local postFilePath="${1}"

    sed -n -e $'/<hr>/{
        :loop
        n
        /<hr>/{
            =
            q
        }
        b loop
    }' "${postFilePath}"
}

function getPostContent() {
    local previewPosition=$(getPostPreviewPosition "${1}")
    local postLink="${2}"

    if [ "${previewPosition}" != "" ]; then
        local skipPosition=$previewPosition
    else
        local skipPosition=2
    fi

    sed -e "1,${skipPosition}d" "${1}" \
        | sed -E -e "s~(src=|href=)\"\./~\1\"${postLink}~g" \
        | sed -E -e "s~(src=|href=)\"/~\1\"${CIDER_homepage}/~g"

}

function getPostDir() {
    echo "${1}" | sed -e 's~/index.md~~g'
}

function renderPaginationLink() {
    local indexPagePath="${1}"
    local pageType="${2}"
    local pageNumber="${3}"
    local pageLinkText="${4}"
    local outputDir="${5}"

    if [ $pageNumber == 1 ]; then
        local pageLinkUrl="${CIDER_homepage}/"
    else
        local pageLinkUrl="${CIDER_homepage}/${pageNumber}/"
    fi

    renderTemplate "${CIDER_themeDir}" "common/page_link.ct" "${outputDir}/page_link.html"
    renderVariable "${outputDir}/page_link.html" "pageLinkUrl" "${pageLinkUrl}"
    renderVariable "${outputDir}/page_link.html" "pageLinkText" "${pageLinkText}"
    renderVariable "${indexPagePath}" "${pageType}" "$(cat "${outputDir}/page_link.html")"

    rm -f "${outputDir}/page_link.html"
}

function getPostDate() {
    echo -n "${1}" | sed -E -e 's~(.*)([0-9]{4}/[0-9]{2}/[0-9]{2})/(.*)~\2~g'
}

function getPostsList() {
    local inputDir="${1}"
    echo $(find "${inputDir}" -type f -name "index.md" \
        | sed -E -e 's~(.*)([0-9]{4}/[0-9]{2}/[0-9]{2}/[^/]+)/index.md~\2~g' \
        | sort -r \
    )
}

function renderPostComments() {
    local compiledPostPath="${1}"
    local postLink="${2}"
    local postId="${3}"
    local outputDir="${4}"

    renderTemplate "${CIDER_themeDir}" "posts/comments.ct" "${outputDir}/comments.html"
    renderVariable "${outputDir}/comments.html" "postId" "${postLink}"
    renderVariable "${outputDir}/comments.html" "postLink" "${postLink}"
    renderVariable "${compiledPostPath}" "postComments" "$(cat "${outputDir}/comments.html")"

    rm -f "${outputDir}/comments.html"
}

function renderPost() {
    local postPath="${1}"
    local pageNumber="${2}"
    local postId=$(printf "%03d" "${3}")-$RANDOM

    local inputPath="${CIDER_inputDir}/${postPath}/index.md"
    local outputDir="${CIDER_outputDir}/${postPath}"

    mkdir -p "${outputDir}"
    cp -r "${CIDER_inputDir}/${postPath}/"* "${outputDir}"

    local tmpPostPath="${outputDir}/.index.html"
    local compiledPostPath="${outputDir}/index.html"
    local listItemPath="${CIDER_outputDir}/post_${postId}.html"
    local postLink="/${postPath}/"
    local canonicalLink="${CIDER_homepage}${postLink}"

    markdown -html4tags "${inputPath}" > "${tmpPostPath}"

    local postDate=$(getPostDate "${postPath}")
    local postTitle=$(getPostTitle "${tmpPostPath}")
    local postPreview=$(getPostPreview "${tmpPostPath}" "${postLink}")
    local postContent=$(getPostContent "${tmpPostPath}" "${postLink}")
    local mainTitle=$(stripTags "${postTitle}")

    echo "${canonicalLink}: ${mainTitle}"

    renderTemplate "${CIDER_themeDir}" "posts/single.ct" "${compiledPostPath}"
    if [ ! -e "${CIDER_inputDir}/${postPath}/.hidden" ]; then
        renderTemplate "${CIDER_themeDir}" "posts/list_item.ct" "${listItemPath}"
    fi

    if [ -z "${CIDER_disqusId}" ]; then
        renderVariable "${compiledPostPath}" "postComments" ""
    else
        renderPostComments "${compiledPostPath}" "${CIDER_homepage}${postLink}" "${postLink}" "${outputDir}"
    fi

    local tr=( "${CIDER_localization[@]}" postLink postDate postTitle postPreview postContent mainTitle canonicalLink )
    for varName in "${tr[@]}"; do
        renderVariable "${compiledPostPath}" "${varName}" "${!varName}"
        if [ ! -e "${CIDER_inputDir}/${postPath}/.hidden" ]; then
            renderVariable "${listItemPath}" "${varName}" "${!varName}"
        fi
    done

    rm -f "${tmpPostPath}"

    # add post to sitemap and RSS feed
    writeSitemapEntry "${CIDER_outputDir}" "${canonicalLink}"
    if [ $pageNumber == 1 ]; then
        writeRssEntry "${CIDER_outputDir}" "${postTitle}" "${canonicalLink}" "${postPreview}${postContent}" "${postDate}"
    fi
}

function renderIndexPage() {
    local pageNumber="${1}"

    if [ $pageNumber == 1 ]; then
        indexPagePath="${CIDER_outputDir}/index.html"
        mainTitle="${CIDER_mainTitle}"
        canonicalLink="${CIDER_homepage}/"
    else
        indexPagePath="${CIDER_outputDir}/${pageNumber}/index.html"
        mainTitle="${CIDER_mainTitlePaged}"
        canonicalLink="${CIDER_homepage}/${pageNumber}/"
    fi

    mkdir -p $(dirname "${indexPagePath}")
    renderTemplate "${CIDER_themeDir}" "index.ct" "${indexPagePath}"

    if [ $pageNumber -gt 1 ]; then
        renderPaginationLink "${indexPagePath}" "pageLinkPrev" "$(( $pageNumber - 1))" "${CIDER_pageLinkPrevText}" "${CIDER_outputDir}"
    else
        renderVariable "${indexPagePath}" "pageLinkPrev" ""
    fi

    renderPaginationLink "${indexPagePath}" "pageLinkCurr" "${pageNumber}" "${CIDER_pageLinkCurrText}" "${CIDER_outputDir}"

    if [ "${postPath}" != "${lastPostPath}" ]; then
        renderPaginationLink "${indexPagePath}" "pageLinkNext" "$(( pageNumber + 1 ))" "${CIDER_pageLinkNextText}" "${CIDER_outputDir}"
    else
        renderVariable "${indexPagePath}" "pageLinkNext" ""
    fi

    postsList=$(cat "${CIDER_outputDir}/post_"*.html)

    tr=( "${CIDER_localization[@]}" mainTitle postsList pageNumber canonicalLink )
    for varName in "${tr[@]}"; do
        renderVariable "${indexPagePath}" "${varName}" "${!varName}"
    done

    rm -f "${CIDER_outputDir}/post_"*.html
    rm -f "${CIDER_outputDir}/page_link.html"
}
