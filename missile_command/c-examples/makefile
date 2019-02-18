SOURCE = labels.c tester.c fake6502.c vic_os.c
PRIVATE_SOURCE = machine.c
all: makeheaders 
	./makeheaders $(SOURCE)
	gcc -D WSL -g $(SOURCE) $(PRIVATE_SOURCE) -o tester && ./tester
