CC=gcc
INCLUDES=
CFLAGS=-Werror -Wall -fPIC -g $(INCLUDES)
SOURCE = labels.c fake6502.c vic_os.c errors.c ipc.c commands.c
PRIVATE_SOURCE = machine.c
OBJS = $(subst .c,.o,$(SOURCE) $(PRIVATE_SOURCE))
HEADERS = $(subst .c,.h,$(SOURCE))
LDLIBS = $(OBJS) -lm

all: libfake6502.so libfake6502.a

%.h: %.c
	./makeheaders $^

makeheaders: makeheaders.c
	gcc -o $@ $^

headers: makeheaders $(HEADERS)

libfake6502.so: $(OBJS)
	$(CC) -shared -o $@ $^

libfake6502.a: makeheaders $(OBJS)
	$(AR) rcs $@ $(OBJS)


clean: 
	rm -f $(OBJS) tester

$(OBJS): $(HEADERS)


