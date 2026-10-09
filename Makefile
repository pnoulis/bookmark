#!/usr/bin/env make

SHELL									= /usr/bin/bash
.DEFAULT_GOAL: all
.DELETE_ON_ERROR:

APPID									= bookmark
SRCDIR_TOP						= .
SRCDIR								= $(SRCDIR_TOP)/src
BOOKMARKS_FILENAME		= bookmarks.csv

# Installation directories
export BUILDIR				= $(SRCDIR_TOP)
export prefix					= /usr/local
export exec_prefix		= ${prefix}
export bindir					= ${exec_prefix}/bin
export datarootdir		= ${prefix}/share
export datadir				= ${datarootdir}
export libdir					= ${exec_prefix}/lib
export libexecdir			= ${exec_prefix}/libexec
export sysconfdir			= ${prefix}/etc
export applibdir			= ${libdir}/$(APPID)
export applibexecdir	= ${libexecdir}/$(APPID)
export appdatadir			= ${datadir}/$(APPID)
export appconfdir			= ${sysconfdir}/$(APPID)

# Compilation targets
BOOKMARK							= $(BUILDIR)/bookmark
BOOKMARK_IMPORT       = $(BUILDIR)/import
INSTALL_HELPER    		= $(BUILDIR)/install.system
ENV										= $(BUILDIR)/env

# Utilites
MKDIR_P								= /usr/bin/mkdir -p
INSTALL								= /usr/bin/install
M4										= /usr/bin/m4
M4FLAGS								= -D__SYSCONFDIR__=$(sysconfdir) -D__APPID__=$(APPID) -D __BOOKMARKS_FILENAME__=$(BOOKMARKS_FILENAME) -D__NODE_EXE__=$(NODE_EXE) -D__TERMINAL_EXE__=$(TERMINAL_EXE) -D__FUZZY_SEARCH_EXE__=$(FUZZY_SEARCH_EXE) -D__CLIPBOARD_COPY_EXE__=$(CLIPBOARD_COPY_EXE) -D__APPLIBEXECDIR__=$(applibexecdir)
ECMA_VERSION					= es2024
NODE_VERSION					= 24.11.1
NODE_VVERSION					= v$(NODE_VERSION)
NVM_BINDIR						= $(HOME)/.nvm/versions/node/$(NODE_VVERSION)/bin
NODE_EXE							= $(NVM_BIN)/node
ESBUILD 							= $(NVM_BIN)/esbuild
TERMINAL_EXE					=/usr/bin/foot
FUZZY_SEARCH_EXE			=/usr/bin/fzf
CLIPBOARD_COPY_EXE		=/usr/bin/wl-copy

.PHONY: all
all: build

.PHONY: build
build: $(BOOKMARK) $(BOOKMARK_IMPORT) $(INSTALL_HELPER) $(ENV)

$(BOOKMARK): $(SRCDIR)/bookmark.sh
	$(M4) $(M4FLAGS) $< > $@
	chmod 775 $@

$(ENV): $(SRCDIR)/env.m4
	$(M4) $(M4FLAGS) $< > $@

$(BOOKMARK_IMPORT): $(SRCDIR)/import.js $(SRCDIR)/converters/*
	$(ESBUILD) $< --bundle --platform=node --target=$(ECMA_VERSION) --minify > $@
	chmod 775 $@

$(INSTALL_HELPER):
	echo 'make prefix=/usr/local \
sysconfdir=/etc \
libdir=/usr/local/lib \
libexecdir=/usr/local/lib \
install' > $@
	chmod 775 $@

.PHONY: install
install:
	$(MKDIR_P) "$(DESTDIR)${bindir}"
	$(INSTALL) $(notdir $(BOOKMARK)) "$(DESTDIR)${bindir}"

.PHONY: uninstall
uninstall:
	rm -f "$(DESTDIR)${bindir}/$(notdir $(BOOKMARK))"
	rm -fr "$(DESTDIR)${applibdir}" \
	"$(DESTDIR)${appdatadir}" \
	"$(DESTDIR)${appconfdir}"

clean:
	rm -f $(BOOKMARK) $(BOOKMARK_IMPORT) $(INSTALL_HELPER) $(ENV)
