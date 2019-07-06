# run c program that examines a prototype
# of the line algorithm
LDLIBS = -lm
CC=gcc
all: bresenham
	echo 11 17 1 11 | ./$<
	echo 17 11 1 11 | ./$<
	echo 11 17 11 1 | ./$<
	echo 17 11 11 1 | ./$<
	echo "long X lines"
	echo 1 11 1 3 | ./$<
	echo 11 1 1 3 | ./$<
	echo 1 11 3 1 | ./$<
	echo 11 1 3 1 | ./$<


all2: bresenham
	echo 1 11 3 1 | ./$<
	echo 1 11 1 3 | ./$<
	echo 11 1 3 1 | ./$<
	echo 11 1 1 3 | ./$<


