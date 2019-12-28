#!/bin/sh

# Install (or reinstall) formulae using $4

FAILED=0

# Elevate _brew to admin
dscl /Local/Default -append /groups/admin GroupMembership "_brew"

if ! brewdo remove "$4"; then
    brewdo remove --force "$4" || FAILED=1
fi

dscl /Local/Default -delete /groups/admin GroupMembership "_brew"

exit $FAILED