# POSIX command line arguments

- An option is a hyphen followed by a single character, e.g. `-o`
- An option may require an argument, e.g. `-o argument` or `-argument`
- Options that do not require arguments can be grouped, e.g. `-lst` is equivalent to `-t -l -s`
- Options can appear in any order, e.g. `-lst` is equivalent to `-tls`
- Options can appear multiple times.
- Options precede other nonoption arguments: `-lst nonoption`
- The `--` argument terminates options
