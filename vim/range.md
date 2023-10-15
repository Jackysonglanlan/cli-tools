<!-- from: https://vim.fandom.com/wiki/Ranges -->

# Ranges

---

A _range_ permits a command to be applied to a group of lines in the current buffer. For most commands, the default range is the current line. For example:

- `:s/old/new/g` changes all _old_ to _new_ in the current line
- `:11,15s/old/new/g` changes lines 11 to 15 inclusive
- `:%s/old/new/g` changes all lines

## Examples <a id="examples" ></a>

A range can be specified using line numbers or special characters, as in these examples:

| Range   | Description                                | Example             |
| :------ | :----------------------------------------- | :------------------ |
| `21`    | line 21                                    | `:21s/old/new/g`    |
| `1`     | first line                                 | `:1s/old/new/g`     |
| `$`     | last line                                  | `:$s/old/new/g`     |
| `.`     | current line                               | `:.w single.txt`    |
| `%`     | all lines (same as `1,$`)                  | `:%s/old/new/g`     |
| `21,25` | lines 21 to 25 inclusive                   | `:21,25s/old/new/g` |
| `21,$`  | lines 21 to end                            | `:21,$s/old/new/g`  |
| `.,$`   | current line to end                        | `:.,$s/old/new/g`   |
| `.+1,$` | line _after_ current line to end           | `:.+1,$s/old/new/g` |
| `.,.+5` | six lines (current to current+5 inclusive) | `:.,.+5s/old/new/g` |
| `.,.5`  | same (`.5` is interpreted as `.+5`)        | `:.,.5s/old/new/g`  |

The `:s///` command substitutes in the specified lines. The `:w` command writes a file. On its own, `:w` writes all lines from the current buffer to the file name for the buffer. Given a range and a file name, `:w` writes only the specified lines to the specified file. The example above creates file `single.txt` containing the current line.

If you know you want to substitute in six lines, starting from the current line, you can use either of the ranges shown above. An easier method is to enter a count value (type `6`), then enter the colon command with no range (type `:s/old/new/g`). Because you entered a count, Vim displays the command:

```vim
:.,.+5s/old/new/g
```

## Default range <a id="default-range" ></a>

For most commands, the default range is `.` (the current line, for example, `:s///` substitutes in the current line). However, for `:g//` and `:w` the default is `%` (all lines).

| Example        | Equivalent      | Description                      |
| :------------- | :-------------- | :------------------------------- |
| `:s/old/new/g` | `:.s/old/new/g` | substitute in current line       |
| `:g/old/`      | `:%g/old/`      | list all lines matching `old`    |
| `:w my.txt`    | `:%w my.txt`    | write all lines to file `my.txt` |

## Selections <a id="selections" ></a>

A command like `:123,145s/old/new/g` substitutes in lines 123 to 145 inclusive, but what if you're not sure what the line numbers are? One method is to use _marks_: Type `ma` in the first line, then type `mb` in the last line (to set marks `a` and `b`). Then enter command `:'a,'bs/old/new/g` to substitute in lines from mark `a` to `b`, inclusive.

Another method is to visually select lines, then enter a colon command (for example, `:s/old/new/g`). Note that you do not enter a range. However, because the command was entered while lines were selected, Vim displays the command as:

```vim
:'<,'>s/old/new/g
```

The range `'<,'>` is entered automatically to identify the lines that were last visually selected (they do not need to be visually selected now).

For example, you might type `vip` to visually select "inner paragraph" (the paragraph holding the cursor). Then type `:s/old/new/g` to substitute in all lines in the selected paragraph.

## Deleting, copying and moving <a id="deleting-copying-and-moving" ></a>

Ranges work with Ex commands (those typed after a colon, for example, `:w`). As well as the commands we've seen so far, it's handy to know how to use `:d` (delete lines), `:t` or `:co` (copy lines), and `:m` (move lines).

| Command      | Description                                         |
| :----------- | :-------------------------------------------------- |
| `:21,25d`    | delete lines 21 to 25 inclusive                     |
| `:$d`        | delete the last line                                |
| `:1,.-1d`    | delete all lines before the current line            |
| `:.+1,$d`    | delete all lines after the current line             |
| `:21,25t 30` | copy lines 21 to 25 inclusive to just after line 30 |
| `:$t 0`      | copy the last line to before the first line         |
| `:21,25m 30` | move lines 21 to 25 inclusive to just after line 30 |
| `:$m 0`      | move the last line to before the first line         |

