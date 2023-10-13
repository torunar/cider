#!/usr/bin/env bash

CIDER_version="4.0.1"

# a cellar is the place where a cider comes from
CIDER_cellar="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CIDER_currentDir=$(pwd -P)

# load core
source "${CIDER_cellar}/core/arguments.sh"
source "${CIDER_cellar}/core/dependencies.sh"
source "${CIDER_cellar}/core/blog.sh"
source "${CIDER_cellar}/core/config.sh"

# load localization
source "${CIDER_cellar}/core/localization.sh"
CIDER_localization=( $(compgen -A variable | grep CIDER_) )

# parse CLI arguments
parseArgs $@
if [ $? -ne 0 ]; then
    help
    exit $?
fi

# check dependencies
checkDependencies
if [ $? -ne 0 ]; then
    help
    exit $?
fi

# validate arguments passed via CLI or config
validateArgs "${CIDER_inputDir}" "${CIDER_outputDir}" "${CIDER_themeDir}" "${CIDER_pageSize}" "${CIDER_host}"
if [ $? -ne 0 ]; then
    exit $?
fi

# copy the whole theme
cp -r "${CIDER_themeDir}/"* "${CIDER_outputDir}"

# get list of posts
postNumber=0
pageNumber=1
postsList=($(getPostsList "${CIDER_inputDir}" "${CIDER_buildPost}"))
if [ -z "${postsList}" ]; then
    echo 'No posts to render'
    exit 0
fi

# open sitemap and RSS
if [ -z "${CIDER_buildPost}" ]; then
    writeSitemapHeader "${CIDER_outputDir}"
    writeRssHeader "${CIDER_outputDir}" "${CIDER_blogName}" "${CIDER_host}" "${CIDER_blogDescription}" "${CIDER_blogLanguage}" "${CIDER_version}"
fi

lastPostPath="${postsList[${#postsList[@]}-1]}"
for postPath in "${postsList[@]}"; do
    if [[ "$((postNumber + 1))" == "${CIDER_pageSize}" || "${postPath}" == "${lastPostPath}" ]]; then
        renderPost "${postPath}" "${pageNumber}" "${postNumber}"
    else
        renderPost "${postPath}" "${pageNumber}" "${postNumber}" &
    fi
    ((postNumber++))

    if [ ! -z "${CIDER_buildPost}" ]; then
        continue
    fi

    if [[ "${postNumber}" == "${CIDER_pageSize}" || "${postPath}" == "${lastPostPath}" ]]; then
        renderIndexPage "${pageNumber}"
        ((pageNumber++))
        postNumber=0
    fi
done

# close sitemap
if [ -z "${CIDER_buildPost}" ]; then
    writeSitemapFooter "${CIDER_outputDir}"
    writeRssFooter "${CIDER_outputDir}"
fi

# clean up
find "${CIDER_outputDir}" -type f -name "*.md" -delete
find "${CIDER_outputDir}" -type f -name "*.ct" -delete
find "${CIDER_outputDir}" -type f -name "post_*.html" -delete
find "${CIDER_outputDir}" -type d -empty -delete
