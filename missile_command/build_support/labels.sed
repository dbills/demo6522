#!/bin/sed
# strip out zero page variables 
# and make a labels files from them
/SEG.U\tZEROP/,/ FILE/{
s/\t//g
s/^[0-9a-f ]{7} U([0-9a-f]{4}) {7}[0-9a-f]{2} [0-9a-f]{2}   ([a-zA-Z0-9_]+) +.*$/\2\t\1/p
s/^[0-9a-f ]{7} U([0-9a-f]{4}) {7}[0-9a-f]{2}   ([a-zA-Z0-9_]+) +.*$/\2\t\1/p}