The line numbers in a command are those _before_ the command executes. In the earlier example which moved lines 21..25 to after 30, the "30" refers to the line number before the move occurred.

## Ranges with marks and searches <a id="ranges-with-marks-and-searches" ></a>

In a range, a line number can be given as:

- A mark (for example, `'x` is the line containing mark `x`).
- A search (for example, `/pattern/` is the next line matching _pattern_).

When using a mark, it must exist in the current buffer.

| Command               | Description                                                 |
| :-------------------- | :---------------------------------------------------------- |
| `:'a,'bd`             | delete lines from mark `a` to mark `b`, inclusive           |
| `:.,'bd`              | delete lines from the current line to mark `b`, inclusive   |
| `:'a,'bm 0`           | move lines from mark `a` to `b` inclusive, to the beginning |
| `:'a,'bw file.txt`    | write lines from mark `a` to `b` to file.txt                |
| `:'a,'bw >> file.txt` | append lines from mark `a` to `b` to file.txt               |

Here are some examples using searches:

- `:.,/green/co $`

      Copy the lines from the current line to the next line containing 'green' (inclusive), to the end of the buffer.

- `:/apples/,/apples/+1s/old/new/g`

      Replace all "old" in the next line in which the "apples" occurs, and the line following it.

- `:/apples/;.1s/old/new/g`

      Same (`.1` is `.+1`, and because `;` was used, the cursor position is set to the line matching "apples" _before_ interpreting the `.+1`).

- `:/apples/,.100s/old/new/g`

      Replace all "old" in the next line in which "apples" occurs, and all lines up to and including 100 lines after the current line (where the command was entered).

      To do a replace in blocks identified by an initial and a final pattern: `:/apples/,/peaches/ s/old/new/g`.
      Replace all "old" in the first block that starts with "apples" and ends with "peaches".

      `/apples/` identifies the first line after the cursor containing "apples".
      `/peaches/` is similar (first line after the current line, _not_ the first after "apples").
      Be aware of backwards ranges. The block is all lines from "apples" to "peaches", inclusive.

- `:/apples/;/peaches/ s/old/new/g`

      Same, but "peaches" identifies the first occurrence _after_ "apples".

- `:/apples/,/peaches/ s/^/# /g`

      Insert "`# `" at the start of each line in the first block.

- `:/apples/+1,/peaches/-1 s/^/# /g`

      Insert "`# `" at the start of each line inside the block.

- To do a global replace in all blocks with the same patterns, use `:g`:

      `:g/apples/,/peaches/ s/^/# /g` Insert "`# `" at the start of each line in all identified blocks.

      `:g/apples/` identifies each line containing "apples".
      In each such line, `.,/peaches/ s/^/# /g` is executed (the `.` is assumed; it means the current line, where "apples" occurs).

- `:g/^function!\? \\(s:\\)\?My/;/^endfunction/s/^/" /`

      _This example is for a Vim script where functions start with `function` or `function!` and end with `endfunction`._

      Insert `" ` at the start of each line in each block.
      All functions that start with `function My` or `function s:My` will be commented out.
      The last line in each block is where `endfunction` first occurs (at the left margin), after where `function My` is found.

Even more tricks are available; see [:help cmdline-ranges](http://vimdoc.sourceforge.net/cgi-bin/help?tag=cmdline-ranges). Summary:

| Item        | Description                                                    |
| :---------- | :------------------------------------------------------------- |
| `/pattern/` | next line where _pattern_ matches                              |
| `?pattern?` | previous line where _pattern_ matches                          |
| `\/`        | next line where the previously used search pattern matches     |
| `\?`        | previous line where the previously used search pattern matches |
| `\&`        | next line where the previously used substitute pattern matches |
| `0;/that`   | first line containing "that" (also matches in the first line)  |
| `1;/that`   | first line after line 1 containing "that"                      |

## Comments <a id="comments" ></a>

I find this counter-intuitive to define a range with commas. Examples : 21,25

I would prefer 21-25 ... --July 19, 2016

---

A dash cannot be used because it refers to negative numbers, relative to the current line. The following uses range `-3,-1` to yank (copy) the three line just before each line containing "password".

```vim
:let @a=''
:g/password/-3,-1y A
:new
:put a
```
