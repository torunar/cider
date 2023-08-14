#!/usr/bin/env bash

CIDER_version="3.3.0"

# a cellar is the place where a cider comes from
CIDER_cellar="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CIDER_currentDir=$(pwd -P)

#
# load core
#
source "${CIDER_cellar}/core/arguments.sh"
source "${CIDER_cellar}/core/dependencies.sh"
source "${CIDER_cellar}/core/blog.sh"
source "${CIDER_cellar}/core/config.sh"

#
# load localization
#
source "${CIDER_cellar}/core/localization.sh"
CIDER_localization=( $(compgen -A variable | grep CIDER_) )

#
# parse CLI arguments
#
parseArgs $@
if [ $? -ne 0 ]; then
    help
    exit $?
fi

#
# check dependencies
#
checkDependencies
if [ $? -ne 0 ]; then
    help
    exit $?
fi

#
# validate arguments passed via CLI or config
#
validateArgs "${CIDER_inputDir}" "${CIDER_outputDir}" "${CIDER_themeDir}" "${CIDER_pageSize}" "${CIDER_host}"
if [ $? -ne 0 ]; then
    exit $?
fi

#
# copy the whole theme
#
cp -r "${CIDER_themeDir}/"* "${CIDER_outputDir}"

#
# get list of posts
#
count=0
pageNumber=1
postsList=($(getPostsList "${CIDER_inputDir}" "${CIDER_buildPost}"))
if [ -z "${postsList}" ]; then
    echo 'No posts to render'
    exit 0
fi

#
# open sitemap and RSS
#
if [ -z "${CIDER_buildPost}" ]; then
    writeSitemapHeader "${CIDER_outputDir}"
    writeRssHeader "${CIDER_outputDir}" "${CIDER_blogName}" "${CIDER_host}" "${CIDER_blogDescription}" "${CIDER_blogLanguage}" "${CIDER_version}"
fi


lastPostPath="${postsList[${#postsList[@]}-1]}"
for postPath in "${postsList[@]}"; do
    inputPath="${CIDER_inputDir}/${postPath}/index.md"
    outputDir="${CIDER_outputDir}/${postPath}"
    mkdir -p "${outputDir}"

    #
    # copy the whole folder
    #
    cp -r "${CIDER_inputDir}/${postPath}/"* "${outputDir}"

    tmpPostPath="${outputDir}/.index.html"
    compiledPostPath="${outputDir}/index.html"
    listItemPath="${CIDER_outputDir}/post_${count}.html"

    markdown -html4tags "${inputPath}" > "${tmpPostPath}"
    if [ $? -ne 0 ]; then
        exit $?
    fi

    postLink="/${postPath}/"
    canonicalLink="${CIDER_host}${postLink}"

    postDate=$(getPostDate "${postPath}")

    postTitle=$(getPostTitle "${tmpPostPath}")

    postPreview=$(getPostPreview "${tmpPostPath}")

    postContent=$(getPostContent "${tmpPostPath}")

    mainTitle=$(stripTags "${postTitle}")

    echo "${canonicalLink}: ${mainTitle}"

    renderTemplate "${CIDER_themeDir}" "posts/single.ct" "${compiledPostPath}"
    renderTemplate "${CIDER_themeDir}" "posts/list_item.ct" "${listItemPath}"

    if [ -z "${CIDER_disqusId}" ]; then
        renderVariable "${compiledPostPath}" "postComments" ""
    else
        renderPostComments "${compiledPostPath}" "${CIDER_host}${postLink}" "${postLink}" "${outputDir}"
    fi

    tr=( "${CIDER_localization[@]}" postLink postDate postTitle postPreview postContent mainTitle canonicalLink )
    for varName in "${tr[@]}"; do
        renderVariable "${compiledPostPath}" "${varName}" "${!varName}"
        renderVariable "${listItemPath}" "${varName}" "${!varName}"
    done

    rm -f "${tmpPostPath}"

    if [ ! -z "${CIDER_buildPost}" ]; then
        continue
    fi

    # add post to sitemap
    writeSitemapEntry "${CIDER_outputDir}" "${CIDER_host}${postLink}"
    if [ $pageNumber == 1 ]; then
        writeRssEntry "${CIDER_outputDir}" "${postTitle}" "${CIDER_host}${postLink}" "${postPreview}${postContent}" "${postDate}"
    fi

    ((count++))

    #
    # render index page
    #
    if [[ "${count}" == "${CIDER_pageSize}" || "${postPath}" == "${lastPostPath}" ]]; then

        if [ $pageNumber == 1 ]; then
            indexPagePath="${CIDER_outputDir}/index.html"
            mainTitle="${CIDER_mainTitle}"
            canonicalLink="${CIDER_host}/"
        else
            indexPagePath="${CIDER_outputDir}/${pageNumber}/index.html"
            mainTitle="${CIDER_mainTitlePaged}"
            canonicalLink="${CIDER_host}/${pageNumber}/"
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

        count=0
        ((pageNumber++))
    fi
done

#
# clean up
#
find "${CIDER_outputDir}" -type f -name "*.md" -delete
find "${CIDER_outputDir}" -type f -name "*.ct" -delete
find "${CIDER_outputDir}" -type f -name "post_*.html" -delete
find "${CIDER_outputDir}" -type d -empty -delete

#
# close sitemap
#
if [ -z "${CIDER_buildPost}" ]; then
    writeSitemapFooter "${CIDER_outputDir}"
    writeRssFooter "${CIDER_outputDir}"
fi
