#!/usr/bin/env bash

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
# check dependencies
#
checkDependencies
if [ $? -ne 0 ]; then
    help
    exit $?
fi

#
# parse CLI arguments
#
parseArgs $@
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
postsList=($(getPostsList "${CIDER_inputDir}"))
if [ "${postsList}" == "" ]; then
    exit 0
fi

#
# open sitemap and RSS
#
writeSitemapHeader "${CIDER_outputDir}"
writeRssHeader "${CIDER_outputDir}" "${CIDER_blogName}" "${CIDER_host}" "${CIDER_blogDescription}" "${CIDER_blogLanguage}"


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

    postLink="/${postPath}"

    postDate=$(getPostDate "${postPath}")

    postTitle=$(getPostTitle "${tmpPostPath}")

    postPreview=$(getPostPreview "${tmpPostPath}")

    postContent=$(getPostContent "${tmpPostPath}")

    mainTitle=$(stripTags "${postTitle}")

    echo "${postLink}: ${mainTitle}"

    renderTemplate "${CIDER_themeDir}" "posts/single.ct" "${compiledPostPath}"
    renderTemplate "${CIDER_themeDir}" "posts/list_item.ct" "${listItemPath}"

    tr=( "${CIDER_localization[@]}" postLink postDate postTitle postPreview postContent mainTitle )
    for varName in "${tr[@]}"; do
        renderVariable "${compiledPostPath}" "${varName}" "${!varName}"
        renderVariable "${listItemPath}" "${varName}" "${!varName}"
    done

    rm -f "${tmpPostPath}"

    # add post to sitemap
    writeSitemapEntry "${CIDER_outputDir}" "${CIDER_host}${postLink}"
    if [ $pageNumber == 1 ]; then
        writeRssEntry "${CIDER_outputDir}" "${postTitle}" "${CIDER_host}${postLink}" "${postPreview}${postContent}" "${postDate}"
    fi

    ((count++))

    if [[ "${count}" == "${CIDER_pageSize}" || "${postPath}" == "${lastPostPath}" ]]; then

        if [ $pageNumber == 1 ]; then
            indexPagePath="${CIDER_outputDir}/index.html"
            mainTitle="${CIDER_mainTitle}"
        else
            indexPagePath="${CIDER_outputDir}/${pageNumber}/index.html"
            mainTitle="${CIDER_mainTitlePaged}"
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

        tr=( "${CIDER_localization[@]}" mainTitle postsList pageNumber )
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
find "${CIDER_outputDir}" -type d -empty -delete

#
# close sitemap
#
writeSitemapFooter "${CIDER_outputDir}"
writeRssFooter "${CIDER_outputDir}"
