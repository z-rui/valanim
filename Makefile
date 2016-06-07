CC=gcc
VALAC=valac
CFLAGS=-O2
CFLAGS+=`pkg-config --cflags gtk+-3.0`
LDLIBS+=`pkg-config --libs gtk+-3.0`

all: console_play gui_play

console_play: console_play.o nim.o

gui_play: gui_play.o nim.o

%.c: %.vala nim.vapi
	$(VALAC) -C --pkg gtk+-3.0 $^

nim.c nim.h nim.vapi: nim.vala
	$(VALAC) -C -H nim.h --vapi nim.vapi --use-header $<
