#
# This is part of JOBSHOP, a set of codes for job-shop scheduling by
# David Applegate and Bill Cook.  The codes are based on "A computational
# study of the job-shop scheduling problem" to appear in the ORSA Journal
# on Computing.
#

CC=cc
CFLAGS = -O

ONEMACHOBJS=onemain.o onemach.o 
BOTTLEOBJS=botmain.o bottle.o boteval.o onemach.o

all: onemach bottle

onemach: $(ONEMACHOBJS)
	$(CC) $(CFLAGS) -o onemach $(ONEMACHOBJS)

bottle: $(BOTTLEOBJS)
	$(CC) $(CFLAGS) -o bottle $(BOTTLEOBJS) -lm

boteval.o: bottle.h
onemain.o: bottle.h
onemach.o: bottle.h
botmain.o: bottle.h
bottle.o: bottle.h

clean:
	rm -f *.o

lint:
	lint *.c
