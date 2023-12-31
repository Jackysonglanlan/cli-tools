<!-- https://linuxhandbook.com/sed-reference-guide/ -->

# Complete Sed Command Guide

Table of Contents

- [A little bit of theory](#_a_little_bit_of_theory)
  - [A first look at the sed execution model](#_a_first_look_at_the_sed_execution_model)
  - [The Sed abstract machine](#_the_sed_abstract_machine)
  - [A more accurate Sed execution model](#_a_more_accurate_sed_execution_model)
- [The print command](#_the_print_command)
- [Addresses](#_addresses)
  - [Line numbers](#_line_numbers)
  - [Regular expressions](#_regular_expressions)
  - [Extended regular expressions](#_extended_regular_expressions)
  - [The bracket quantifier](#_the_bracket_quantifier)
  - [Range addresses](#_range_addresses)
  - [Complement](#_complement)
  - [Conjunctions](#_conjunctions)
- [The quit command](#_the_quit_command)
- [The substitution command](#_the_substitution_command)
  - [The delete command](#_the_delete_command)
  - [The next command](#_the_next_command)
- [Working with the hold space](#_working_with_the_hold_space)
  - [The exchange command](#_the_exchange_command)
  - [The hold commands](#_the_hold_command)
  - [The get command](#_the_get_command)
- [print, delete and next revisited](#_print_delete_and_next_revisited)
- [Branching](#_branching)
  - [labels and branches](#_labels_and_branches)
  - [Conditional branch](#_conditional_branch)
- [Handling verbatim text](#_handling_verbatim_text)
  - [The change command](#_the_change_command)
  - [The insert command](#_the_insert_command)
  - [The append command](#_the_append_command)
  - [The read command](#_the_read_command)
- [Alternate output](#_alternate_output)
  - [The write command](#_the_write_command)
  - [The substitution command `write` flag](#_the_substitution_command_write_flag)
- [Comments](#_comment)
- [The commands you will rarely need](#_the_commands_you_will_rarely_need)
  - [The line number command](#_the_line_number_command)
  - [The unambiguous print command](#_the_unambiguous_print_command)
  - [The transliterate command](#_the_transliterate_command)
- [The last word](#_the_last_word)

## A little bit of theory on Sed <a id="_a_little_bit_of_theory"></a>

### A first look at the sed execution model <a id="_a_first_look_at_the_sed_execution_model"></a>

To truly understand Sed you must first understand the tool execution model.

When processing data, Sed reads one line of input at a time and stores it into the so-called _pattern space_. All Sed’s transformations apply to the pattern space. Transformations are described by one-letter commands provided on the command line or in an external Sed script file. Most Sed commands can be preceded by an address, or an address range, to limit their scope.

By default, Sed prints the content of the pattern space at the end of each processing cycle, that is, just before overwriting the pattern space with the next line of input. We can summarize that model like that:

1. Try to read the next input line into the pattern space
2. If the read was successful:
   1. Apply in the script order all commands whose address matches the current input line
   2. If sed was not launched in quiet mode (`-n`) print the content of the (potentially modified) pattern space
   3. got back to 1.

Since the content of the pattern space is lost after each line is processed, it is not suitable for long-term storage. For that purpose, Sed has a second buffer, the _hold space_. Sed never clears, puts or gets data from the hold space unless you explicitly request it. We will investigate that more in depth later when studying the [exchange](#exchange), [get](#get) and [hold](#hold) commands.

### The Sed abstract machine <a id="_the_sed_abstract_machine"></a>

The model explained above is what you will see described in many Sed tutorials. Indeed, it is correct enough to understand the most basic Sed programs. But when you start digging into more advanced commands, you will see it is not sufficient. So let’s try to be a little bit more formal now.

Actually, Sed can be viewed as implementing an [abstract machine](http://mathworld.wolfram.com/AbstractMachine.html) whose [state](<https://en.wikipedia.org/wiki/State_(computer_science)>) is defined by three [buffers](https://en.wikipedia.org/wiki/Data_buffer), two [registers](https://en.wikipedia.org/wiki/Processor_register#Categories_of_registers), and two [flags](https://www.computerhope.com/jargon/f/flag.htm):

- **three buffers** to store arbitrary length text. Yes: _three_! In the basic execution model we talked about the pattern- and hold-space, but Sed has a third buffer: the _append queue_. From the Sed script perspective, it is a write-only buffer that Sed will flush automatically at predefined moments of its execution (broadly speaking before reading a new line from the input, or just before quitting).

- Sed also maintains **two registers**: the _line counter_ (LC) which holds the number of lines read from the input, and the _program counter_ (PC) which always hold the index (“position” in the script) of the next command to execute. Sed automatically increments the PC as part of its main loop. But using specific commands, a script can also directly modify the PC to skip or repeat parts of the program. This is how loops or conditional statements can be implemented with Sed. More on that in the dedicated [branches section](#branches) below.

- Finally **two flags** can modify the behavior of certain Sed commands: the _auto-print flag_ (AP) the _substitution flag_ (SF). When the auto-print flag is _set_, Sed will automatically print the content of the pattern space _before_ overwriting it (notably before reading a new line of input but not only). When the auto-print flag is _clear_ (“not set”), Sed will never print the content of the pattern space without an explicit command in the script. You can clear the auto-print flag by running Sed in “quiet mode” (using the `-n` command line option or by using the [special comment](#comment)`#n` on the very first line or the script). The “substitution flag” is set by the [substitution command](#substitution) (the `s` command) when both its address and search pattern match the content of the pattern space. The substitution flag is cleared at the start of each new cycle, or when a new line is read from input, or after a conditional branch is taken. Here again, we will revisit that topic in details in the [branches section](#branches).

In addition, Sed maintains the list of commands having entered their address range (more on that of the [range addresses](#range) section) as well as a couple of file handles to read and write data. You will find some more information on that in the [read](#read) and [write](#write) command description.

### A more accurate Sed execution model <a id="_a_more_accurate_sed_execution_model"></a>

As a picture worth thousands of words, I draw a flowchart describing the Sed execution model. I left a couple of things aside, like dealing with multiple input files or error handling, but I think this should be sufficient for you to understand the behavior of any Sed program and to avoid wasting your time by groping around while writing your own Sed scripts.

<js-ext-figure class="js-illustration">
![The Sed execution model](./sed-flowchart.png)
</js-ext-figure>

You may have noticed I didn’t describe the command-specific actions in the flowchart above. We will see that in detail for each command. So, without further ado, let’s start our tour!

## The print command <a id="_the_print_command"></a>

The print command (`p`) displays the content of the pattern space at the moment it is executed. It does not change in any way the state of the Sed abstract machine.

<js-ext-figure class="js-illustration">
![The Sed `print` command](./sed-print-command.png)
</js-ext-figure>

For example:

```bash
sed -e 'p' inputfile
```

The command above will print each line of the input file … twice.
Once because you _explicitly_ requested it using the `print` command, and a second time _implicitly_ at the end of the processing loop (because we didn’t launch Sed in “quiet mode” here).

If we are not interested in seeing each line twice, we have two way of fixing that:

```bash
sed -n -e 'p' inputfile # quiet mode with explicit print
sed -e '' inputfile  # empty "do nothing" program, implicit print
```

Note: the `-e` option introduces a Sed command. It is used to distinguish between commands and file names. Since a Sed invocation must contain at least one command, the `-e` flag is optional for that first command. However, I have the habit of using it, mostly for consistency with more complex cases where I have to give multiple Sed expressions on the command line. I let you figure by yourself if this is a good or bad habit, but I will follow that convention in the rest of the article.

## Addresses <a id="_addresses"></a>

Obviously, the print command is not very useful by itself. However, if you add an address before the command to apply it only to some lines of the input file, it suddenly becomes able to filter out unwanted lines from a file. But what’s an address for Sed? And how are identified the “lines” of the input file?

### Line numbers <a id="_line_numbers"></a>

A Sed address can be either a _line number_ (with the extension of `$` to mean “the last line”) or a _regular expression_. When using line numbers, you have to remember lines are numbered starting from one in Sed— and not starting from zero.

```bash
sed -n -e '1p' inputfile # print only the first line of the file
sed -n -e '5p' inputfile # print only the line 5
sed -n -e '$p' inputfile # print the last line of the file
sed -n -e '0p' inputfile # will result in an error because 0 is not a valid line number
```

According to the [POSIX specifications](http://pubs.opengroup.org/onlinepubs/9699919799/utilities/sed.html), line numbers are cumulative if you specify several input files. In other words, the line counter is not reset when Sed opens a new input file. So, the two commands below will do the same thing, printing only one line of text to the output:

```bash
sed -n -e '1p' inputfile1 inputfile2 inputfile3
cat inputfile1 inputfile2 inputfile3 | sed -n -e '1p'
```

Actually, this is exactly how POSIX defines multiple file handling:

> If multiple file operands are specified, the named files shall be read in the order specified and the concatenation shall be edited.

However, some Sed implementations offer command line options to change that behavior, like the GNU Sed `-s` flag (which is implicitly applied too when using the GNU Sed `-i` flags):

```bash
sed -sn -e '1p' inputfile1 inputfile2 inputfile3
```

If your implementation of Sed supports such non-standard options, I let you check into the `[man](https://linux.die.net/man/1/man)` for the details regarding them.

### Regular expressions <a id="_regular_expressions"></a>

I’ve said Sed addresses could be line numbers or regular expressions. But what is this _regex_ thing?

In just a few words, a [regular expression](https://www.regular-expressions.info/) is a way to describe a _set_ of strings. If a given string pertains to the set described by a regular expression, we said the string matches the regular expression.

A regular expression may contain literal characters that must be present verbatim into a string to have a match. For example, all letters and digits behave that way, as well as most printable characters. However, some symbols have a special meaning:

- They could represent anchors, like `^` and `$` that respectively denotes the start or end of a line;

- other symbols can serve as placeholders for entire sets of characters (like the dot that matches any single characters or the square brackets that are used to define a custom character set);

- others again are quantifiers that serve to denotes repetitions (like the [Kleene star](https://chortle.ccsu.edu/FiniteAutomata/Section07/sect07_16.html) that means 0, 1 or several occurrences of the previous pattern).

My goal here is not to give you a regular expression tutorial. So I will stick with just a few examples. However, feel free to search for more on the web about that topic: regular expressions are a really powerful feature available in many standard Unix commands and programming language and a skill every Unixien should master.

Here are few examples used in the context of a Sed address:

```bash
sed -n -e '/systemd/p' inputfile # print only lines *containing* the literal string "systemd"
sed -n -e '/nologin$/p' inputfile # print only lines ending with "nologin"
sed -n -e '/^bin/p' inputfile # print only lines starting with "bin"
sed -n -e '/^$/p' inputfile # print only empty lines (i.e.: nothing between the start and end of a line)
sed -n -e '/./p' inputfile # print only lines containing a character (i.e. print only non-empty lines)
sed -n -e '/^.$/p' inputfile # print only lines containing exactly one character
sed -n -e '/admin.*false/p' inputfile # print only lines containing "admin" followed by "false" (with any number of arbitrary characters between them)
sed -n -e '/1[0,3]/p' inputfile # print only lines containing a "1" followed by a "0" or "3"
sed -n -e '/1[0-2]/p' inputfile # print only lines containing a "1" followed by a "0", "1", "2" or "3"
sed -n -e '/1.*2/p' inputfile # print only lines containing the character "1" followed by a "2" (with any number of arbitrary characters between them)
sed -n -e '/1[0-9]*2/p' inputfile # print only lines containing the character "1" followed by zero, one or more digits, followed by a "2"
```

If you want to remove the special meaning of a character in a regular expression (including the regex delimiter symbol), you have to precede it with a slash:

```bash
# Print all lines containing the string "/usr/sbin/nologin"
sed -ne '/\/usr\/sbin\/nologin/p' inputfile
```

You are not limited to use only the slash as the regular expression delimiter in an address. You can use any other character that could suit your needs and tastes by preceding the first delimiter by a backslash. This is particularly useful when you have addresses that should match literal slashes like when working with file paths:

```bash
# Both commands are perfectly identical
sed -ne '/\/usr\/sbin\/nologin/p' inputfile
sed -ne '\=/usr/sbin/nologin=p' inputfile
```

### Extended regular expressions <a id="_extended_regular_expressions"></a>

By default, the Sed regular expression engine only understands the [POSIX basic regular expression](https://www.regular-expressions.info/posix.html#bre) syntax. If you need [extended regular expressions](https://www.regular-expressions.info/posix.html#ere), you must add the `-E` flag to the Sed command. Extended regular expressions add a couple of extra feature to basic regular expressions and, most important maybe, they require far fewer backslashes. I let you compare:

```bash
sed -n -e '/\(www\)\|\(mail\)/p' inputfile
sed -En -e '/(www)|(mail)/p' inputfile
```

### The bracket quantifier <a id="_the_bracket_quantifier"></a>

One powerful feature of regular expressions is the [range quantifier](https://www.regular-expressions.info/repeat.html#limit)`{,}`. Actually, when written exactly like that, this quantifier is a perfect synonym for the `*` quantifier. However, you can explicitly add a lower and upper bound on each side of the coma, something that gives a tremendous amount of flexibility. When the lower bound of the range quantifier is omitted, it is assumed to be zero. When the upper bound is omitted, it is assumed to be the infinity:

| Bracket notation | Shorthand | Description                                          |
| ---------------- | --------- | ---------------------------------------------------- |
| {,}              | `*`       | zero, one or many occurrences of the preceding regex |
| {,1}             | ?         | zero or one occurrence of the preceding regex        |
| {1,}             | +         | one or many occurrences of the preceding regex       |
| {n,n}            | {n}       | exactly n occurrences of the preceding regex         |

The bracket notation is available in basic regular expressions too, but it requires backslashes. According to POSIX, the only quantifiers available in basic regular expression are the star and the bracket notation (with backslashes `\{m,n\}`). Many regex engines do support the `\?` and `\+` notation as an extension. However, why tempting the devil? If you need those quantifiers, using extended regular expressions will be both easier to write and more portable.

If I took the time to talk about the bracket notation for regex quantifiers, this is because that feature is often useful in Sed scripts to count characters.

```bash
sed -En -e '/^.{35}$/p' inputfile # Print lines containing exactly 35 characters
sed -En -e '/^.{0,35}$/p' inputfile # Print lines containing 35 characters or less
sed -En -e '/^.{,35}$/p' inputfile # Print lines containing 35 characters or less
sed -En -e '/^.{35,}$/p' inputfile # Print lines containing 35 characters or more
sed -En -e '/.{35}/p' inputfile # I let you figure out this one by yourself (test it!)
```

### Range addresses <a id="_range_addresses"></a>

All the addresses we used so far were unique addresses. When using an unique address, the command is applied only the line(s) matching that address. However, Sed also supports range addresses. They are used to apply a command to all lines _between_ the start and the end address of the range:

```bash
sed -n -e '1,5p' inputfile # print only lines 1 through 5
sed -n -e '5,$p' inputfile # print from line 5 to the end of the file

sed -n -e '/xxx/,/systemd/p' inputfile # print from the first line matching the /xxx/ regular expression to the next line
                                       # matching the /systemd/ regular expression.
```

If the same line _number_ is used both for the start and end address, the range is reduced to that line. Actually, if the second address is a number less than or equal to the line number of the first selected line of the range, only one line will be selected:

```console
$ printf "%s\n" {a,b,c}{d,e,f} | cat -n | sed -ne '4,4p'
     4    bd

$ printf "%s\n" {a,b,c}{d,e,f} | cat -n | sed -ne '4,3p'
     4    bd
```

This is somewhat tricky, but the rule given in the previous paragraph also applies when the _start address is a regular expression_. In that case, Sed will compare the _line number_ of the first line matching the regex with the explicit _line number_ given as end address. Once again, if the end line number is lower or equal to the start line number, the range will be reduced to one line:

```console
# The /b/,4 address will match *three* one-line range since each matching line has a line number >= 4
$ printf "%s\n" {a,b,c}{d,e,f} | cat -n | sed -ne '/b/,4p'
     4  bd
     5  be
     6  bf

# I let you figure by yourself how many ranges are matched by that second example:
$ printf "%s\n" {a,b,c}{d,e,f} | cat -n | sed -ne '/d/,4p'
     1  ad
     2  ae
     3  af
     4  bd
     7  cd
```

However, the behavior of Sed is different when the end address is a _regular expression_. In that case, the first line of the range is _not_ tested against the end address, so the range will contain at least two lines (except of course if there is not enough input data):

```console
$ printf "%s\n" {a,b,c}{d,e,f} | cat -n | sed -ne '/b/,/d/p'
     4    bd
     5    be
     6    bf
     7    cd

$ printf "%s\n" {a,b,c}{d,e,f} | cat -n | sed -ne '4,/d/p'
     4    bd
     5    be
     6    bf
     7    cd
```

### Complement <a id="_complement"></a>

Adding an exclamation mark (`!`) after an address select lines _not_ matching that address. For example:

```bash
sed -n -e '5!p' inputfile # Print all lines except line 5
sed -n -e '5,10!p' inputfile # Print all lines except line 5 to 10
sed -n -e '/sys/!p' inputfile # Print all lines except those containing "sys"
```

### Conjunctions <a id="_conjunctions"></a>

allows to group commands in blocks using brackets (`{…​}`). You can leverage that feature to combine several addresses. For example, let’s compare the output of those two commands:

```bash
sed -n -e '/usb/{
/daemon/p
}' inputfile

sed -n -e '/usb.*daemon/p' inputfile
```

By nesting commands in a block, we will select lines containing “usb” and “daemon” in any order. Whereas the regular expression “usb.\*daemon” would only match lines where the “usb” string appears before the “daemon” string.

After that long digression, let’s go back now to our review of the various Sed commands.

## The quit command <a id="_the_quit_command"></a>

The quit command will stop Sed at the end of the current processing loop iteration.

<js-ext-figure class="js-illustration">
![The Sed `quit` command](./sed-quit-command.png)
</js-ext-figure>

The `quit` command is a way to stop input processing before reaching the end of the input file. Why would someone want to do that?

Well, if you remember, we’ve seen you can print the lines 1 through 5 of a file using the following command:

```bash
sed -n -e '1,5p' inputfile
```

With most implementations of Sed, the tool will read and cycle over all the remaining input lines, even if only the first five can produce a result. This may have a significant impact if your file contains millions of rows (or even worst, if you read from an infinite stream of data like `/dev/urandom` for example).

Using the quit command, the same program can be rewritten much more efficiently:

```bash
sed -e '5q' inputfile
```

Here, since I did not use the `-n` option, Sed will implicitly print the pattern space at the end of each cycle, but it will quit, and thus not reading more data, after having processed the line 5.

We could use a similar trick to print only a specific line of a file. That will be a good occasion to see several ways of providing multiple Sed expressions from the command line. The three variations bellow take benefit of Sed accepting several commands, either as different `-e` options, or in the same expression, but separated by newlines or semi-colon:

```bash
sed -n -e '5p' -e '5q' inputfile
```

```bash
sed -n -e '
  5p
  5q
' inputfile
```

```bash
sed -n -e '5p;5q' inputfile
```

If you remember it, we’ve seen earlier we can group commands using brackets, something that we could use here to avoid repeating the same address twice:

```bash
# By grouping commands
sed -e '5{
  p
  q
}' inputfile
```

```bash
# Which can be shortened as:
sed '5{p;q;}' inputfile
```

```bash
# As a POSIX extension, some implementations makes the semi-colon before the closing bracket optional:
sed '5{p;q}' inputfile
```

## The substitution command <a id="_the_substitution_command"></a>

You can imagine the substitution command as the Sed equivalent to the search-replace feature you can find on most WYSIWYG editors. An equivalent, albeit a more powerful one though. The substitution command being one of the best-known Sed commands, it is largely documented on the web.

<js-ext-figure class="js-illustration">
![The Sed `substitution` command](./sed-substitution-command.png)
</js-ext-figure>

We already have covered it [in a previous article](https://linuxhandbook.com/?p=128) so I will not repeat myself here. However there are some key points to remember if you’re not yet completely familiar with it:

- The substitution command takes two parameters: the search pattern and the replacement string: `sed s/:/-----/ inputfile`

- The command and its arguments are separated by an arbitrary character. Mostly by habit, 99% of the time we use a slash but any other character can be used: `sed s%:%-----% inputfile`, `sed sX:X-----X inputfile` or even `sed 's : ----- ' inputfile`

- By default, the substitution is applied only to the first matching substring of the pattern space. You can change that by specifying the match index as a flag after the command: `sed 's/:/-----/1' inputfile`, `sed 's/:/-----/2' inputfile`, `sed 's/:/-----/3' inputfile`, …

- If you want to perform a substitution globally (i.e.: on each non-overlapping match of the pattern space), you need to add the `g` flag: `sed 's/:/-----/g' inputfile`

- In the replacement string, any occurrence of the ampersand (`&`) will be replaced by the substring matching the search pattern: `sed 's/:/-&&&-/g' inputfile`, `sed 's/…​./& /g' inputfile`

- Parenthesis ( `(…​)` in extended regex or `\(…​\)` in basic regex) introduce a _capturing group_. That is a part of the matching string that can be referenced in the replacement string. `\1` is the content of the first capturing group, `\2` the content of the second one and so on: `sed -E 's/(.)(.)/\2\1/g' inputfile`, `sed -E 's/(.**):x:(.**):(.*)/\1:\3/' inputfile` (that latter works because [the star regular expression quantifier is greedy](https://www.regular-expressions.info/repeat.html#greedy), and matches as many characters as it can)

- In the search pattern or the replacement string you can remove the special meaning of any character by preceding it with a backslash: `sed 's/:/--\&--/g' inputfile`, `sed 's/\//\\/g' inputfile`

As all this might seem a little bit abstract, here are a couple of examples. To start, let’s say I want to display the first field of my test input file padded with spaces on the right up to 20 characters, I could write something like that:

```bash
sed < inputfile -E -e '
  s/:/                    / # replace the first field separator by 20 spaces
  s/(.{20}).*/\1/           # keep only the first 20 characters of the line
  s/.*/| & |/               # add vertical bars for a nice output
'
```

As a second example, if I want to change the UID/GID of the user sonia to 1100, I could write something like that:

```bash
sed -En -e '
  /sonia/{
    s/[0-9]+/1100/g
    p
  }' inputfile
```

Notice the `g` option at the end of the substitution command. It modifies its behavior, so all occurrences of the search pattern are replaced. Without that option, only the first one would be.

By the way, this is also a good occasion to mention the print command displays the content of the pattern space at the moment the command is executed. So, I can obtain a before-after output like that:

```bash
sed -En -e '
  /sonia/{
    p
    s/[0-9]+/1100/g
    p
  }' inputfile
```

Actually, since printing a line after a substitution is a common use case, the substitution command also accepts the `p` option for that purpose:

```bash
sed -En -e '/sonia/s/[0-9]+/1100/gp' inputfile
```

Finally, I won’t be exhaustive without mentioning the `w` option of the substitution command. We will examine it in detail [later](#write-flag).

### The delete command <a id="_the_delete_command"></a>

The delete command (`d`) is used to clear the pattern space and immediately start the next cycle. By doing so, it will also skip the implicit print of the pattern space even if the auto-print flag is set.

<js-ext-figure class="js-illustration">
![The Sed `delete` command](./sed-delete-command.png)
</js-ext-figure>

A particularly inefficient way of printing only the first five lines of a file would be:

```bash
sed -e '6,$d' inputfile
```

I let you guess why I said this was inefficient. If this is not obvious, try to re-read the section concerning the [quit command](#quit). The answer is there!

The delete command is particularly useful when combined with regular expression-based addresses to remove matching lines from the output:

```bash
sed -e '/systemd/d' inputfile
```

### The next command <a id="_the_next_command"></a>

This command prints the current pattern space if Sed is not running in quiet mode, then, in all cases, it reads the next input line into the pattern space and executes the _remaining commands of the current cycle_ with the new pattern space.

<js-ext-figure class="js-illustration">
![The Sed `next` command](./sed-next-command.png)
</js-ext-figure>

A common use case of the next command is to skip lines:

```bash
cat -n inputfile | sed -n -e 'n;n;p'
```

In the example above, Sed will implicitly read the first line of the input file.
But the `next` command discards (and does not display because of the `-n` option) the pattern space and replaces it with
the next line from the input.
And the second `next` command will do the same thing, skipping now the line 2 of the input.
And finally, the script explicitly prints the pattern space which now contains the third line of the input.

Then Sed will start a new cycle, implicitly reading the line 4, then skipping it, as well as the line 5, because of the
`next` commands, and it will print the line 6. And again and again until the end of the file.

Concretely, this prints one line over three of the input file.

Using the next command, we can also find a couple of other ways to display the first five lines of a file:

```bash
cat -n inputfile | sed -n -e '1{p;n;p;n;p;n;p;n;p}'
cat -n inputfile | sed -n -e 'p;n;p;n;p;n;p;n;p;q'
cat -n inputfile | sed -e 'n;n;n;n;q'
```

More interestingly, the next command is also very useful when you want to process lines _relative_ to some address:

```bash
cat -n inputfile | sed -n '/pulse/p'       # print lines containing "pulse"
cat -n inputfile | sed -n '/pulse/{n;p}'   # print the line following
                                           # the line containing "pulse"
cat -n inputfile | sed -n '/pulse/{n;n;p}' # print the line following
                                           # the line following
                                           # the line containing "pulse"
```

## Working with the hold space <a id="_working_with_the_hold_space"></a>

Until now, the command we’ve seen dealt only with the pattern space. However, as we’ve mentioned it at the very top of this article, there is a second buffer, the hold space, entirely under the control of the user. This will be the purpose of the commands described in this section.

### The exchange command <a id="_the_exchange_command"></a>

As it names implies it, the exchange command (`x`) will swap the content of the hold and pattern space. Remember as long as you didn’t put anything into the hold space, it is empty.

<js-ext-figure class="js-illustration">
![The Sed `exchange` command](./sed-exchange-command.png)
</js-ext-figure>

As a first example, we may use the exchange command to print in reverse order the first two lines of a file:

```bash
cat -n inputfile | sed -n -e 'x;n;p;x;p;q'
```

Of course, you don’t have to use the content of the hold space immediately after having set it, since the hold space remains untouched as long as you don’t explicitly modify it. In the following example, I use it to move the first line of the input after the fifth one:

```bash
cat -n inputfile | sed -n -e '
  1{x;n}                # Swap the hold and pattern space to store line 1 into the hold bufferand then read line two
  5{
    p                   # print line 5
    x                   # swap the hold and pattern space to get back the content of line one into the pattern space
  }

  1,5p                  # triggered on lines 2 through 5
                        # (not a typo! try to figure why this rule is NOT executed for line 1;)
'
```

### The hold commands <a id="_the_hold_commands"></a>

The hold command (`h`) is used to store the content of the pattern space into the hold space. However, as opposed to the exchange command, this time the content of the pattern space is left unchanged. The hold commands came in two flavors:

`h`

that will copy the content of the pattern space into the hold space, overwriting any value already present

`H`

that will append the content of the pattern space to the hold space, using a newline as separator

<js-ext-figure class="js-illustration">
![The Sed `hold` command](./sed-hold-command.png)
</js-ext-figure>

The example above using the exchange command can be rewritten using the hold command instead:

```bash
cat -n inputfile | sed -n -e '
  1{h;n}                # Store line 1 into the hold buffer and continue
  5{                    # on line 5
    x                   # switch the pattern and hold space (now the pattern space contains the line 1)
    H                   # append the line 1 after the line 5 in the hold space
    x                   # switch again to get back lines 5 and 1 into the pattern space
  }

  1,5p                  # triggered on lines 2 through 5
                        # (not a typo! try to figure why this rule is NOT executed for line 1;)
'
```

### The get command <a id="_the_get_command"></a>

The get command (`g`) does the exact opposite of the hold command: it takes the content of the hold space and put it into the pattern space. Here again, it comes in two flavors:

`g`

that will copy the content of the hold space into the pattern space, overwriting any value already present

`G`

that will append the content of the hold space to the pattern space, using a newline as separator

<js-ext-figure class="js-illustration">
![The Sed `get` command](./sed-get-command.png)
</js-ext-figure>

Together, the hold and get commands allow to store and recall data. As a little challenge, I let you rewrite the example of the previous section to put the line 1 of the input file after the line 5, but this time using the get and hold commands (lower- or upper-case version), but _without_ using the exchange command. With a little bit of luck, it should be simpler that way!

In the meantime, I can show you another example that could serve for your inspiration. The goal here is to separate the users having a login shell from the others:

```bash
cat -n inputfile | sed -En -e '
  \=(/usr/sbin/nologin|/bin/false)$= { H;d; }
              # Append matching lines to the hold buffer and continue to next cycle
  p           # Print other lines
  $ { g;p }   # On the last line, get and print the content of the hold buffer
'
```

## print, delete and next revisited <a id="_print_delete_and_next_revisited"></a>

Now you’ve gained more familiarities with the hold space, let me go back on the `print`, `delete` and `next` commands. We already talked about the lower case `p`, `d` and `n` commands. But they also have an upper case version. As it seems to be a convention with Sed, the uppercase version of those commands will be related to multi-line buffers:

`P`

print the content of the pattern space _up to the first newline_

`D`

delete the content of the pattern space _up and including the first newline_ then restart a cycle with the remaining text _without_ reading any new input

`N`

_read and append a new line of input_ to the pattern space using the newline character as a separator between the old and new data. Continue the execution of the current cycle.

<js-ext-figure class="js-illustration">
![The Sed uppercase `Delete` command](./sed-delete-upper-command.png)
</js-ext-figure>

<js-ext-figure class="js-illustration">
![The Sed uppercase `Next` command](./sed-next-upper-command.png)
</js-ext-figure>

The main use case for those commands is to implement queues ([FIFO lists](<https://en.wikipedia.org/wiki/FIFO_(computing_and_electronics)>)). The canonical example being removing the last 5 lines from a file:

```bash
cat -n inputfile | sed -En -e '
  1 { N;N;N;N }     # ensure the pattern space contains *five* lines

  N                 # append a sixth line onto the queue
  P                 # Print the head of the queue
  D                 # Remove the head of the queue
'
```

As a second example, we could display input data on two columns:

```bash
# Print on two columns
sed < inputfile -En -e '
 $!N                # Append a new line to the pattern space *except* on the last line of input
                    # This is a trick required to deal with inconsistencies between GNU Sed and POSIX Sed
                    # when using N on the last line of input
                    # https://www.gnu.org/software/sed/manual/sed.html#N_005fcommand_005flast_005fline

                    # Right pad the first field of the first line with spaces and discard rest of the line
 s/:.*\n/                    \n/
 s/:.*//            # Discard all but the first field on the second line
 s/(.{20}).*\n/\1/  # Trim and join lines
 p                  # Print result
'
```

## Branching <a id="_branching"></a>

We just saw Sed has buffer capabilities through the hold space. But it also has test and branch instructions. Having both those features makes Sed a [Turing complete](https://chortle.ccsu.edu/StructuredC/Chap01/struct01_5.html) language. It may sound silly, but that means you can write any program using Sed. You can do it, but that does not mean it would be an easy task, nor that the result would be particularly efficient of course.

However, don’t panic. In this article, we will stay with simple examples of tests and branches. Even if these capabilities seem limited at first sight, remember some people have written [http://www.catonmat.net/ftp/sed/dc.sed](http://www.catonmat.net/ftp/sed/dc.sed) [calculators], [http://www.catonmat.net/ftp/sed/sedtris.sed](http://www.catonmat.net/ftp/sed/sedtris.sed) [Tetris] or many other kinds of applications using sed!

### labels and branches <a id="_labels_and_branches"></a>

By some aspects, you can see Sed as a very limited assembly language. So you won’t find high-level “for” or “while” loops or “if … else” statements, but you can implement them using branches.

<js-ext-figure class="js-illustration">
![The Sed `branch` command](./sed-branch-command.png)
</js-ext-figure>

If you take a look at the flowchart describing the Sed execution model at the top of this article, you can see Sed automatically increments the program counter, resulting in the execution of the commands in the program’s instructions order. However, using branch instructions, you can break that sequential flow by continuing the execution with any command of your choice in the program. The destination of a jump is explicitly defined using a label.

<js-ext-figure class="js-illustration">
![The Sed `label` command](./sed-label-command.png)
</js-ext-figure>

Here is an example:

```bash
echo hello | sed -ne '
  :start      # Put the "start" label on that line of the program
  p           # Print the pattern buffer
  b start     # Continue execution at the :start label
' | less
```

The behavior of that Sed program is very close to the [yes](https://linux.die.net/man/1/yes) command:
it takes a string and produces an infinite stream of lines containing that string.

Branching to a label as we did bypass all Sed automatic features: it does not read any input, nor print anything, nor update any buffer. It just jumps to a different instruction instead of executing the next one in the source program order.

Worth mentioning without any label specified as an argument, the branch command (`b`) will branch to the end of the program. So Sed will start a new cycle. This may be useful to bypass some instructions and thus may be used as an alternative to blocks:

```bash
cat -n inputfile | sed -ne '
/usb/!b
/daemon/!b
p
'
```

### Conditional branch <a id="_conditional_branch"></a>

Until now, we’ve seen the so-called unconditional branches, even if the term is somewhat misleading in this context since Sed commands are always conditional based on their optional address.

However, in a more traditional sense, an _unconditional_ branch is a branch that, when executed, will _always jump_ to the specified destination, whereas a _conditional_ branch _may or may not jump_ to the specified instruction depending on the current state of the system.

has only one conditional instruction, the test (`t`) command. It jumps to a different instruction only if a substitution was executed since the start of the current cycle or since the previous conditional branch. More formally, the test command will branch only if the _substitution flag_ is set.

<js-ext-figure class="js-illustration">
![The Sed `test` command](./sed-test-command.png)
</js-ext-figure>

With the test instruction, you can easily perform loops in a Sed program. As a practical example, you can use that to pad lines to a certain length (something you can’t do with regex only):

```bash
# Center text
cut -d: -f1 inputfile | sed -Ee '
  :start
  s/^(.{,19})$/ \1 /    # Pad lines shorter than 20 chars with a space at the start and another one at the end
  t start               # Go back to :start if we added a space
  s/(.{20}).*/| \1 |/   # Keep only the first 20 char of the line to fix the off-by-one error caused by odd lines
'
```

If you carefully read the previous example, you’ve noticed I cheated a little bit by using the cut command to pre-process the data before feeding them to sed.

We can, however, perform the same task using only sed at the cost of a small modification to the program:

```bash
cat inputfile | sed -Ee '
  s/:.*//               # Remove all but the first field
  t start
  :start
  s/^(.{,19})$/ \1 /    # Pad lines shorter than 20 chars with a space at the start and another one at the end
  t start               # Go back to :start if we added a space
  s/(.{20}).*/| \1 |/   # Keep only the first 20 char of the line to fix the off-by-one error caused by odd lines
'
```

In the above example, you may be surprised by the following construct:

```bash
 t start
:start
```

At first sight, the branch here seems useless since it will jump to the instruction that would have been executed anyway. However, if you read the definition of the `test` command attentively, you will see it branches only _if there was a substitution_ since the start of the current cycle or _since the previous test command was executed_. In other words, the test instruction has the side effect of clearing the _substitution flag_. This is exactly the purpose of the code fragment above. This is a trick you will often see in Sed programs containing conditional branches to avoid false positive when using several substitutions commands.

I agree though it wasn’t absolutely mandatory here to clear the substitution flag since the specific substitution command I used is idempotent once it has padded the string to the right length. So one extra iteration will not change the result. However, look at that second example now:

```bash
# Classify user accounts based on their login program
cat inputfile | sed -Ene '
  s/^/login=/
  /nologin/s/^/type=SERV /
  /false/s/^/type=SERV /
  t print
  s/^/type=USER /
  :print
  s/:.*//p
'
```

My hope here was to tag the user accounts with either “SERV” or “USER” depending on the configured default login program. If you ran it, you’ve seen the “SERV” tag as expected. However, no trace of the “USER” tag in the output. Why? Because the `t print` instruction will _always_ branch since whatever was the content of the line, the _substitution flag_ was set by the very first substitution command of the program. Once set, the flag remains set until a next line is read— or until the next test command. And gives us the solution to fix that program:

```bash
# Classify user accounts based on the login program
cat inputfile | sed -Ene '
  s/^/login=/

  t classify # clear the "substitution flag"
  :classify

  /nologin/s/^/type=SERV /
  /false/s/^/type=SERV /
  t print
  s/^/type=USER /
  :print
  s/:.*//p
'
```

## Handling verbatim text <a id="_handling_verbatim_text"></a>

is a text editor. A non-interactive one. But a text editor nevertheless. It wouldn’t be complete without some facility to insert literal text in the output. I’m not a big fan of that feature since I find the syntax awkward (even by the Sed standards), but sometimes you can’t avoid it.

In the strict POSIX syntax, all the three commands to change (`c`), insert (`i`) or append (`a`) some literal text to the output follow the same specific syntax: the command letter is followed by a backslash, and the text to insert start on the next line of the script:

```bash
head -5 inputfile | sed '
1i\
# List of user accounts
$a\
# end
'
```

To insert multiple lines of text, you must end each of them with a backslash:

```bash
head -5 inputfile | sed '
1i\
# List of user accounts\
# (users 1 through 5)
$a\
# end
'
```

Some Sed implementations, like GNU Sed, makes the newline after the initial backslash optional, even when forced in `--posix` mode. I didn’t find anything in the standard that authorizes that alternate syntax. So use it at your own risks if portability is a premium (or leave a comment if I missed that feature in the specifications!):

```bash
# non-POSIX syntax:
head -5 inputfile | sed -e '
1i \# List of user accounts
$a\# end
'
```

Some Sed implementation also makes the initial backslash completely optional. Since this is, without any doubt this time, a vendor-specific extension to the POSIX specifications, I let you check the manual for the version of sed you use to check if it supports that syntax.

After that quick overview, let’s review those commands in more details now, starting with the change command I didn’t have presented yet.

### The change command <a id="_the_change_command"></a>

The change command (`c\`) deletes the pattern space and starts a new cycle just like the `d` command. The only difference is the user provided text is written on the output when the command is executed.

<js-ext-figure class="js-illustration">
![The Sed `change` command](./sed-change-command.png)
</js-ext-figure>

```bash
cat -n inputfile | sed -e '
/systemd/c\
# :REMOVED:
s/:.*// # This will NOT be applied to the "changed" text
'
```

If the change command is associated with a [range address](#range), the text is output only once, when reaching the last line of the range. Which somehow makes it an exception to the convention a Sed command is repeatedly applied to all lines of its range address:

```bash
cat -n inputfile | sed -e '
19,22c\
# :REMOVED:
s/:.*// # This will NOT be applied to the "changed" text
'
```

As a consequence, if you want the change command to be repeated for every line in a range, you have no other choice than wrapping it inside a block:

```bash
cat -n inputfile | sed -e '
19,22{c\
# :REMOVED:
}
s/:.*// # This will NOT be applied to the "changed" text
'
```

### The insert command <a id="_the_insert_command"></a>

The insert command (`i\`) immediately print the user-provided text on the output. It does not alter in any way the program flow or buffer content.

<js-ext-figure class="js-illustration">
![The Sed `insert` command](./sed-insert-command.png)
</js-ext-figure>

```bash
# display the first five user names with a title on the first row
sed < inputfile -e '
1i\
USER NAME
s/:.*//
5q
'
```

### The append command <a id="_the_append_command"></a>

The append command (`a\`) queues some text to be displayed when the next line of input will be read. The text is output at the end of the current cycle (including at the end of the program) or when a new line is read from the input using either the `n` or `N` command.

<js-ext-figure class="js-illustration">
![The Sed `append` command](./sed-append-command.png)
</js-ext-figure>

Same example as above, but inserts this time a footer instead of a header:

```bash
sed < inputfile -e '
5a\
USER NAME
s/:.*//
5q
'
```

### The read command <a id="_the_read_command"></a>

There is a fourth command to insert literal content into the output stream: the read command (`r`). It works exactly like the append command, but instead of taking the text hardcoded from the Sed script itself, it will write the content of a file on the output.

The read command only schedules the file to be read. That latter is effectively read when the append queue is flushed. Not when the read command is executed. This may have implications if there are concurrent accesses to the file to be read, if that file is not a regular file (for example, if it’s a character device or a named pipe), or if the file is modified during processing.

As an illustration, if you use the [write](#write) command we will see in detail in the next section together with the read command to write and re-read from a temporary file, you may obtain some creative results (using a French equivalent of the [Shiritori](https://en.wikipedia.org/wiki/Shiritori) game as an illustration):

```bash
printf "%s\n" "Trois p'tits chats" "Chapeau d' paille" "Paillasson" |
sed -ne '
  r temp
  a\
  ----
  w temp
'
```

We’ve now ended the list of the Sed commands dedicated to the insertion of literal text in the stream output. My last example was mostly for fun, but since I mentioned there the write command, that makes a perfect transition with the next section where we will see how to write data to an external file from Sed.

## Alternate output <a id="_alternate_output"></a>

is designed with the idea all text transformations will end-up being written on the standard output of the process. However, Sed also has some provision to send data to alternate destinations. You have two ways to do that: using the dedicated write command, or by adding the write flag to a substitution command.

### The write command <a id="_the_write_command"></a>

The write command (`w`) appends the content of the pattern space to the given destination file. POSIX requires the destination file to be created by Sed before it starts processing any input data. If the file already exists, it is overwritten.

<js-ext-figure class="js-illustration">
![The Sed `write` command](./sed-write-command.png)
</js-ext-figure>

As a consequence, even if you never really write to a file, it will be created anyway. For example, the following Sed program will create/overwrite the “output” file, even if the write command is never executed:

```bash
echo | sed -ne '
q         # immediately quit
w output  # this command is never executed
'
```

You can have several write commands referencing the same destination file. All write commands at the destination of the same file will append content to that file (more or less in the same manner as the `>>` shell redirection). :

```bash
sed < inputfile -ne '
/:\/bin\/false$/w server
/:\/usr\/sbin\/nologin$/w server
w output
'
cat server
```

### The substitution command `write` flag <a id="_the_substitution_command_write_flag"></a>

A long time ago now, we had seen the substitution command has the `p` option for the common use case of printing the pattern space after a substitution. In a very similar manner it also has a `w` option to write the pattern space to a file after a substitution:

```bash
sed < inputfile -ne '
s/:.*\/nologin$//w server
s/:.*\/false$//w server
'
cat server
```

## Comments <a id="_comments"></a>

I already used them countless times, but I never took the time to introduce them formally, so, let’s fix that: like in most programming languages, a _comment_ is a way to add free-form text the software will not try to interpret. The Sed syntax being rather cryptic, I can’t insist enough on the need to comment your scripts. Otherwise, they will be hardly understandable by anyone except their author.

<js-ext-figure class="js-illustration">
![The Sed `comment` command](./sed-comment-command.png)
</js-ext-figure>

However, like many other parts of Sed, comments have their own share of subtleties. First, and the most important, comments are not a syntactic construct, but are full-fledged commands in Sed. A do-nothing (“no-op”) command, but a command anyway. At least, that is how there are defined by POSIX. So, strictly speaking, they should only be allowed where other commands are allowed.

Most Sed implementation relaxes that requirement by allowing inline commands as I used them all over the place in that article.

To close on that topic, worth mentioning the very special case of the `#n` comment (an octothorpe followed by the letter n without any space). If that exact comment if found on the very first line of a script, Sed should switch to quiet mode (i.e., clearing the auto-print flag) just like if the `-n` option was specified on the command line.

## The commands you will rarely need <a id="_the_commands_you_will_rarely_need"></a>

Now, we have reviewed the commands that will allow you to write 99.99% of your scripts. But this tour wouldn’t be exhaustive if I didn’t mention the last remaining Sed commands. I left them aside until now because I rarely needed them. But maybe did you have on your side examples of practical use cases where you find them useful. If that is the case do not hesitate to share that with us using the comment section.

### The line number command <a id="_the_line_number_command"></a>

The `=` command writes on the standard output the number of lines currently read by Sed, that is the content of the line counter register. There is no way to capture that number in one of the Sed buffers, nor to format the output. Two limitations that severely reduce the usefulness of that command.

<js-ext-figure class="js-illustration">
![The Sed `line number` command](./sed-current-line-command.png)
</js-ext-figure>

Remember in strict POSIX compliance mode, when several input files are given on the command line, Sed does not reset that counter but continue to increment it just like if all the files where concatenated. Some Sed implementations like GNU Sed have options to reset the counter after each input file.

### The unambiguous print command <a id="_the_unambiguous_print_command"></a>

The `l` (lowercase letter ell) is similar to the print command (`p`), but the content of the pattern space will be written in an unambiguous form. To quote [the POSIX standard](http://pubs.opengroup.org/onlinepubs/9699919799/utilities/sed.html):

> The characters listed in XBD Escape Sequences and Associated Actions ( ‘\\\\’, ‘\\a’, ‘\\b’, ‘\\f’, ‘\\r’, ‘\\t’, ‘\\v’ ) shall be written as the corresponding escape sequence; the ‘\\n’ in that table is not applicable. Non-printable characters not in that table shall be written as one three-digit octal number (with a preceding `<backslash>`) for each byte in the character (most significant byte first). Long lines shall be folded, with the point of folding indicated by writing a `<backslash>` followed by a `<newline>`; the length at which folding occurs is unspecified, but should be appropriate for the output device. The end of each line shall be marked with a `$`.

<js-ext-figure class="js-illustration">
![The Sed `unambiguous print` command](./sed-unambiguous-print-command.png)
</js-ext-figure>

I suspect this command was once used to exchange data over non [8-bits clean channels](https://en.wikipedia.org/wiki/8-bit_clean). As of myself, I never used it for anything else than for debugging purposes.

### The transliterate command <a id="_the_transliterate_command"></a>

The transliterate (`y`) command allows mapping characters of the pattern space from a source set to a destination set. It is quite similar to the `[tr](https://linux.die.net/man/1/tr)` command, although more limited.

<js-ext-figure class="js-illustration">
![The Sed `transliterate` command](./sed-transliterate-command.png)
</js-ext-figure>

```bash
# The `y` c0mm4nd 1s for h4x0rz only
sed < inputfile -e '
  s/:.*//
  y/abcegio/48<3610/
'
```

While the transliterate command syntax bears some resemblances with the substitution command syntax, it does not accept any option after the replacement string. The transliteration is always global.

Beware that the transliterate command requires all the characters both in the original and destination set to be given verbatim. That means the following Sed program does not do what you might think at first sight:

```bash
# BEWARE: this doesn't do what you may think!
sed < inputfile -e '
  s/:.*//
  y/[a-z]/[A-Z]/
'
```

## The last word <a id="_the_last_word"></a>

```bash
# What will this do?
# Hint: the answer is not far away...
sed -E '
  s/.*\W(.*)/\1/
  h
  ${ x; p; }
  d' < inputfile
```

I can’t believe we did it! We’ve reviewed all the Sed commands. If you reached that point, you deserve congratulations, especially if you took the time to try the different examples on your system!

As you’ve seen, Sed is a complex beast, not only because of its sparse syntax but also because of all the various corner cases or subtle differences in the command behavior. No doubt, we can blame historical reasons for that. Despite these drawbacks, it is a powerful tool and like [AWK command](https://linuxhandbook.com/awk-command-tutorial/), even today remains one of the most useful commands of the Unix toolbox.
