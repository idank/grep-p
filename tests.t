  $ alias g='python $GREPP -p'
  $ cat <<EOF > file.py
  > def a():
  >     b
  >     c
  > EOF

option parsing:
  $ g -c
  grep: invalid option -- 'p' can't be used with -Z, -c, -L or -l
  Usage: grep [OPTION]... PATTERN [FILE]...
  Try `grep --help' for more information.
  [2]

  $ g --foo
  grep: unrecognized option '--foo'
  Usage: grep [OPTION]... PATTERN [FILE]...
  Try `grep --help' for more information.
  [2]
  $ g -C a
  grep: a: invalid context length argument
  [2]

  $ python $GREPP -cp
  grep: invalid option -- 'p' can't be used with -Z, -c, -L or -l
  Usage: grep [OPTION]... PATTERN [FILE]...
  Try `grep --help' for more information.
  [2]
  $ python $GREPP -Hnp b file.py
  file.py:1=def a():
  file.py:2:    b
  $ python $GREPP -rp b file.py
  def a():
      b

simplest match:
  $ g b file.py
  def a():
      b

  $ g def file.py
  def a():

don't print the same function twice:
  $ g -e b -e c file.py
  def a():
      b
      c

print filename:
  $ g -H b file.py
  file.py=def a():
  file.py:    b

print lineno:
  $ g -n b file.py
  1=def a():
  2:    b

print filename and lineno:
  $ g -H -n b file.py
  file.py:1=def a():
  file.py:2:    b

suppress filename:
  $ g -h b file.py
  def a():
      b
  $ g -h -n b file.py
  1=def a():
  2:    b

options seen later should override previous ones:
  $ g -H -h b file.py
  def a():
      b
  $ g -Hh b file.py
  def a():
      b

context lines:
  $ g -C 1 c file.py
      b
  def a():
      c
  $ g -A1 b file.py
  def a():
      b
      c
  $ g -B1 c file.py
      b
  def a():
      c

byte offset:
  $ g -b b file.py
  def a():
  9:    b
  $ g -nb b file.py
  1=def a():
  2:9:    b
  $ g -Hnb b file.py
  file.py:1=def a():
  file.py:2:9:    b

colors:
  $ g --color=always b file.py
  def a():
      \x1b[01;31m\x1b[Kb\x1b[m\x1b[K (esc)

  $ g -Hn --color=always b file.py
  \x1b[35m\x1b[Kfile.py\x1b[m\x1b[K\x1b[36m\x1b[K:\x1b[m\x1b[K\x1b[32m\x1b[K1\x1b[m\x1b[K\x1b[36m\x1b[K=\x1b[m\x1b[Kdef a(): (esc)
  \x1b[35m\x1b[Kfile.py\x1b[m\x1b[K\x1b[36m\x1b[K:\x1b[m\x1b[K\x1b[32m\x1b[K2\x1b[m\x1b[K\x1b[36m\x1b[K:\x1b[m\x1b[K    \x1b[01;31m\x1b[Kb\x1b[m\x1b[K (esc)

binary files:
  $ printf 'a\0' > binary
  $ g a binary
  Binary file binary matches

GREP_OPTIONS:
  $ GREP_OPTIONS="-H" g b file.py
  file.py=def a():
  file.py:    b
  $ GREP_OPTIONS="-H" g b file.py -h
  def a():
      b

piping stuff should 'work' since we can't find the extension of the printed file name:
  $ printf 'def foo():\nbar' | g bar
  bar
