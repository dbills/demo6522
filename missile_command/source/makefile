# I'm really bummed about this
# I can't seem to get directories to show up on my winvice
# as a drive on my windows PC ( which I must use, a story I will not
# go into as it depressed me, especially in cause but also as effect ).  The directory
# as a drive always worked for me under linux, and previously under windows
# oh well, I have to use c1541 I reckon
# C1541=c:\winvice3\c1541 -attach disk1.d64 -write a.p00 a
C1541=/mnt/c/winvice3/c1541.exe
EXE=a
MAIN=source/main.asm
FLAGS=-I./headers/ -I./data/ -I./source/
CA65FIX= sed  -e 's/^\([^(]*\)[(]\([0-9]*\)[)]:/\1:\2:0:/'
all: tests
	rm -f a.p00 a.lst
	dasm $(MAIN) $(FLAGS) -oa.p00;dasm $(MAIN) $(FLAGS) -la.lst
	sed -rnf build_support/subs.sed < a.lst > labels.txt
	sed -rnf build_support/labels.sed < a.lst >> labels.txt
#$(C1541) -attach disk1.d64 -delete a -write a.p00 a

tests:
	cd testing && make

foo:
	cc65 foo.cc -t vic20 -o foo.S
	ca65 foo.S -o foo.o
	ld65 -o b.p00 -C vic20-32k.cfg -m foo.map foo.o vic20.lib

OBJS=main.o jstick.o shapes.o line.o target.o text.o zerop.o screen.o sprite.o timer.o debugscreen.o playfield.o interceptor.o queue.o sound.o system.o screen_draw.o detonation.o bigletter.o math.o scroller.o attract.o insertion_sort.o unit_tests.o icbm.o mushroom.o mushroom_draw.o collision.o

SOURCE=$(OBJS:.o=.asm)

graphics:
	cd ../build_support && g++-8 sprite.cc -lm
	(cd ../build_support && ./explosions2.sh) > screen_draw.asm

extra_graphics:
	g++-8 -fpermissive -g -D_GLIBCXX_DEBUG -std=c++17 ../build_support/piskel2ca65.c  -o /tmp/piskel2ca65
	/tmp/piskel2ca65 ../piskel/mc_mushrom.c > mushroom_draw.asm

port: graphics extra_graphics
	if [ ! -d obj ]; then mkdir obj;fi
	rm -f *.o *.inc
	rm -f test.asm
#	ca65 --cpu 6502 -I headers source/jstick.asm
#	ca65 --cpu 6502 -I headers source/line.asm 2>&1 | $(CA65FIX)
#	cc65 -T --cpu 6502 test.c -o test.asm 2>&1 | ../build_support/fix_errors.sh
	for i in $(SOURCE);do ../build_support/assemble.sh $$i;done
	for i in $(SOURCE);do ../build_support/assemble.sh $$i asm || exit 1;done
# make sure main is first so the start addr is always the same
#cl65 -o a.p00 -tvic20 -Ln vlabels.txt -m a.map -C linker.cfg --listing --add-source --debug main.o test.o $(OBJS)
	cd obj;cl65 -o ../a.p00 -tvic20 -Ln ../vlabels.txt -m a.map -C ../linker.cfg --listing --add-source --debug $(OBJS)
	cd obj;perl ../../build_support/mapfile.pl a.map > a.lst

foo1:
	ca65 --cpu 6502 shapes.asm -l foo.lst
