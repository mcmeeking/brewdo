#!/bin/sh

# Uninstall cask using $4

FAILED=0

# Elevate _brew to admin
dscl /Local/Default -append /groups/admin GroupMembership "_brew"

if ! brewdo cask remove "$4"; then
    brewdo cask zap --force "$4" || FAILED=1
fi

dscl /Local/Default -delete /groups/admin GroupMembership "_brew"

exit $FAILED