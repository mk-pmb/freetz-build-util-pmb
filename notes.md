﻿
Missing packages
================

```bash
sudo aptitude install \
  libacl1-dev \
  libcap-dev \
  libncurses-dev \
  realpath \
  ;
```



Additional download sources
===========================

Replacements for broken links
-----------------------------

* dropbear:
  [Author's download site](https://matt.ucc.asn.au/dropbear/releases/)
* git:
  [Oregon State University](https://ftp.osuosl.org/pub/blfs/conglomeration/git/)
* OpenSSH:
  [ftp.openbsd.org](http://ftp.openbsd.org/pub/OpenBSD/OpenSSH/portable/)
  [ftp.vim.org](http://ftp.vim.org/security/OpenSSH/)
* TinyProxy:
  [launchpad](https://launchpad.net/tinyproxy/1.8/1.8.2)



Trouble shooting
================

* "ERROR: kernel image is … too big.":
  [SquashFS block size](https://github.com/Freetz/freetz.github.io/issues/9)
* iptables LOG output can be read with the `dmesg` command.



