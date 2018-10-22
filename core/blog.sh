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
    sed -n -e $'/<hr>/{
        n
        :loop
        p
        n
        /<hr>/{
            q
        }
        b loop
    }' "${1}"
}

# search for a line where description ends
function getPostPreviewPosition() {
    sed -n -e $'/<hr>/{
        :loop
        n
        /<hr>/{
            =
            q
        }
        b loop
    }' "${1}"
}

function getPostContent() {
    local previewPosition=$(getPostPreviewPosition "${1}")

    if [ "${previewPosition}" != "" ]; then
        local skipPosition=$previewPosition
    else
        local skipPosition=2
    fi

    sed -e "1,${skipPosition}d" "${1}"
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
        local pageLinkUrl="/"
    else
        local pageLinkUrl="/${pageNumber}/"
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
    echo $(find "${1}" -type f -name "index.md" \
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