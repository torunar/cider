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
cider.sh [-c|--config] [-l|--localization] [-i|--inputDir] [-o|--outputDir] [-t|--theme] [-p|--pageSize] [-H|--host] [-h|--help]

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

WIP.

## Writing a theme

WIP.

## Localizing

WIP.

