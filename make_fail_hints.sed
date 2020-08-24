#!/bin/sed -nurf
# -*- coding: UTF-8, tab-width: 2 -*-

/^fakeroot: preload library \S*libfakeroot\.so\S* not found/{
  s~^~Maybe 'make fakeroot-dirclean' can solve this: ~p
}
