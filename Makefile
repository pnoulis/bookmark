#!/usr/bin/env make

SHELL								= /usr/bin/bash
.DEFAULT_GOAL: all
.DELETE_ON_ERROR:

SRCDIR_TOP					= .
SRCDIR							= $(SRCDIR_TOP)/src
MODE								= dev

# Installation directories
export BUILDIR			= $(SRCDIR_TOP)
export prefix				= /usr/local
export exec_prefix	= ${prefix}

ifeq ($(MODE),dev)
export sysconfdir   = $(BUILDIR)
else
export sysconfdir		= ${prefix}/etc
endif

export bindir       = ${exec_prefix}/bin

# Compilation targets
BOOKMARK						= $(BUILDIR)/bookmark

# Utilites
MKDIR_P							= /usr/bin/mkdir -p
INSTALL							= /usr/bin/install
M4									= /usr/bin/m4
M4FLAGS							= -D__SYSCONFDIR__=$(sysconfdir)

.PHONY: all
all: build

.PHONY: build
build: $(BOOKMARK)

$(BOOKMARK): $(SRCDIR)/bookmark
	$(M4) $(M4FLAGS) $< > $@
	chmod 775 $@

.PHONY: install
install:
	$(MKDIR_P) "$(DESTDIR)${bindir}"
	$(INSTALL) $(notdir $(BOOKMARK)) "$(DESTDIR)${bindir}"

.PHONY: uninstall
uninstall:
	rm -f "$(DESTDIR)${bindir}/$(notdir $(BOOKMARK))"

clean:
	rm -f $(BOOKMARK)
