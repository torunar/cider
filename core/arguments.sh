#!/usr/bin/env bash

function parseArgs()
{
    local error=0

    for arg in "$@"; do
        case $arg in
            -h|--help)
                local error=1
                ;;
            -b=*|--buildPost=*)
                CIDER_buildPost="${arg#*=}"
                shift;
                ;;
            -c=*|--config=*)
                source "${arg#*=}"
                shift
                ;;
            -l=*|--localization=*)
                source "${arg#*=}"
                shift
                ;;
            -i=*|--inputDir=*)
                CIDER_inputDir="${arg#*=}"
                shift
                ;;
            -o=*|--outputDir=*)
                CIDER_outputDir="${arg#*=}"
                shift
                ;;
            -t=*|--theme=*)
                CIDER_themeDir="${CIDER_cellar}/themes/${arg#*=}"
                shift
                ;;
            -p=*|--pageSize=*)
                CIDER_pageSize="${arg#*=}"
                shift
                ;;
            -H=*|--host=*)
                CIDER_host="${arg#*=}"
                shift
                ;;
            -x)
                showLogo
                ;;
            *)
                echo "Unknown argument: ${arg}"
                local error=1
                ;;
        esac
    done

    return $error
}

function validateArgs()
{
    local inputDir=$1
    local outputDir=$2
    local themeDir=$3
    local pageSize=$4
    local host=$5
    local error=0

    if [ ! -d "${inputDir}" ]; then
        echo "Input directory ${inputDir} doesn't exist"
        local error=1
    fi
    if [ ! -d "${outputDir}" ]; then
        echo "Output directory ${outputDir} doesn't exist"
        local error=1
    fi
    if [ ! -d "${themeDir}" ]; then
        echo "Theme directory ${themeDir} doesn't exist"
        local error=1
    fi
    if [ -z "${host}" ]; then
        echo "Homepage address is not specified."
        local error=1
    fi
    if [ $pageSize -lt 1 ]; then
        echo "Wrong page size: ${pageSize}"
        local error=1
    fi

    return $error
}

function help() {
    echo '
CIDER: Markdown-based blogging engine using BASH.

Usage:

    cider.sh [-b|--buildPost] [-c|--config] [-l|--localization] [-i|--inputDir] [-o|--outputDir] [-t|--theme] [-p|--pageSize] [-H|--host] [-h|--help]

    -b|--buildPost     Slug of the single post to be built.
                       E.g.: 2019/12/25/merry-xmas

    -c|--config        Path to the configuration file.
                       The default one is loaded from `core/config.sh`

    -l|--localization  Path to localization file.
                       The default one is loaded from `core/localization.sh`

    -i|--inputDir      Path to the directory where posts are placed with the following structure:
                       /YYYY/MM/DD/postName/index.md
                           YYYY - year  - 4 numbers
                           MM   - month - 2 numbers
                           DD   - day   - 2 numbers

    -o|--outputDir     Path to the directory where posts are exported.

    -t|--theme         The theme to use.
                       Themes are located in the `themes` directory.

    -p|--pageSize      The amount of posts per page.

    -H|--host          Homepage address.
                       E.g.: http://example.com

    -h|--help          Show this help and exit.

Dependencies:

    sed        https://linux.die.net/man/1/sed
    grep       https://linux.die.net/man/1/grep
    find       https://linux.die.net/man/1/find
    sort       https://linux.die.net/man/1/sort
    tr         https://linux.die.net/man/1/tr
    less       https://linux.die.net/man/1/less
    echo       https://linux.die.net/man/1/echo
    markdown   http://daringfireball.net/projects/markdown/
' | less
}

function showLogo() {
    echo '
     [===]
     |   |
     |   |
    /     \
   |       |
   |-------|    __/__
   | CIDER |  /       \
   |-------| |         |
   |       |  \       /
   |_______|   \_,,,_/
   '
    exit
}
