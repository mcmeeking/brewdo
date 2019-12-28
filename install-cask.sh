#!/bin/sh

# Install (or reinstall) cask using $4

FAILED=0

# Elevate _brew to admin
dscl /Local/Default -append /groups/admin GroupMembership "_brew"

if ! brewdo cask install "$4"; then
    brewdo cask reinstall "$4" || FAILED=1
fi

dscl /Local/Default -delete /groups/admin GroupMembership "_brew"

exit $FAILED