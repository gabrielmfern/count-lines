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

This is slightly slower than the fastest tool I know for this tokei:

```
PS C:\Users\gabri\programming\editor> hyperfine count-lines tokei
Benchmark 1: count-lines (48 runs)
                mean     ±       σ          min     …     max
  Wall Time     55.1 ms  ±     1.6 ms      53.3 ms  …    61.8 ms

Benchmark 2: tokei (53 runs)
                mean     ±       σ          min     …     max
  Wall Time     47.0 ms  ±     1.6 ms      44.5 ms  …    56.0 ms           -14.7%
```

Mainly because it does slightly less passes in the file's contents, ignores `.gitignore` and processes files in parallel.
