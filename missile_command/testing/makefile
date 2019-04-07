CC=gcc
INCLUDES=-I/usr/include/guile/2.0
CFLAGS=-DWSL -Werror -Wall -fPIC -g $(INCLUDES)
#CFLAGS=-Wall -fPIC -g $(INCLUDES)
SOURCE = labels.c fake6502.c vic_os.c errors.c ipc.c commands.c
PRIVATE_SOURCE = machine.c
OBJS = $(subst .c,.o,$(SOURCE) $(PRIVATE_SOURCE))
LDLIBS = $(OBJS) -lguile-2.0 -lm
all: gen_headers $(OBJS) tester 
	#	gcc -I/usr/include/guile/2.0 -Werror -Wall -D WSL -g $(SOURCE) $(PRIVATE_SOURCE) -o tester 
	./tester

gen_headers: makeheaders 
	./makeheaders $(SOURCE)

shared_lib: gen_headers $(OBJS)
	$(CC) -shared -o libfake6502.so $(OBJS)

# run c program that examines a prototype
# of the line algorithm
bres: bresenham
	echo 1 117 1 29 | ./$<
clean: 
	rm -f $(OBJS) tester

$(OBJS): makefile
