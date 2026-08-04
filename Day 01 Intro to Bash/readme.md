So Today I have learnt what , how and why bash .
Also what is shebang - bascilly the header for shell script
Comments - using # Symbol
How to make script executable using chmod -x script-name.sh and to run them using ./script-name.sh
Also made a Introductory file named intro.sh

Terminal commands i learnt :
Navigation: pwd (where am I), cd (change directory), ls (list files)
File Creation: touch (create file), mkdir (create directory)
File Operations: cp (copy), mv (move/rename), rm (remove)
Useful Options: -r (recursive), -f (force), -i (interactive), -a (all), -l (long format), -h (human-readable)
Special Directories: ~ (home), . (current), .. (parent), - (previous)
Safety: Be careful with rm -rf - there's no undo! Use -i for safety.
Other Commands: cat, head, tail, find, grep, which, whoami, date

variable and their naming conventions:
variable=value(no space around)
use $variable to access it
naming conventions follow the rules of our programming languages
unset command to remove the variable
NO decleration needed , just assign & use
ex:- name="rakesh"


also how to set default values to variables using ${var:-value}
and then to assign it we use ${var:=value}
check for string length using ${#var}
print string offset using ${var:offset:length}
one imp thing to note is when using negative indexes use space before offset i.e
${var: -5}


