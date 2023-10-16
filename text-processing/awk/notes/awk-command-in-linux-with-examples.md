<!-- from: https://phoenixnap.com/kb/awk-command-in-linux -->

# AWK Command in Linux with Examples

Contents

1. [AWK Command Syntax](#awk-command-syntax)

2. [How Does the AWK Command Work?](#how-does-the-awk-command-work)

   1. [AWK Operations](#awk-operations)
   2. [AWK Statements](#awk-statements)
   3. [AWK Patterns](#awk-patterns)
   4. [Regular Expression Patterns](#regular-expression-patterns)
   5. [Relational Expression Patterns](#relational-expression-patterns)
   6. [Range Patterns](#range-patterns)
   7. [Special Expression Patterns](#special-expression-patterns)
   8. [Combining Patterns](#combining-patterns)
   9. [AWK Variables](#awk-variables)
   10. [AWK Actions](#awk-actions)

3. [How to Use the AWK Command - Examples](#how-to-use-the-awk-command-examples)

## AWK Command Syntax <a id="awk-command-syntax" ></a>

The syntax for the **`awk`** command is:

```awk
awk [options] 'selection_criteria {action}' input-file > output-file
```

The available options are:

OptionDescription

**`-F [separator]`**
Used to specify a file separator. The default separator is a blank space.

**`-f [filename]`**
Used to specify the file containing the **`awk`** script. Reads the **`awk`** program source from the specified file, instead of the first command-line argument.

**`-v`**
Used to assign a variable.

**Note:** You might also be interested in learning about the [ Linux curl command](https://phoenixnap.com/kb/curl-command), allowing you to transfer data to and from a [server](https://phoenixnap.com/servers/dedicated) after processing it with awk.

## How Does the AWK Command Work? <a id="how-does-the-awk-command-work" ></a>

The **`awk`** command's main purpose is to make **information retrieval and text manipulation** easy to perform in Linux. The command works by scanning a set of input lines in order and searches for lines matching the patterns specified by the user.

For each pattern, users can specify an action to perform on each line that matches the specified pattern. Thus, using **`awk`**, users can easily process complex log files and output a readable report.

**Note:** The **`awk`** command got its name from three people who wrote the original version in 1977 - Alfred **A**ho, Peter **W**einberger, and Brian **K**ernighan.

### AWK Operations <a id="awk-operations" ></a>

**`awk`** allows users to perform various operations on an input file or text. Some of the available operations are:

- Scan a file line by line.
- Split the input line/file into fields.
- Compare the input line or fields with the specified pattern(s).
- Perform various actions on the matched lines.
- Format the output lines.
- Perform arithmetic and string operations.
- Use control flow and loops on output.
- Transform the files and data according to a specified structure.
- Generate formatted reports.

### AWK Statements <a id="awk-statements" ></a>

The command provides basic control flow statements (**`if-else`**, **`while`**, **`for`**, **`break`**) and also allows users to group statements using braces **`{}`**.

- **if-else**

      The **`if-else`** statement works by evaluating the condition specified in the parentheses and, if the condition is true, the statement following the **`if`** statement is executed. The **`else`** part is optional.

      For example:

      ```awk
      awk -F ',' '{if($2==$3){print $1","$2","$3} else {print "No Duplicates"}}' answers.txt
      ```

      The output shows the lines in which duplicates exist and states _No duplicates_ if there are no duplicate answers in the line.

- **while**

      The **`while`** statement repeatedly executes a target statement as long as the specified condition is true. That means that it operates like the one in the C programming language. If the condition is true, the body of the loop is executed. If the condition is false, **`awk`** continues with the execution.

      For example, the following statement instructs **`awk`** to print all input fields one per line:

      ```awk
      awk '{i=0; while(i<=NF) { print i ":"$i; i++;}}' employees.txt
      ```

- **for**

      The **`for`** statement also works like that of C, allowing users to create a loop that needs to execute a specific number of times.

      For example:

      ```awk
      awk 'BEGIN{for(i=1; i<=10; i++) print "The square of", i, "is", i*i;}'
      ```

      The statement above increases the value of **`i`** by one until it reaches ten and calculates the square of **`i`** each time.

      **Note:** The expressions in the condition part of **`if`**, **`while`** or **`for`** can include relational operators, such as **`<, , >=, ==`** (is equal to), and **`!=`** (not equal to). The expressions can also include regular expression matches with the match operators **`∼`** and **`!∼`**, logical operators **`||, &&`**, and **`!`**. The operators are grouped with parentheses.

- **break**

      The **`break`** statement immediately exits from an enclosing **`while`** or **`for`**. To begin the next iteration, use the **`continue`** statement.

      The **`next`** statement instructs **`awk`** to skip to the next record and begin scanning for patterns from the top. The **`exit`** statement instructs **`awk`** that the input has ended.

      Following is an example of the **`break`** statement:

      ```awk
      awk 'BEGIN{x=1; while(1) {print "Example"; if ( x==5 ) break; x++; }}'
      ```

      The command above breaks the loop after 5 iterations.

      **Note:** The **`awk`** tool allows users to place comments in **`AWK`** programs. Comments begin with **`#`** and end at the end of the line.

### AWK Patterns <a id="awk-patterns" ></a>

Inserting a pattern in front of an action in **`awk`** acts as a **selector**. The selector determines whether to perform an action or not. The following expressions can serve as patterns:

- Regular expressions.
- Arithmetic relational expressions.
- String-valued expressions.
- Arbitrary Boolean combinations of the expressions above.

The following sections explain the above-mentioned expressions and how to use them.

**Note:** Learn how you can search for strings or patterns with the [ grep command](https://phoenixnap.com/kb/grep-multiple-strings).

#### Regular Expression Patterns <a id="regular-expression-patterns" ></a>

Regular expression patterns are the simplest form of expressions containing a string of characters enclosed in slashes. It can be a sequence of letters, numbers, or a combination of both.

In the following example, the program outputs all the lines starting with "A". If the specified string is a part of a larger word, it is also printed.

```awk
awk '$1 ~ /^A/ {print $0}' employees.txt
```

#### Relational Expression Patterns <a id="relational-expression-patterns" ></a>

Another type of **`awk`** patterns are relational expression patterns. The relational expression patterns involve using any of the following relational operators: **<, <=, ==, !=, >=**, and **>**.

Following is an example of an **`awk`** relational expression:

```awk
awk 'BEGIN { a = 10; b = 10; if (a == b) print "a == b" }'
```

#### Range Patterns <a id="range-patterns" ></a>

A range pattern is a pattern consisting of **two patterns** separated by a comma. Range patterns perform the specified action for each line between the occurrence of pattern one and pattern two.

For example:

```awk
awk '/clerk/, /manager/ {print $1, $2}' employees.txt
```

The pattern above instructs **`awk`** to print all the lines of the input containing the keywords "clerk" and "manager".

#### Special Expression Patterns <a id="special-expression-patterns" ></a>

Special expression patterns include **`BEGIN`** and **`END`** which denote program initialization and end. The **`BEGIN`** pattern matches the beginning of the input, before the first record is processed. The **`END`** pattern matches the end of the input, after the last record has been processed.

For example, you can instruct **`awk`** to display a message at the beginning and at the end of the process:

```awk
awk 'BEGIN { print "List of debtors:" }; {print $1, $2}; END {print "End of the debtor list"}' debtors.txt
```

#### Combining Patterns <a id="combining-patterns" ></a>

The **`awk`** command allows users to combine two or more patterns using logical operators. The combined patterns can be any Boolean combination of patterns. The logical operators for combining patterns are:

- **`||`** (or)
- **`&&`** (and)
- **`!`** (not)

For example:

```awk
awk '$3 > 10 && $4 < 20 {print $1, $2}' employees.txt
```

The output prints the first and second fields of those records whose third field is greater than ten and the fourth field is less than 20.

### AWK Variables <a id="awk-variables" ></a>

The **`awk`** command has built-in field variables, which break the input file into separate parts called **fields**. The **`awk`** assigns the following variables to each data field:

- **`$0`**. Used to specify the whole line.
- **`$1`**. Specifies the first field.
- **`$2`**. Specifies the second field.
- etc.

Other available built-in **`awk`** variables are:

- **`NR`**. Counts the number of input records (usually lines). The **`awk`** command performs the pattern/action statements once for each record in a file.

      For example:

      ```awk
      awk '{print NR,$0}' employees.txt
      ```

      The command displays the line number in the output.

- **`NF`**. Counts the number of fields in the current input record and displays the last field of the file.

      For example:

      ```awk
      awk '{print $NF}' employees.txt
      ```

- **`FS`**. Contains the character used to divide fields on the input line. The default separator is space, but you can use **`FS`** to reassign the separator to another character (typically in **`BEGIN`**).

      For example, you can make the _etc/passwd_ file ([user list](https://phoenixnap.com/kb/how-to-list-users-linux)) more readable by changing the separator from a colon (**`:`**) to a dash (**`/`**) and print out the field separator as well:

      ```awk
      awk -FS 'BEGIN{FS=":"; OFS="-"} {print $0}' /etc/passwd
      ```

- **`RS`**. Stores the current record separator character. The default input line is the input record, which makes a newline the default record separator. The command is useful if the input is a comma-separated file (CSV).

      For example:

      ```awk
      awk 'BEGIN {FS="-"; RS=","; OFS=" owes Rs. "} {print $1,$2}' debtors.txt
      ```

      **Note:** We first used the [ cat command](https://phoenixnap.com/kb/linux-cat-command) to show the file's contents and then formatted the output with **`AWK`**.

- **`OFS`**. Stores the output field separator, which separates the fields when printed. The default separator is a blank space. Whenever the printed file has several parameters separated with commas, the **`OFS`** value is printed between each parameter.

      For example:

      ```awk
      awk 'OFS=" works as " {print $1,$3}' employees.txt
      ```

### AWK Actions <a id="awk-actions" ></a>

The **`awk`** tool follows rules containing pattern-action pairs. Actions consist of statements enclosed in curly braces **`{}`** which contain expressions, control statements, compound statements, input and output statements, and deletion statements. Those statements are described in the sections above.

Create an **`awk`** script using the following syntax:

```awk
awk '{action}'
```

For example:

```awk
awk '{print "How to use the awk command"}'
```

This simple command instructs **`awk`** to print the specified string each time you run the command. Terminate the program using **Ctrl+D**.

## How to Use the AWK Command - Examples <a id="how-to-use-the-awk-command-examples" ></a>

Apart from manipulating data and producing formatted outputs, **`awk`** has other uses as it is a scripting language and not only a text processing command. This section explains alternative use cases for **`awk`** .

- **Calculations**. The **`awk `** command allows you to perform arithmetic calculations. For example:

      ```awk
      df | awk '/\/dev\/loop/ {print $1"\t"$2 + $3}'
      ```

      In this example, we pipe into the [df command](https://phoenixnap.com/kb/linux-check-disk-space) and use the information generated in the report to calculate the total memory available and used by the mounted filesystems that contain only _/dev_ and _/loop_ in the name.

      The produced report shows the memory sum of the _/dev_ and _/loop_ filesystems in columns two and three in the **`df `** output.

- **Filtering**. The **`awk`** command allows you to filter the output by limiting the length of the lines. For example:

      ```awk
      awk 'length($0) > 8' /etc/shells
      ```

      In this example, we ran the _/etc/shells_ system file through **`awk`** and filtered the output to contain only the lines containing more than 8 characters.

- **Monitoring**. Check if a certain process is running in Linux by piping into the **`ps`** command. For example:

      ```awk
      ps -ef | awk '{ if($NF == "clipboard") print $0}'
      ```

      The output prints a [list of all the processes running](https://phoenixnap.com/kb/list-processes-linux) on your machine with the last field matching the specified pattern.

- **Counting**. You can use **`awk`** to count the number of characters in a line and get the number printed in the result. For example:

      ```awk
      awk '{ print "The number of characters in line", NR,"=" length($0) }' employees.txt
      ```
