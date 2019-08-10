#!/bin/sed
# strip out labels for subroutines
s/\t//g
s/^[0-9a-f ]{7}  ([0-9a-f]{4}) {3}([a-zA-Z0-9_]+) +subroutine.*$/al C:\1\t\.\2/p
