# count-lines

A simple program meant to calcualte the amount of actual lines of a jai codebase in the simplest way possible, without any use of the heap.

Just running the program is enough to count the lines:

```jai
C:\Users\gabri\programming\count-lines>.\count-lines.exe
Lines of code:     133
Lines of comments:   4
Lines of blank:      7
----------------------
Lines:             144
```

Lines of comments are only counted as lines that are fully comments, without any piece of code. It's also careful to not count comments inside of a string, or a multi line string.
Lines of blank are lines that don't have code or comments, only spaces and line breaks.

The program is extremly simple and can be read and understood in a trivial amount of time.

Natural path for this would be to support other languages.
