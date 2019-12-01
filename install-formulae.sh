#!/bin/sh

# Install (or reinstall) formulae using $4

# Elevate _brew to admin
dscl /Local/Default -append /groups/admin GroupMembership "_brew"

if ! brewdo install "$4"; then
    brewdo reinstall "$4"
fi

dscl /Local/Default -delete /groups/admin GroupMembership "_brew"