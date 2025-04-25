# SPDX-FileCopyrightText: 2021 Gioele Barabucci
# SPDX-License-Identifier: ISC

VERSION = 12.1

# Paths
prefix = /usr
exec_prefix = $(prefix)
bindir = $(prefix)/bin
datarootdir = $(prefix)/share
mandir = $(datarootdir)/man

# Programs and options
BATS = bats
INSTALL = install
POD2MAN = pod2man
POD2MAN_OPTS = --center="User Commands" --release="lsb_release $(VERSION)"
SHELLCHECK = shellcheck
SHELLCHECK_OPTS = -e SC1090 -x

# Genrated files
MANPAGE = lsb_release.1

GENERATED_FILES = $(MANPAGE)

all: $(GENERATED_FILES)

%.1: %.pod
	$(POD2MAN) $(POD2MAN_OPTS) $< > $@

check:
	$(SHELLCHECK) $(SHELLCHECK_OPTS) lsb_release
	$(BATS) lsb_release.bats
	@echo "All checks passed"

clean:
	rm -f $(GENERATED_FILES)

install: all
	$(INSTALL) -D lsb_release $(DESTDIR)$(bindir)/lsb_release
	$(INSTALL) -D $(MANPAGE) -m 0444 -t $(DESTDIR)$(mandir)/man1/

.PHONY: all check clean install
