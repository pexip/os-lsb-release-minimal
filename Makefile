INSTALL=install
prefix=/usr

VERSION=12.0

POD2MAN_OPTS=--center="User Commands" --release="lsb_release $(VERSION)"
SHELLCHECK_OPTS=-e SC1090 -x

all: lsb_release.1

lsb_release.1: lsb_release.pod
	pod2man $(POD2MAN_OPTS) $< > $@

check:
	shellcheck $(SHELLCHECK_OPTS) lsb_release
	bats lsb_release.bats

clean:
	rm -f lsb_release.1

install: all
	$(INSTALL) -D lsb_release $(DESTDIR)$(prefix)/bin/lsb_release
	$(INSTALL) -D lsb_release.1 -m 0444 -t $(DESTDIR)$(prefix)/share/man/man1/

.PHONY: all check clean install
