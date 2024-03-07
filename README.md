```
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
```

# About

CIDER is a markdown-based blogging engine using BASH.

# Usage

```
cider.sh [-c|--config] [-l|--localization] [-i|--inputDir] [-o|--outputDir] [-t|--theme] [-p|--pageSize] [-H|--homepage] [-b|--buildPost] [-h|--help]

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

-H|--homepage      Homepage address.
                   E.g.: http://example.com

-b|--buildPost     Single post slug to rebuild
                   E.g.: 2024/03/07/configuring-cider

-h|--help          Show this help and exit.
```

# Dependencies

* [sed](https://linux.die.net/man/1/sed)
* [grep](https://linux.die.net/man/1/grep)
* [find](https://linux.die.net/man/1/find)
* [sort](https://linux.die.net/man/1/sort)
* [tr](https://linux.die.net/man/1/tr)
* [less](https://linux.die.net/man/1/less)
* [echo](https://linux.die.net/man/1/echo)
* [markdown](http://daringfireball.net/projects/markdown/)

# Core functionality

## Configuration

Configuration parameters affect the build process and resulting blog structure:

* `CIDER_inputDir` - directory that will be used to store temporary data during build
* `CIDER_outputDir` - directory where built pages will be put
* `CIDER_themeDir` - directory where theme should be loaded from (completely overrides `-t|--theme` option)
* `CIDER_pageSize` - amount of posts per page
* `CIDER_homepage` - homepage address
* `CIDER_blogLanguage` - language (used in RSS and specifies HTML lang attribute)
* `CIDER_disqusId` - [Disqus](https://disqus.com/) comment widget ID
* `CIDER_buildPost` - single post slug (e.g. `2024/03/07/configuring-cider`) to rebuild

Default configuration parameter values are loaded from [core/config.sh](core/config.sh).

Parameters that are supplied via configuration file (see `-c|--config` option) or passed as environment variables will override default values:

```bash
$ CIDER_inputDir='/opt/cider.example.com/posts' CIDER_outputDir='/var/www/cider.example.com' CIDER_homepage='https://cider.example.com' cider.sh
```

## Writing a theme

WIP.

## Localizing

Localization messages are used in theme templates to display predefined texts and HTML snippets:

* `CIDER_mainTitle` - HTML title shown for the homepage
* `CIDER_mainTitlePaged` - HTML title shown for the list of posts for pages 2, 3 and so on
* `CIDER_pageLinkPrevText` - symbol that will be used to display navigation link to a previous page
* `CIDER_pageLinkNextText` - symbol that will be used to display navigation link to a next page
* `CIDER_pageLinkCurrText` - HTML snippet that will render current page number
* `CIDER_blogName` - blog name
* `CIDER_blogDescription` - blog description (used in RSS, shown in default themes)
* `CIDER_commentsTitle` - title shown before Disqus comments widget

Default localization messages are loaded from [core/localization.sh](core/localization.sh).

Parameters that are supplied via localization file (see `-l|--localization` option) or passed as environment variables will override default values:

```bash
$ CIDER_blogName='CIDER 101' CIDER_blogDescription='Tips and trick on using CIDER' cider.sh
```
