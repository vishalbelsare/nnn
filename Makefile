VERSION = 2.0

PREFIX ?= /usr/local
MANPREFIX ?= $(PREFIX)/share/man
STRIP ?= strip
PKG_CONFIG ?= pkg-config
INSTALL ?= install

CFLAGS ?= -O3
CFLAGS += -Wall -Wextra -Wno-unused-parameter

ifeq ($(shell $(PKG_CONFIG) ncursesw && echo 1),1)
	CFLAGS += $(shell $(PKG_CONFIG) --cflags ncursesw)
	LDLIBS += $(shell $(PKG_CONFIG) --libs   ncursesw)
else
	LDLIBS += -lncurses
endif

DISTFILES = src nnn.1 Makefile README.md LICENSE
SRC = src/nnn.c
BIN = nnn

all: $(BIN)

$(SRC): src/nnn.h

$(BIN): $(SRC)
	$(CC) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) -o $@ $^ $(LDLIBS)

debug: $(SRC)
	$(CC) -DDEBUGMODE -g $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) -o $(BIN) $^ $(LDLIBS)

install: all
	$(INSTALL) -m 0755 -d $(DESTDIR)$(PREFIX)/bin
	$(INSTALL) -m 0755 $(BIN) $(DESTDIR)$(PREFIX)/bin
	$(INSTALL) -m 0755 -d $(DESTDIR)$(MANPREFIX)/man1
	$(INSTALL) -m 0644 $(BIN).1 $(DESTDIR)$(MANPREFIX)/man1

uninstall:
	$(RM) $(DESTDIR)$(PREFIX)/bin/$(BIN)
	$(RM) $(DESTDIR)$(MANPREFIX)/man1/$(BIN).1

strip: $(BIN)
	$(STRIP) $^

dist:
	mkdir -p nnn-$(VERSION)
	$(CP) -r $(DISTFILES) nnn-$(VERSION)
	tar -cf nnn-$(VERSION).tar nnn-$(VERSION)
	gzip nnn-$(VERSION).tar
	$(RM) -r nnn-$(VERSION)

clean:
	$(RM) -f $(BIN) nnn-$(VERSION).tar.gz

skip: ;

.PHONY: $(BIN) $(SRC) all debug install uninstall strip dist clean
