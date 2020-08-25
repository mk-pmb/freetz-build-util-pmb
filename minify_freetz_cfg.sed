#!/bin/sed -urf
# -*- coding: UTF-8, tab-width: 2 -*-
/^#?\s*$/d
/^# [A-Za-z0-9_-]+ is not set$/d
