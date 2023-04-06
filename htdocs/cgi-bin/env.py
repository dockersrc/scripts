#!/usr/bin/env python
import sys
import os

print "Content-Type: text/html\n\n"

for name, value in os.environ.items():
    print "%s\t= %s <br/>" % (name, value)
