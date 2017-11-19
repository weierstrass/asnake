

SRCDIR = src
OBJDIR = build

VPATH = $(SRCDIR)
ASMSRCS = $(addsuffix /*.S, $(SRCDIR))
CCSRCS = $(addsuffix /*.c, $(SRCDIR))
ASRCS = $(wildcard $(ASMSRCS)) 
CSRCS = $(wildcard $(CCSRCS))
SRCS = $(ASRCS) $(CSRCS)  
OBJS = $(addprefix $(OBJDIR)/, $(notdir $(ASRCS:.S=.o))) $(addprefix $(OBJDIR)/, $(notdir $(CSRCS:.c=.o)))

CC = gcc
AS = as
LD = ld

CFLAGS = -g
ASFLAGS = -g -o
LDFLAGS = -g -dynamic-linker /lib64/ld-linux-x86-64.so.2

LIBS = -lc -lSDLmain -lSDL

# Build rules
.PHONY: print all clean test

all: $(OBJDIR) a.out

$(OBJDIR):
	mkdir $(OBJDIR)

$(OBJDIR)/%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJDIR)/%.o: %.S
	$(AS) $(ASFLAGS) $@ $<

a.out: $(OBJS)
	$(LD) $(OBJS) $(LIBS) $(LDFLAGS)
clean:
	rm -f a.out $(OBJDIR)/*.o *.o

print:
	echo $(SRCS)
	echo $(OBJS)

test:
	gcc -fverbose-asm -O2 -S -c test.c
