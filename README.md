# lsb-release-minimal

This repository contains a bare-bones version of the `lsb_release` command,
implemented as a tiny POSIX shell script (less than 100 lines of
commented code).

Instead of using LSB packages, this version of `lsb_release` uses the
information in `/etc/os-release`. Nevertheless, the output of this version
is byte-for-byte compatible with the Python-based version provided by Debian
and its derivatives.

Using this implementation it is possible to avoid installing Python in a
base OS image while still retaining compatibility with older scripts that
expect `lsb_release` to exist.

## Authors

* Gioele Barabucci https://gioele.io

## License

This is free software released under the terms of the ISC license.

See the `LICENCE.txt` file for more details.
