CODEDIRS=. lib
INCDIR=include
MCU=18F452
HEX=out.hex
COF=out.cof
CC=mpasmx
LK=mplink
CFLAGS= -p$(MCU)
LFLAGS= -p$(MCU)
ASMFILES=$(foreach D, $(CODEDIRS), $(wildcard $(D)/*.asm))
INCFILES=$(foreach D, $(INCDIR), $(wildcard $(D)/*.inc))
OBJECTS=$(patsubst %.asm,%.o, $(ASMFILES))
ERRFILES=$(patsubst %.asm,%.ERR, $(ASMFILES))
LSTFILES=$(patsubst %.asm,%.LST, $(ASMFILES))

all: $(HEX)

$(HEX): $(COF)
	mp2hex $^

$(COF): $(OBJECTS)
	$(LK) -x $(LFLAGS) $^ -o$@

main.o: main.asm $(INCFILES)
	$(CC) $(CFLAGS) -o$@ $<
	@grep Error $(basename $@).ERR | grep -v grep | cat

%.o:%.asm
	$(CC) $(CFLAGS) -o$@ $<
	@grep Error $(basename $@).ERR | grep -v grep | cat

clean:
	rm -rf $(HEX) $(COF) $(OBJECTS) $(ERRFILES) $(LSTFILES)

flash: $(HEX) 
	pk2cmd -PPIC$(MCU) -M -Fout.hex -W -R
