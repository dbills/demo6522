# I'm really bummed about this
# I can't seem to get directories to show up on my winvice
# as a drive on my windows PC ( which I must use, a story I will not
# go into as it depressed me, especially in cause but also as effect ).  The directory
# as a drive always worked for me under linux, and previously under windows
# oh well, I have to use c1541 I reckon
#C1541=c:\winvice3\c1541 -attach disk1.d64 -write a.p00 a 
C1541=/mnt/c/winvice3/c1541.exe
all:
	rm -f a.p00 a.lst
	dasm main.asm -oa.p00 && dasm main.asm -la.lst
	sed -rnf build_support/subs.sed < a.lst
	$(C1541) -attach disk1.d64 -delete a -write a.p00 a 

lt:
	cd c-examples && make

generate_labels:
	cat a.lst | sed -e 's/\t/    /g' | sed -ne '7p' | cut -c29-33

